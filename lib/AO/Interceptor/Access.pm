# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::Access;

use AO::Interceptor::ContextInterceptor ();
use AO::Interceptor::RequestInterceptor ();
@ISA = qw(AO::Interceptor::ContextInterceptor AO::Interceptor::RequestInterceptor);

use strict;

sub context_init
  {
    my $self = shift;
    my $ctx = shift;

    my $auth_method = $ctx->auth_method() or
      return 0;

    if ($auth_method eq 'FORM')
      {
        # fix up form page paths to include the context path. if the
        # paths are missing leading slashes, add them (relative paths
        # don't make sense here)

        my $ctx_path = $ctx->path();
        my $form_login_page = $ctx->form_login_page() or
          die "No form login page!\n";
        my $form_error_page = $ctx->form_error_page() or
          die "No form error page!\n";

        unless ($form_login_page =~ m|^$ctx_path|)
          {
            $form_login_page =~ s|^/||;
            $ctx->form_login_page(join('/', $ctx->path(), $form_login_page));
          }

        unless ($form_error_page =~ m|^$ctx_path|)
          {
            $form_error_page =~ s|^/||;
            $ctx->form_error_page(join('/', $ctx->path(), $form_error_page));
          }
      }
    else
      {
        die "Auth method [$auth_method] not supported for ctx ", $ctx->path(), "\n";
      }

    return 0;
  }

sub request_map
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;
    my $ctx = $req->context();
    my $ses = $req->session();
    my $uri = $req->uri();
    my $method = $req->method();
    my $srv_path = $req->servlet_path();

    if ($srv_path ne '/ao_security_check')
      {
        # don't check login or error page
        return 0 if ($uri eq $ctx->form_login_page() ||
                     $uri eq $ctx->form_error_page());

        # if the request uri matches a security pattern (and the request
        # method matches that security constraint's method list), the
        # request needs must be authenticated. if a matching security
        # pattern does not have a method list, all methods must be
        # secured.

        my $match_ok = 0;
        my $method_ok = 0;
        for my $pat ($ctx->security_patterns())
          {
            if ($srv_path =~ /$pat/)
              {
                my $constraint = $ctx->security_constraint($pat);
                my $methods = $constraint->{methods};
                if (@$methods)
                  {
                    for my $m (@$methods)
                      {
                        $method_ok++ && last if ($m eq $method);
                      }
                    return 0 unless $method_ok;
                  }
                $match_ok++;
                $req->required_roles($constraint->{roles});
                last;
              }
          }
        return 0 unless $match_ok;

        # already authenticated
        return 0 if $req->user_principal();

        # tell the security interceptor that authentication is
        # necessary. save the original location in case authentication
        # fails.

        $req->notes('ao.do_authen' => 1);
        $ses->{original_location} = $uri;

        return 0;
      }

    else
      {
        # if login form was submitted, set up security check (some
        # security interceptor will look for the session attributes and
        # perform the credential check.

        if ($ctx->auth_method() eq 'FORM')
          {
            $ses->{ao_username} = $req->param('ao_username');
            $ses->{ao_password }= $req->param('ao_password');
          }
        else
          {
            # XXX: unimplemented methods
            die "unimplemented method [", $ctx->auth_method(), "]\n";
          }

        my $loc = $ses->{original_location};
        delete $ses->{original_location};

        return $req->redirect($loc);
      }
  }

1;
