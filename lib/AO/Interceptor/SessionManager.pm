# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::SessionManager;

use AO::Interceptor::ContextInterceptor ();
@ISA = qw(AO::Interceptor::ContextInterceptor);

use strict;
use AO::SessionManager::DBI ();

sub init
  {
    my $self = shift;

    $self->{connection_url} = undef;
    $self->{connection_name} = undef;
    $self->{connection_password} = undef;

    return 1;
  }

sub context_init
  {
    my $self = shift;
    my $ctx = shift;

    # XXX: support non-DBI session managers

    my $sm = AO::SessionManager::DBI->new($self->{connection_url},
                                          $self->{connection_name},
                                          $self->{connection_password});

    $ctx->session_manager($sm);

    return 0;
  }

# XXX: implement a context_shutdown hook that can whack all of the
# context's sessions. this requires changes to Apache::Session and to
# AO::SessionManager so that we can list all the current sessions.

sub connection_url
  {
    my $self = shift;
    $self->{connection_url} = shift if @_;

    return $self->{connection_url};
  }

sub connection_name
  {
    my $self = shift;
    $self->{connection_name} = shift if @_;

    return $self->{connection_name};
  }

sub connection_password
  {
    my $self = shift;
    $self->{connection_password} = shift if @_;

    return $self->{connection_password};
  }

1;
