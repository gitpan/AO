# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::SessionManager::BaseSessionManager;

use strict;
use AO::Session ();

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       timeout => undef,
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init
  {
  }

sub find_session {}
sub get_new_session {}

sub timeout
  {
    my $self = shift;
    $self->{timeout} = shift if @_;

    return $self->{timeout};
  }

sub is_expired
  {
    my $self = shift;
    my $ses = shift;

    if ($self->{timeout})
      {
        my $time = time();

        if (defined($ses->{last_accessed}) &&
            ($ses->{last_accessed} + $self->{timeout} < $time))
          {
            $ses->end();
            return 1;
          }

        $ses->{last_accessed} = $time;
      }

    return 0;
  }

sub release
  {
    my $self = shift;
    my $ses = shift;

    # no storing objects referenced circularly!
    delete $ses->{session_manager};

    $ses->is_new(undef);

    tied(%$ses)->DESTROY();

    return 1;
  }

sub end
  {
    my $self = shift;
    my $ses = shift;

    tied(%$ses)->delete();

    return 1;
  }

1;
