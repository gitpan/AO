# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Servlet::BaseServlet;

use strict;

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
       name => undef,
       context => undef,
       load_on_startup => undef,
       loaded => undef,
       config => {},
       security_roles => {},
      }, $class;

    $self->init(@_);

    return $self;
  }

sub init
  {
  }

sub name
  {
    my $self = shift;
    $self->{name} = shift if @_;

    return $self->{name};
  }

sub context
  {
    my $self = shift;
    $self->{context} = shift if @_;

    return $self->{context};
  }

sub load_on_startup
  {
    my $self = shift;
    $self->{load_on_startup} = shift if @_;

    return $self->{load_on_startup};
  }

sub config
  {
    my $self = shift;

    return wantarray ?
      %{ $self->{config} } :
        $self->{config};
  }

sub init_parameter
  {
    my $self = shift;
    my $name = shift or
      return undef;

    if (@_)
      {
        $self->{config}->{$name} ||= {};
        $self->{config}->{$name}->{name} = $name,
        $self->{config}->{$name}->{value} = shift;
        $self->{config}->{$name}->{description} = shift;
      }

    return $self->{config}->{$name}->{value};
  }

sub init_parameter_names
  {
    my $self = shift;

    return keys %{ $self->{config} };
  }

sub load
  {
  }

sub is_loaded
  {
    my $self = shift;
    $self->{loaded} = shift if @_;

    return $self->{loaded};
  }

sub security_role
  {
    my $self = shift;
    my $name = shift or
      return undef;

    return $self->{security_roles}->{$name};
  }

sub add_security_role
  {
    my $self = shift;
    my $name = shift or
      return undef;
    my $link = shift or
      return undef;
    my $description = shift || '';

    $self->{security_roles}->{$name} =
      {
       link => $link,
       description => $description,
      };

    return 1;
  }

sub service
  {
  }

1;
