# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Request;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       context_manager => undef,
       context => undef,
       servlet => undef,
       servlet_path => undef,
       response => undef,
       session => undef,
       cookies => {},
       remote_user => undef,
       required_roles => [],
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init
  {
  }

sub context_manager
  {
    my $self = shift;
    $self->{context_manager} = shift if @_;

    return $self->{context_manager};
  }

sub context
  {
    my $self = shift;
    $self->{context} = shift if @_;

    return $self->{context};
  }

sub servlet
  {
    my $self = shift;
    $self->{servlet} = shift if @_;

    return $self->{servlet};
  }

sub servlet_path
  {
    my $self = shift;
    $self->{servlet_path} = shift if @_;

    return $self->{servlet_path};
  }

sub response
  {
    my $self = shift;
    $self->{response} = shift if @_;

    return $self->{response};
  }

sub session
  {
    my $self = shift;
    $self->{session} = shift if @_;

    return $self->{session};
  }

sub cookies
  {
    my $self = shift;

    return $self->{cookies};
}

sub remote_user
  {
    my $self = shift;
    $self->{remote_user} = shift if @_;

    return $self->{remote_user};
  }

sub user_principal
  {
    my $self = shift;

    return undef unless $self->{session};

    my $p = $self->{session}->principal();
    if ($p)
      {
        $self->remote_user($p->{name}) unless $self->remote_user();
        return $p;
      }

    return undef unless $self->remote_user();

    $p = { name => $self->remote_user() }; # XXX: should be a class?
    $self->{session}->principal($p);

    return $p;
  }

sub required_roles
  {
    my $self = shift;
    $self->{required_roles} = shift if @_;

    return wantarray ? @{ $self->{required_roles} } : $self->{required_roles};
  }

# XXX: utility method, should it go elsewhere?

sub redirect
  {
    my $self = shift;
    my $ctx = $self->context();
    my $srv = $self->server();

    # XXX: put behind servlet api
    # XXX: how to figure out if ssl?
    my $url = 'http://' . $srv->server_hostname();
    $url = join(':', $url, $srv->port()) if $srv->port() != 80;
    $url .= (shift || $ctx->path());

    $self->response()->header_out(Location => $url);

    # explicitly release the session since redirecting will abort
    # the context manager's servicing

    $ctx->session_manager()->release($self->session());

    return 302;
  }

1;
