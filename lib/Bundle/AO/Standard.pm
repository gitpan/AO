package Bundle::AO::Standard;

$VERSION = '0.01';

=pod

=head1 NAME

Bundle::AO::Standard - libraries needed by standard AO interceptors

=head1 DESCRIPTION

This bundle specifies the libraries needed by the standard AO
interceptors. You should install this stuff if you want AO to work out
of the box. If you are developing new interceptors, this bundle
probably doesn't apply to you.

=head1 SYNOPSIS

  perl -MCPAN -e 'install Bundle::AO::Standard'

=head1 CONTENTS

Apache::Request

HTML::Mason

DBI

=cut

