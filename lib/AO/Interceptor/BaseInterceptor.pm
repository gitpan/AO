# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::BaseInterceptor;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       context_manager => undef,
      }, $class;

    return $self;
  }

sub context_manager
  {
    my $self = shift;
    $self->{context_manager} = shift if @_;

    return $self->{context_manager};
  }

1;
