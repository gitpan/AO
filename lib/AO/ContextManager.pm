# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::ContextManager;

use strict;
use Cwd ();
use File::Spec ();

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       contexts => [],
       _context_table => {},
       context_interceptors => [],
       request_interceptors => [],
       home => '',
       logger => undef,
      }, $class;

    return $self;
  }

sub init
  {
    my $self = shift;
    my $l = $self->logger();
    my ($i, $c);

    for $i (@{ $self->context_interceptors() })
      {
        $l->info("calling engine_init on $i");
        $i->engine_init($self);
      }

    for $c ($self->contexts())
      {
        for $i (@{ $self->context_interceptors($c) })
          {
            $l->info("calling context_init on $i for $c");
            $i->context_init($c);
          }
      }

    return 1;
  }

sub shutdown
  {
    my $self = shift;
    my $l = $self->logger();
    my ($i, $c);

    for $c ($self->contexts())
      {
        for $i (@{ $self->context_interceptors($c) })
          {
            $l->info("calling context_shutdown on $c");
            $i->context_shutdown($c);
          }

        # close context-specific logs but not our own log
        $c->logger()->close() unless ref($c->logger()) eq ref($l);

        $self->remove_context($c);
      }

    for $i (@{ $self->context_interceptors() })
      {
        $l->info("calling engine_shutdown on $i");
        $i->engine_shutdown($self);
      }

    $l->close();

    return 1;
  }

sub start
  {
    # XXX: stubbed, waiting for out-of-process implementation
  }

sub stop
  {
    # XXX: stubbed, waiting for out-of-process implementation
  }

sub init_request
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;

    $res->request($req);
    $req->response($res);
    $req->context_manager($self);
  }

sub service
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;
    my $i;
    my $servlet;
    my @roles;
    my $status = 0;

    for $i (@{ $self->request_interceptors($req) })
      {
        $status = $i->context_map($req, $res);
        return $status if $status;

        $status = $i->request_map($req, $res);
        return $status if $status;
      }

    return 404 unless $servlet = $req->servlet();

    for $i (@{ $self->request_interceptors($req) })
      {
        $status = $i->authenticate($req, $res);
        if ($status)
          {
            if ($status == 401)
              {
                return $req->redirect($req->context()->form_error_page());
              }
            return $status;
          }
      }

    if (@roles = $req->required_roles())
      {
        for $i (@{ $self->request_interceptors($req) })
          {
            $status = $i->authorize($req, $res, \@roles);
            if ($status)
              {
                if ($status == 401)
                  {
                    return $req->redirect($req->context()->form_error_page());
                  }
                return $status;
              }
          }
      }

    $servlet->load() unless $servlet->is_loaded();

    for $i (@{ $self->request_interceptors($req) })
      {
        $status = $i->pre_service($req, $res);
        return $status if $status;
      }

    $status = $servlet->service($req, $res);

    for $i (@{ $self->request_interceptors($req) })
      {
        $i->post_service($req, $res);
      }

    return $status;
  }

sub home
  {
    my $self = shift;
    $self->{home} = shift if @_;

    return $self->{home};
  }

sub contexts
  {
    my $self = shift;

    return grep { defined } @{ $self->{contexts} };
  }

sub add_context
  {
    my $self = shift;
    my $context = shift;

    $context->context_manager($self);

    for my $i (@{ $self->context_interceptors() })
      {
        $i->add_context($context);
      }

    push @{ $self->{contexts} }, $context;
    $self->{_context_table}->{$context->path()} =
      length(@{ $self->{contexts} }) - 1;

    unshift @INC,
      File::Spec->catdir($context->absolute_path(), 'WEB-INF', 'lib');

    return 1;
  }

sub remove_context
  {
    my $self = shift;
    my $context = shift;

    for my $i (@{ $self->context_interceptors() })
      {
        $i->remove_context($context);
      }

    my $ix = $self->{_context_table}->{$context->path()};
    $self->{contexts}->[$ix] = undef;
    delete $self->{_context_table}->{$context->path()};

    my $libpath =
      File::Spec->catdir($context->absolute_path(), 'WEB-INF', 'lib');
    @INC = grep { ! /^$libpath$/ } @INC;

    return 1;
  }

sub request_interceptors
  {
    my $self = shift;
    my $req = shift;

    if ($req)
      {
        return ([@{ $self->{request_interceptors} },
                 @{ $req->context()->request_interceptors() }]);
      }

    return $self->{request_interceptors};
  }

sub add_request_interceptor
  {
    my $self = shift;
    my $i = shift;

    $i->context_manager($self);

    push @{ $self->{request_interceptors} }, $i;

    if ($i->isa('AO::Interceptor::ContextInterceptor'))
      {
        push @{ $self->{context_interceptors} }, $i;
      }
  }

sub context_interceptors
  {
    my $self = shift;
    my $ctx = shift;

    if ($ctx)
      {
        return ([@{ $self->{context_interceptors} },
                 @{ $ctx->context_interceptors() }]);
      }

    return $self->{context_interceptors};
  }

sub add_context_interceptor
  {
    my $self = shift;
    my $i = shift;

    $i->context_manager($self);

    push @{ $self->{context_interceptors} }, $i;
  }

sub logger
  {
    my $self = shift;
    $self->{logger} = shift if @_;

    return $self->{logger};
  }

1;
