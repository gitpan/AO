# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Apache::AO::Response;

use AO::Response ();
use Apache::Request ();
@ISA = qw(AO::Response Apache::Request);

use strict;
use Apache::Cookie ();

sub init
  {
    my $self = shift;

    $self->{_r} = shift; # $r

    return 1;
  }

sub add_cookie
  {
    my $self = shift;
    my $cookie = shift;

    if ($cookie)
      {
        unless ($cookie->isa('Apache::Cookie'))
          {
            my $new_cookie = Apache::Cookie->new($self);

            $new_cookie->name($cookie->name()) if $cookie->name();
            $new_cookie->value([$cookie->value()]);
            $new_cookie->domain($cookie->domain()) if $cookie->domain();
            $new_cookie->path($cookie->path()) if $cookie->path();
            $new_cookie->expires($cookie->expires()) if $cookie->expires();
            $new_cookie->secure($cookie->secure()) if $cookie->secure();

            $cookie = $new_cookie;
          }

        $cookie->bake();
      };

    return 1;
  }

1;
