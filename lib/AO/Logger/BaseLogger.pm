# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Logger::BaseLogger;

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

sub open {}
sub close {}
sub emerg {}
sub alert {}
sub crit {}
sub error {}
sub warn {}
sub notice {}
sub info {}
sub debug {}

sub log_level
  {
    my $self = shift;
    $self->{log_level} = shift if @_;

    return $self->{log_level};
  }

1;
