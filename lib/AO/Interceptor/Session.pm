# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::Session;

use AO::Interceptor::RequestInterceptor ();
@ISA = qw(AO::Interceptor::RequestInterceptor);

use strict;
use AO::Cookie ();

use constant SESSION_TAG => 'AO_sessionID';

sub request_map
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;

    my $sid;
    if (my $cookiejar = $req->cookies())
      {
        if (my $cookie = $cookiejar->{SESSION_TAG()})
          {
            $sid = $cookie->value();
          }
      }

    my $ctx = $req->context();
    my $sm = $ctx->session_manager();

    my $ses = $sm->find_session($sid) if $sid;
    unless ($ses)
      {
        $ses = $sm->get_new_session();
        $res->add_cookie(AO::Cookie->new(name => SESSION_TAG,
                                         value => $ses->id(),
                                         path => $ctx->path()));
      }

    $req->session($ses);

    return 0;
  }

sub post_service
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;

    my $ses = $req->session();
    if ($ses)
      {
        my $sm = $req->context()->session_manager();
        $sm->release($ses);
      }

    return 0;
  }

1;
