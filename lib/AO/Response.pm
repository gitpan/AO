# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Response;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       request => undef,
       cookies => [],
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init
  {
  }

sub request
  {
    my $self = shift;
    $self->{request} = shift if @_;

    return $self->{request};
  }

sub add_cookie
  {
    my $self = shift;
    my $cookie = shift;

    if ($cookie)
      {
        push @{ $self->{cookies} }, $cookie;
      }

    return 1;
  }

1;
