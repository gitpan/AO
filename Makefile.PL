# -*- Mode: Perl; -*-

use ExtUtils::MakeMaker;

%WriteArgs =
  (
   NAME         => 'AO',
   VERSION_FROM => 'lib/AO.pm',
#   PL_FILES     => { "bin/ao.PL" => "bin/ao" },
#   EXE_FILES    => [ "bin/ao" ],
   PREREQ_PM    =>
   {
# XXX: find a way to add Apache stuff as prereqs only if installing
# into a mod_perl environment
    Apache          => '0',
    Apache::Request => '0',
    Apache::Session => '1.51',
    DBI             => '0',
    File::Spec      => '0',
    HTML::Mason     => '0',
    XML::XPath      => '0',
   },
   clean        => { FILES => 'bin/ao' },
  );

ExtUtils::MakeMaker::WriteMakefile(%WriteArgs);

1;
