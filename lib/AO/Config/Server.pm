# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Config::Server;

use strict;
use AO::Context ();
use XML::XPath ();

sub new
  {
    my $type = shift;
    my $class = ref($type) || $type;

    my $self = bless
      {
      }, $class;

    return $self;
  }

sub read_config
  {
    my $self = shift;
    my $fh = shift;
    my $cm = shift;

    my $xp = XML::XPath->new(ioref => $fh);

    # XXX: really should be instantiating a context manager for each
    # /Server/ContextManager node, but how to pick one for any given
    # request? and how to use the right class to instantiate
    # (Apache::AO::ContextManager, for instance)?

    $self->process_logger_config($xp, $xp->findnodes('/Server'), $cm);

    my @set = $xp->findnodes('/Server/ContextManager');
    die "No /Server/ContextManager element found!\n" unless @set;

    for my $n (@set)
      {
        $self->process_logger_config($xp, $n, $cm);
        $self->process_interceptor_config($xp, $n, $cm);
        $self->process_context_config($xp, $n, $cm);
      }

    return 1;
  }

sub process_logger_config
  {
    my $self = shift;
    my $xp = shift;
    my $nl = shift;
    my $c = shift;

    my @set = $xp->findnodes('child::Logger', $nl);
    return 1 unless @set;

    for my $n (@set)
      {
        $self->add_logger($c, $n);
      }

    return 1;
  }

sub process_interceptor_config
  {
    my $self = shift;
    my $xp = shift;
    my $nl = shift;
    my $c = shift;

    my @set;
    push @set, $xp->findnodes("child::ContextInterceptor", $nl);
    push @set, $xp->findnodes("child::RequestInterceptor", $nl);

    for my $n (@set)
      {
        $self->add_interceptor($c, $n);
      }

    return 1;
  }

sub process_context_config
  {
    my $self = shift;
    my $xp = shift;
    my $nl = shift;
    my $cm = shift;
    my $l = $cm->logger();

    my @set = $xp->findnodes('child::Context', $nl);
    die "No Contexts defined!\n" unless @set;

    my ($n, $path, $c, $attr_n, $attr);
    for $n (@set)
      {
        $path = $n->getAttribute('path') or
          die "Context tag must have path attribute\n";

        $c = AO::Context->new();
        for $attr_n ($n->getAttributes())
          {
            $attr = $attr_n->getName();
             if ($c->can($attr))
              {
                $c->$attr($attr_n->getValue());
               }
            else
              {
                $l->debug("no accessor [$attr] found for context [$path]");
              }
          }

        # add the context before doing any further processing, so that
        # the context has a logger at least through the context
        # manager
        $cm->add_context($c);

        $self->process_logger_config($xp, $n, $c);
        $self->process_interceptor_config($xp, $n, $c);

        $l->info("added context $c for $path");
      }

    return 1;
  }

sub add_logger
  {
    my $self = shift;
    my $c = shift;
    my $n = shift;

    my $class_name = $n->getAttribute('class_name') or
      die "Interceptor tag must have class_name attribute\n";

    eval "require $class_name";
    die $@ if $@;

    my $l = $class_name->new();
    my $attr;
    for my $attr_n ($n->getAttributes())
      {
        $attr = $attr_n->getName();
        next if $attr eq 'class_name';

        if ($l->can($attr))
          {
            $l->$attr($attr_n);
          }
        else
          {
            $l->debug("no accessor [$attr] found for interceptor [$class_name]");
          }
      }

    $c->logger($l);

    # open logger ASAP. close in shutdown methods.
    $l->open();

    $l->info("added logger $l for $c");

    return 1;
  }

sub add_interceptor
  {
    my $self = shift;
    my $c = shift;
    my $n = shift;
    my $l = $c->logger();

    my $class_name = $n->getAttribute('class_name') or
      die "Interceptor tag must have class_name attribute\n";

    eval "require $class_name";
    die $@ if $@;

    my $i = $class_name->new();
    my $attr;
    for my $attr_n ($n->getAttributes())
      {
        $attr = $attr_n->getName();
        next if $attr eq 'class_name';

        if ($i->can($attr))
          {
            $i->$attr($attr_n->getValue());
          }
        else
          {
            $l->debug("no accessor [$attr] found for interceptor [$class_name]");
          }
      }

    if ($n->getLocalName() eq 'ContextInterceptor')
      {
        $c->add_context_interceptor($i);
      }
    else
      {
        $c->add_request_interceptor($i);
      }

    $l->info("added interceptor $i for $c");

    return 1;
  }

1;
