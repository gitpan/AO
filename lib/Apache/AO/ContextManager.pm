# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Apache::AO::ContextManager;

use AO::ContextManager ();
@ISA = qw(AO::ContextManager);

use strict;
use Apache::AO::Logger ();

sub service
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;

    return $self->SUPER::service($req, $res);
  }

sub logger
  {
    my $self = shift;
    if (@_)
      {
        $self->{logger} = shift;
      }
    elsif (!$self->{logger})
      {
        $self->{logger} = Apache::AO::Logger->new();
      }

    return $self->{logger};
  }

1;
