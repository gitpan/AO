# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Apache::AO;

use strict;

use AO::Config::Server ();
use Apache ();
use Apache::AO::ContextManager ();
use Apache::AO::Request ();
use Apache::AO::Response ();
use Apache::DBI ();  # XXX: need more robust db manager class? ;)
use Apache::Request ();
use Symbol ();

my $cm;

BEGIN
  {
    $cm = Apache::AO::ContextManager->new();
    my $cfg = AO::Config::Server->new();

    my $home = $ENV{AO_HOME} || Apache->server_root_relative();
    $cm->home($home);

    my @file_loc = defined($ENV{AO_CONFIG}) ?
      ($ENV{AO_CONFIG}) :
        ("$home/conf/server.xml", "$home/etc/server.xml", "$home/server.xml");
    my $cfg_file;
    for my $f (@file_loc)
      {
        if (-f $f)
          {
            $cfg_file = $f;
            last;
          }
      }

    die("Can't find server.xml! Search path: ",
        join(' ', @file_loc), "\n") unless $cfg_file;

    my $fh = Symbol::gensym();
    open $fh, $cfg_file or
      die "Can't open config file [$cfg_file]: $!\n";

    $cfg->read_config($fh, $cm);

    $cm->init();
  }

sub handler
  {
    my $r = Apache::Request->new(shift);

    my $req = Apache::AO::Request->new($r);
    my $res = Apache::AO::Response->new($r);

    $cm->init_request($req, $res);

    # context mapping

    my $uri = $req->uri();
    my ($ctx, $path, $c);

    # XXX does this method give 'longest path' match?
    for my $c ($cm->contexts())
      {
        $path = $c->path();
        if ($uri =~ m|^$path|)
          {
            $ctx = $c;
            $req->context($ctx);
            last;
          }
      }

    die "Can't find context for request ", $req->uri(), "\n" unless $ctx;

    # request mapping

    my $ctx_path = $ctx->path();
    $uri =~ m|${ctx_path}(.*)|;
    my $srv_path = $1 || '/';

    $req->servlet_path($srv_path);
    $req->filename(File::Spec->catdir($ctx->absolute_path(), $srv_path));

    # XXX: using 'default servlet' only
    $req->servlet($ctx->servlets()->[0]);

    $cm->service($req, $res);
  }

END
  {
    $cm->shutdown();
  }

1;
