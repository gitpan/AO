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

#    use XML::Parser ();
#    eval
#      {
#        my $xp = XML::Parser->new(Style => 'Debug');
#        $xp->parse($fh);
#      };
#    die $@ if $@;
#    return 1;

    my $xp = XML::XPath->new(ioref => $fh);

    eval {
    $self->process_webapp_config($xp, $ctx);
    $self->process_session_config($xp, $ctx);
    $self->process_login_config($xp, $ctx);
    $self->process_security_config($xp, $ctx);
    $self->process_servlet_config($xp, $ctx);
    }; warn $@ if $@;

    return 1;
  }

sub process_webapp_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;

    $ctx->display_name($xp->find('/web-app/display-name')->string_value());
    $ctx->description($xp->find('/web-app/description')->string_value());

    return 1;
  }

sub process_session_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;

    $ctx->session_timeout($xp->find('/web-app/session-config/session-timeout')->string_value());

    return 1;
  }

sub process_login_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;

    $ctx->auth_method($xp->find('/web-app/login-config/auth-method')->string_value());
    $ctx->realm_name($xp->find('/web-app/login-config/realm-name')->string_value());
    $ctx->form_login_page($xp->find('/web-app/login-config/form-login-config/form-login-page')->string_value());
    $ctx->form_error_page($xp->find('/web-app/login-config/form-login-config/form-error-page')->string_value());

    return 1;
  }

sub process_security_config
  {
    my $self = shift;
    my $xp = shift;
    my $ctx = shift;

    for my $n ($xp->find('/web-app/security-constraint')->get_nodelist())
      {
        my ($o, $p, $name, $description, @roles, @patterns, @methods);
        for $o ($xp->find('./auth-constraint/role-name', $n)->get_nodelist())
          {
            push @roles, $o->string_value();
          }

        for $o ($xp->find('./web-resource-collection', $n)->get_nodelist())
          {
            $name = $xp->find('./web-resource-name', $o)->string_value();
            $description = $xp->find('./description', $o)->string_value();

            for $p ($xp->find('./url-pattern', $o)->get_nodelist())
              {
                push @patterns, $p->string_value();
              }

            for $p ($xp->find('./http-method', $o)->get_nodelist())
              {
                push @methods, $p->string_value();
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

    my ($n, $o);
    for $n ($xp->find('/web-app/servlet')->get_nodelist())
      {
        my $class_name = $xp->find('./servlet-class', $n)->string_value();
        eval "require $class_name";
        die $@ if $@;

        my $srv = $class_name->new();
        $srv->context($ctx);
        $srv->name($xp->find('./servlet-name', $n)->string_value());
        $srv->load_on_startup($xp->find('./load-on-startup',
                                        $n)->string_value() || undef);

        for $o ($xp->find('./security-role-ref', $n)->get_nodelist())
          {
            $srv->add_security_role($xp->find('./role-name',
                                              $o)->string_value(),
                                    $xp->find('./role-link',
                                              $o)->string_value(),
                                    $xp->find('./description',
                                              $o)->string_value());
          }

        for $o ($xp->find('./init-param', $n)->get_nodelist())
          {
            $srv->init_parameter($xp->find('./param-name',
                                           $o)->string_value(),
                                 $xp->find('./param-value',
                                           $o)->string_value(),
                                 $xp->find('./description',
                                           $o)->string_value());
          }

        $ctx->add_servlet($srv);
      }

    return 1;
  }

1;
