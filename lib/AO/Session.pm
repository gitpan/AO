# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Session;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       last_accessed => undef,
       is_new => undef,
       session_manager =>  undef,
       principal => undef,
      }, $class;

    $self->init();

    return $self;
  }

sub init
  {
  }

sub id
  {
    my $self = shift;

    return $self->{_session_id};
  }

sub last_accessed
  {
    my $self = shift;
    $self->{last_accessed} = shift if @_;

    return $self->{last_accessed};
  }

sub is_new
  {
    my $self = shift;
    $self->{is_new} = shift if @_;

    return $self->{is_new};
  }

sub session_manager
  {
    my $self = shift;
    $self->{session_manager} = shift if @_;

    return $self->{session_manager};
  }

sub principal
  {
    my $self = shift;
    $self->{principal} = shift if @_;

    return $self->{principal};
  }

1;
