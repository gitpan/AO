# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::ContextConfig;

use AO::Interceptor::ContextInterceptor ();
@ISA = qw(AO::Interceptor::ContextInterceptor);

use strict;
use AO::Config::Context ();
use File::Spec ();

sub context_init
  {
    my $self = shift;
    my $ctx = shift;

    my $cm = $ctx->context_manager();
    my $cfg = AO::Config::Context->new();

    my $cfg_file = File::Spec->catfile($ctx->absolute_path(),
                                       'WEB-INF', 'web.xml');
    die "Can't find context config file [$cfg_file]!\n" unless -f $cfg_file;

    $cm->logger()->info("loading context config file $cfg_file");

    my $fh = Symbol::gensym();
    open $fh, $cfg_file or
      die "Can't open context config file [$cfg_file]: $!\n";

    $cfg->read_config($fh, $ctx);

    return 0;
  }

1;
