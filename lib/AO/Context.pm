# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Context;

use strict;
use File::Spec ();

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       context_manager => undef,
       session_manager => undef,
       path => undef,
       doc_base => undef,
       display_name => undef,
       description => undef,
       session_timeout => undef,
       auth_method => undef,
       realm_name => undef,
       form_login_page => undef,
       form_error_page => undef,
       context_interceptors => [],
       request_interceptors => [],
       servlets => [],
       security_constraints => {},
       security_patterns => [],
       logger => undef,
      }, $class;

    return $self;
  }

sub context_manager
  {
    my $self = shift;
    $self->{context_manager} = shift if @_;

    return $self->{context_manager};
  }

sub session_manager
  {
    my $self = shift;
    $self->{session_manager} = shift if @_;

    return $self->{session_manager};
  }

sub path
  {
    my $self = shift;
    $self->{path} = shift if @_;

    return $self->{path};
  }

sub doc_base
  {
    my $self = shift;
    $self->{doc_base} = shift if @_;

    return $self->{doc_base};
  }

sub absolute_path
  {
    my $self = shift;

    return $self->{abs_path} if $self->{abs_path};

    if (File::Spec->file_name_is_absolute($self->{doc_base}))
      {
        $self->{abs_path} = $self->{doc_base};
      }
    else
      {
        $self->{abs_path} =
          File::Spec->catdir($self->{context_manager}->home(),
                             $self->{doc_base});
      }

    $self->{abs_path} = File::Spec->canonpath($self->{abs_path});

    return $self->{abs_path};
  }

sub display_name
  {
    my $self = shift;
    $self->{display_name} = shift if @_;

    return $self->{display_name};
  }

sub description
  {
    my $self = shift;
    $self->{description} = shift if @_;

    return $self->{description};
  }

sub session_timeout
  {
    my $self = shift;
    $self->{session_timeout} = shift if @_;

    return $self->{session_timeout};
  }

sub auth_method
  {
    my $self = shift;
    $self->{auth_method} = shift if @_;

    return $self->{auth_method};
  }

sub realm_name
  {
    my $self = shift;
    $self->{realm_name} = shift if @_;

    return $self->{realm_name};
  }

sub form_login_page
  {
    my $self = shift;
    $self->{form_login_page} = shift if @_;

    return $self->{form_login_page};
  }

sub form_error_page
  {
    my $self = shift;
    $self->{form_error_page} = shift if @_;

    return $self->{form_error_page};
  }

sub servlets
  {
    my $self = shift;

    return wantarray ?
      @{ $self->{servlets} } :
        $self->{servlets};
  }

sub add_servlet
  {
    my $self = shift;
    push @{ $self->{servlets} }, @_;

    return 1;
  }

sub security_constraint
  {
    my $self = shift;
    my $pattern = shift;

    return $self->{security_constraints}->{$pattern};
  }

sub add_security_constraint
  {
    my $self = shift;
    my $name = shift;
    my $description = shift;
    my $patterns = shift;
    my $methods = shift;
    my $roles = shift;

    $patterns = ['/*'] unless @$patterns;

    # XXX: does this need to be a class? *whine*

    for my $pattern (@$patterns)
      {
        $self->{security_constraints}->{$pattern} =
          {
           name => $name,
           description => $description,
           pattern => $pattern,
           methods => $methods,
           roles => $roles,
          };

        # later constraints override earlier ones
        unshift @{ $self->{security_patterns} }, $pattern;
      }

    return 1;
  }

sub security_patterns
  {
    my $self = shift;

    return wantarray ?
      @{ $self->{security_patterns} } :
        $self->{security_patterns};
  }

sub context_interceptors
  {
    my $self = shift;

    return $self->{context_interceptors};
  }

sub add_context_interceptor
  {
    my $self = shift;
    my $i = shift;

    $i->context_manager($self->context_manager());

    push @{ $self->{context_interceptors} }, $i;

    return 1;
  }

sub request_interceptors
  {
    my $self = shift;

    return $self->{request_interceptors};
  }

sub add_request_interceptor
  {
    my $self = shift;
    my $i = shift;

    $i->context_manager($self->context_manager());

    push @{ $self->{request_interceptors} }, $i;

    if ($i->isa('AO::Interceptor::ContextInterceptor'))
      {
        push @{ $self->{context_interceptors} }, $i;
      }

    return 1;
  }

sub logger
  {
    my $self = shift;
    $self->{logger} = shift if @_;

    return $self->{logger} ?
      $self->{logger} :
        $self->context_manager()->logger(@_);
  }

1;
