# -*- Mode: Perl; indent-tabs-mode: nil -*-

use Config;
use File::Basename qw(basename dirname);

# horked from lwp-download.PL
chdir(dirname($0));
($file = basename($0)) =~ s/\.PL$//;
$file =~ s/\.pl$//
  if ($Config{osname} eq 'VMS' or
      $Config{osname} eq 'OS2');  # "case-forgiving"
open OUT,">$file" or die "Can't create $file: $!";
chmod(0755, $file);
print "Extracting $file (with variable substitutions)\n";

$script = <<'!END!OF!SCRIPT!';
# -*- Mode: Perl; indent-tabs-mode: nil -*-

use strict;

use AO::ContextManager ();
use AO::Config::Server ();
use AO::Request ();
use AO::Response ();
use Cwd ();
use File::Basename ();
use Symbol ();

my $PROGRAM = File::Basename::basename($0);

my $cm = AO::ContextManager->new();
my $cfg = AO::Config::Server->new();

my $home = shift || $ENV{AO_HOME} || Cwd::cwd();
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
$cm->start();

my $req = AO::Request->new();
my $res = AO::Response->new();

$cm->init_request($req, $res);

$cm->service($req, $res);

$cm->stop();
$cm->shutdown();

1;
__END__

=pod

=head1 NAME

ao - AO standalone test script

=head1 SYNOPSIS

 ao

=head1 DESCRIPTION

This program is a simple test script for the AO server. It could theoretically
eventually become the basis for an out-of-process configuration of AO, but
right now it's not more than a test.pl.

=head1 USAGE

Before installation:

  cd ao-x.xx
  perl -I./lib bin/ao

After installation:

  ao

=head1 AUTHOR

Brian Moseley <bcm@maz.org>

=cut
!END!OF!SCRIPT!

print OUT "$Config{startperl} -w\n";
print OUT $script;
