# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Servlet::Mason;

use AO::Servlet::BaseServlet;
@ISA = qw(AO::Servlet::BaseServlet);

use strict;
use File::Spec ();
use HTML::Mason ();
use HTML::Mason::ApacheHandler (args_method => 'mod_perl');

sub load
  {
    my $self = shift;

    return 1 if $self->{loaded};

    my $ctx = $self->context();

    my $init_params = {};
    for my $name ($self->init_parameter_names())
      {
        my ($comp, $key) = split(/\./, $name, 2);
        $init_params->{$comp} ||= {};
        $init_params->{$comp}->{$key} = $self->init_parameter($name);
      }

    $self->{parser} = 
      HTML::Mason::Parser->new(in_package => 'AO::Servlet::Mason::Commands',
                               allow_globals => [qw($ses)],
                               %{ $init_params->{parser} });

    $self->{interp} =
      HTML::Mason::Interp->new(parser => $self->{parser},
                               comp_root => $ctx->absolute_path(),
                               data_dir =>
                               File::Spec->catdir($ctx->absolute_path(),
                                                  'WEB-INF', 'var'),
                               %{ $init_params->{interp} });

    $self->{handler} =
      HTML::Mason::ApacheHandler->new(interp => $self->{interp},
                                      %{ $init_params->{handler} });

    $self->{loaded} = 1;

    return 1;
  }

sub service
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;

    my $ses = $req->session();
    if ($ses)
      {
        $AO::Servlet::Mason::Commands::ses = $ses;
      }

    my $rc = $self->{handler}->handle_request($req);

    if ($ses)
      {
        undef $AO::Servlet::Mason::Commands::ses;
      }

    return $rc;
  }

1;
