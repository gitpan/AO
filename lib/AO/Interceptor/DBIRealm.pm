# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Interceptor::DBIRealm;

use AO::Interceptor::RealmBase ();
@ISA = qw(AO::Interceptor::RealmBase);

use strict;
use DBI ();

sub check_credentials
  {
    my $self = shift;
    my $credentials = shift;

    my $dbh =
      DBI->connect($self->connection_url(),
                   $self->connection_name(),
                   $self->connection_password(),
                   { RaiseError => 1}) or
                     die "Can't connect to authen db: $DBI::errstr\n";

    my $sth =
      $dbh->prepare(sprintf(q(SELECT %s FROM %s WHERE %s = %s),
                                    $self->user_cred_col(),
                                    $self->user_table(),
                                    $self->user_name_col(),
                                    $dbh->quote($credentials->{username})));
    my $rs = $dbh->selectall_arrayref($sth);

    $dbh->disconnect();

    return $rs && $rs->[0]->[0] && $rs->[0]->[0] eq $credentials->{password};
  }

sub user_in_role
  {
    my $self = shift;
    my $username = shift;
    my $roles = shift;

    my $dbh =
      DBI->connect($self->connection_url(),
                   $self->connection_name(),
                   $self->connection_password(),
                   { RaiseError => 1}) or
                     die "Can't connect to authen db: $DBI::errstr\n";

    my $sth =
      $dbh->prepare(sprintf(q(SELECT %s FROM %s WHERE %s = %s),
                                    $self->role_name_col(),
                                    $self->user_role_table(),
                                    $self->user_name_col(),
                                    $dbh->quote($username)));
    my $rs = $dbh->selectall_arrayref($sth);

    $dbh->disconnect();

    return undef unless $rs;

    for my $row (@$rs)
      {
        for my $role (@$roles)
          {
            return 1 if $row->[0] eq $role;
          }
      }

    return 0;
  }

sub connection_url
  {
    my $self = shift;
    $self->{connection_url} = shift if @_;

    return $self->{connection_url};
  }

sub connection_name
  {
    my $self = shift;
    $self->{connection_name} = shift if @_;

    return $self->{connection_name};
  }

sub connection_password
  {
    my $self = shift;
    $self->{connection_password} = shift if @_;

    return $self->{connection_password};
  }

sub user_table
  {
    my $self = shift;
    $self->{user_table} = shift if @_;

    return $self->{user_table};
  }

sub user_name_col
  {
    my $self = shift;
    $self->{user_name_col} = shift if @_;

    return $self->{user_name_col};
  }

sub user_cred_col
  {
    my $self = shift;
    $self->{user_cred_col} = shift if @_;

    return $self->{user_cred_col};
  }

sub user_role_table
  {
    my $self = shift;
    $self->{user_role_table} = shift if @_;

    return $self->{user_role_table};
  }

sub role_name_col
  {
    my $self = shift;
    $self->{role_name_col} = shift if @_;

    return $self->{role_name_col};
  }

1;
