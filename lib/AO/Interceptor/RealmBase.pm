# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::RealmBase;

use AO::Interceptor::RequestInterceptor ();
@ISA = qw(AO::Interceptor::RequestInterceptor);

use strict;

sub authenticate
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;
    my $ses = $req->session();

    return 0 unless $req->notes('ao.do_authen');

    my $username = $ses->{ao_username};
    my $password = $ses->{ao_password};
    return 401 unless defined($username) && defined($password);

    return 401 unless $self->check_credentials({username => $username,
                                                password => $password});

    $req->remote_user($username);
    $ses->principal({name => $username});
    $ses->{ao_username} = undef;
    $ses->{ao_password} = undef;

    return 0;
  }

sub authorize
  {
    my $self = shift;
    my $req = shift;
    my $res = shift;
    my $roles = shift;

    my $username = $req->remote_user() or
      return 401;

    return $self->user_in_role($username, $roles) ? 0 : 403;
  }

sub check_credentials { undef }
sub user_in_role { undef }

1;
