# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::RequestInterceptor;

use AO::Interceptor::BaseInterceptor ();
@ISA = qw(AO::Interceptor::BaseInterceptor);

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init {}
sub context_map {}
sub request_map {}
sub authenticate {}
sub authorize {}
sub pre_service {}
sub post_service {}

1;
