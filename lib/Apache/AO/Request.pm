# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Apache::AO::Request;

use AO::Request ();
use Apache::Request ();
@ISA = qw(AO::Request Apache::Request);

use strict;
use Apache::Cookie ();

sub init
  {
    my $self = shift;

    $self->{_r} = shift; # $r
    $self->{_cookies_parsed} = undef;

    return 1;
  }

sub cookies
  {
    my $self = shift;

    return $self->{cookies} if $self->{_cookies_parsed};

    $self->{cookies} = Apache::Cookie->fetch();
    $self->{_cookies_parsed} = 1;

    return $self->{cookies};
  }

sub remote_user
  {
    my $self = shift;
    $self->connection()->user(shift) if @_;

    return $self->connection()->user();
  }

1;
