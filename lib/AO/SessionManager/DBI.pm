# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::SessionManager::DBI;

use AO::SessionManager::BaseSessionManager ();
@ISA = qw(AO::SessionManager::BaseSessionManager);

use strict;

my $drivers =
  {
   mysql => 'Apache::Session::MySQL',
   postgres => 'Apache::Session::Postgres',
   oracle => 'Apache::Session::Oracle',
  };

sub init
  {
    my $self = shift;

    $self->{connection_url} = shift || undef;
    $self->{connection_name} = shift || undef;
    $self->{connection_password} = shift || undef;
    $self->{driver} = undef;

    $self->_load_driver() if $self->{connection_url};

    return 1;
  }

sub _load_driver
  {
    my $self = shift;

    my ($driver_name) = ($self->{connection_url} =~ m|^DBI:([^:]+):|i);

    my $driver = $drivers->{$driver_name};
    die "Unsupported session driver [$driver]\n" unless $driver;

    eval "require $driver";
    die $@ if $@;

    $self->{driver} = $driver;

    return 1;
  }

sub find_session
  {
    my $self = shift;
    my $id = shift;

    $self->_load_driver() unless $self->{driver};

    my $ses = AO::Session->new();
    tie(%$ses, $self->{driver}, $id,
        {
         DataSource => $self->{connection_url},
         UserName => $self->{connection_name},
         Password => $self->{connection_password},
         LockDataSource => $self->{connection_url},
         LockUserName => $self->{connection_name},
         LockPassword => $self->{connection_password},
        }) or die "Couldn't tie session: $!\n";

    $ses->session_manager($self);

    return undef if $self->is_expired($ses);
    return $ses;
  }

sub get_new_session
  {
    my $self = shift;

    $self->_load_driver() unless $self->{driver};

    my $ses = AO::Session->new();
    tie(%$ses, $self->{driver}, undef,
        {
         DataSource => $self->{connection_url},
         UserName => $self->{connection_name},
         Password => $self->{connection_password},
         LockDataSource => $self->{connection_url},
         LockUserName => $self->{connection_name},
         LockPassword => $self->{connection_password},
        }) or die "Couldn't tie session: $!\n";

    $ses->is_new(1);
    $ses->session_manager($self);

    return $ses;
  }

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

