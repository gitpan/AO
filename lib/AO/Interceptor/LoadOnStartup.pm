# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::LoadOnStartup;

use AO::Interceptor::ContextInterceptor ();
@ISA = qw(AO::Interceptor::ContextInterceptor);

use strict;

sub context_init
  {
    my $self = shift;
    my $ctx = shift;

    my (%order, $sv, $srv);
    for $srv (@{ $ctx->servlets() })
      {
        $sv = $srv->load_on_startup();
        if (defined $sv)
          {
            $order{$sv} ||= [];
            push @{ $order{$sv} }, $srv;
          }
      }

    for $sv (sort keys %order)
      {
        for $srv (@{ $order{$sv} })
          {
            $srv->load();
          }
      }

    return 0;
  }

1;
