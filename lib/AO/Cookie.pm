# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Cookie;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       name => undef,
       value => [],
       domain => undef,
       path => undef,
       expires => undef,
       secure => undef,
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init
  {
    my $self = shift;
    my %args = @_;

    if (%args)
      {
        for (qw(name domain path expires secure))
          {
            $self->{$_} = $args{$_} if defined $args{$_};
          }
        push @{ $self->{value} }, $args{value} if defined $args{value};
      }

    return 1;
  }

sub name
  {
    my $self = shift;
    $self->{name} = shift if @_;

    return $self->{name};
  }

sub value
  {
    my $self = shift;
    push @{ $self->{value} }, @_ if @_;

    return wantarray ? @{ $self->{value} } : $self->{value}->[0];
  }

sub domain
  {
    my $self = shift;
    $self->{domain} = shift if @_;

    return $self->{domain};
  }

sub path
  {
    my $self = shift;
    $self->{path} = shift if @_;

    return $self->{path};
  }

sub expires
  {
    my $self = shift;
    $self->{expires} = shift if @_;

    return $self->{expires};
  }

sub secure
  {
    my $self = shift;
    $self->{secure} = shift if @_;

    return $self->{secure};
  }

sub as_string
  {
    my $self = shift;

    return "";
  }

1;
