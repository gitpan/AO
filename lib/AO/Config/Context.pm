# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Config::Context;

use strict;
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
    my $ctx = shift;

    my $xp = XML::XPath->new(ioref => $fh);

    $self->process_webapp_config($xp, $ctx);
    $self->process_session_config($xp, $ctx);
    $self->process_login_config($xp, $ctx);
    $self->process_security_config($xp, $ctx);
    $self->process_servlet_config($xp, $ctx);

    return 1;
  }

sub process_webapp_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;
    my $n;

    $n = $xp->findnodes('/web-app/display-name');
    $ctx->display_name($n->string_value()) if $n;

    $n = $xp->findnodes('/web-app/description');
    $ctx->description($n->string_value()) if $n;

    return 1;
  }

sub process_session_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;

    my $n = $xp->findnodes('/web-app/session-config/session-timeout');
    $ctx->session_timeout($n->string_value()) if $n;

    return 1;
  }

sub process_login_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;
    my $n;

    $n = $xp->findnodes('/web-app/login-config/auth-method');
    $ctx->auth_method($n->string_value()) if $n;

    $n = $xp->findnodes('/web-app/login-config/realm-name');
    $ctx->realm_name($n->string_value()) if $n;

    $n = $xp->findnodes('/web-app/login-config/form-login-config/form-login-page');
    $ctx->form_login_page($n->string_value()) if $n;

    $n = $xp->findnodes('/web-app/login-config/form-login-config/form-error-page');
    $ctx->form_error_page($n->string_value()) if $n;

    return 1;
  }

sub process_security_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;
    my @set;

    @set = $xp->findnodes('/web-app/security-constraint');
    return 1 unless @set;

    for my $n (@set)
      {
        my (@set2, $o, $p, $name, $description, @roles, @patterns, @methods);

        @set2= $xp->findnodes('child::auth-constraint/role-name', $n);
        for $o (@set2)
          {
            push @roles, $o->string_value();
          }

        @set2 = $xp->findnodes('child::web-resource-collection', $n);
        for $o (@set2)
          {
            my ($n3, @set3);

            $n3 = $xp->findnodes('child::web-resource-name', $o);
            $name = $n->string_value() if $n3;

            $n3 = $xp->findnodes('child::description', $o);
            $description = $n->string_value if $n3;

            @set3= $xp->findnodes('child::auth-constraint/url-pattern', $n);
            for $n3 (@set3)
              {
                push @patterns, $n3->string_value();
              }

            @set3= $xp->findnodes('child::auth-constraint/http-method', $n);
            for $n3 (@set3)
              {
                push @methods, $n3->string_value();
              }

            $ctx->add_security_constraint($name, $description,
                                          \@patterns, \@methods, \@roles);
          }
      }

    return 1;
  }

sub process_servlet_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;
    my @set;

    @set = $xp->findnodes('/web-app/servlet');
    die "No Servlet elements found!\n" unless @set;

    my ($n, $o);
    for $n (@set)
      {
        my ($n2, @set2);

        $n2 = $xp->findnodes('child::servlet-class', $n);
        die "No servlet-class element found for servlet element!\n" unless
          $n2;

        my $class_name = $n2->string_value();
        eval "require $class_name";
        die $@ if $@;

        my $srv = $class_name->new();
        $srv->context($ctx);

        $n2 = $xp->findnodes('child::servlet-name', $n);
        die "No servlet-name element found for servlet element!\n" unless $n2;
        $srv->name($n2->string_value());

        $n2 = $xp->findnodes('child::load-on-startup', $n);
        $srv->load_on_startup($n2->string_value()) if $n2;

        @set2 = $xp->findnodes('child::security-role-ref', $n);
        for $o (@set2)
          {
            my ($n3, @arg);

            $n3 = $xp->findnodes('child::role-name', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $n3 = $xp->findnodes('child::role-link', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $n3 = $xp->findnodes('child::description', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $srv->add_security_role(@arg);
          }

        @set2 = $xp->findnodes('child::init-param', $n);
        for $o (@set2)
          {
            my ($n3, @arg);

            $n3 = $xp->findnodes('child::param-name', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $n3 = $xp->findnodes('child::param-value', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $n3 = $xp->findnodes('child::description', $o);
            push @arg, ($n3 ? $n3->string_value() : undef);

            $srv->init_parameter(@arg);
          }

        $ctx->add_servlet($srv);
      }

    return 1;
  }

1;
