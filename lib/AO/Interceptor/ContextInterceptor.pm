# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::ContextInterceptor;

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
sub engine_init {}
sub context_init {}
sub add_context {}
sub remove_context {}
sub context_shutdown {}
sub engine_shutdown {}

1;
