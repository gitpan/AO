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

    my $sql = sprintf(q(SELECT %s FROM %s WHERE %s = %s),
                      $self->user_cred_col(),
                      $self->user_table(),
                      $self->user_name_col(),
                      $dbh->quote($credentials->{username}));
    my $passwd = $dbh->selectrow_array($sql);

    $dbh->disconnect();

    return $passwd && $passwd eq $credentials->{password};
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

    my $sql =sprintf(q(SELECT %s.%s FROM %s, %s, %s WHERE %s.%s = %s AND %s.%s=%s.%s AND %s.%s=%s.%s),
                     $self->role_table(),
                     $self->role_name_col(),
                     $self->user_table(),
                     $self->role_table(),
                     $self->user_role_table(),
                     $self->user_table(),
                     $self->user_name_col(),
                     $dbh->quote($username),
                     $self->user_table(),
                     $self->user_id_col(),
                     $self->user_role_table(),
                     $self->user_role_user_id_col(),
                     $self->user_role_table(),
                     $self->user_role_role_id_col(),
                     $self->role_table(),
                     $self->role_id_col(),
                    );
    my $dbroles = $dbh->selectcol_arrayref($sql);

    $dbh->disconnect();

    for my $dbrole (@$dbroles)
      {
        for my $role (@$roles)
          {
            return 1 if $dbrole eq $role;
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

sub user_id_col
  {
    my $self = shift;
    $self->{user_id_col} = shift if @_;

    return $self->{user_id_col};
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

sub role_table
  {
    my $self = shift;
    $self->{role_table} = shift if @_;

    return $self->{role_table};
  }

sub role_id_col
  {
    my $self = shift;
    $self->{role_id_col} = shift if @_;

    return $self->{role_id_col};
  }

sub role_name_col
  {
    my $self = shift;
    $self->{role_name_col} = shift if @_;

    return $self->{role_name_col};
  }

sub user_role_table
  {
    my $self = shift;
    $self->{user_role_table} = shift if @_;

    return $self->{user_role_table};
  }

sub user_role_user_id_col
  {
    my $self = shift;
    $self->{user_role_user_id_col} = shift if @_;

    return $self->{user_role_user_id_col};
  }

sub user_role_role_id_col
  {
    my $self = shift;
    $self->{user_role_role_id_col} = shift if @_;

    return $self->{user_role_role_id_col};
  }

1;
