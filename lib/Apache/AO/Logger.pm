# -*- Mode: Perl; indent-tabs-mode: nil -*-

package Apache::AO::Logger;

use AO::Logger::BaseLogger ();
@ISA = qw(AO::Logger::BaseLogger);

use strict;
use Apache ();
use Apache::Log ();

sub init
  {
    my $self = shift;
    my $opts = shift || {};

    $self->{_l} = Apache->server()->log();

    return 1;
  }

# no-ops
sub open {}
sub close {}

sub emerg
  {
    my $self = shift;
    $self->{_l}->emerg(@_);
  }

sub alert
  {
    my $self = shift;
    $self->{_l}->alert(@_);
  }

sub crit
  {
    my $self = shift;
    $self->{_l}->crit(@_);
  }

sub err
  {
    my $self = shift;
    $self->{_l}->err(@_);
  }

sub warn
  {
    my $self = shift;
    $self->{_l}->warning(@_);
  }

sub notice
  {
    my $self = shift;
    $self->{_l}->notice(@_);
  }

sub info
  {
    my $self = shift;
    $self->{_l}->info(@_);
  }

sub debug
  {
    my $self = shift;
    $self->{_l}->debug(@_);
  }

1;
