# -*- Mode: Perl; indent-tabs-mode: nil -*-

package AO::Logger::Syslog;

use AO::Logger::BaseLogger ();
@ISA = qw(AO::Logger::BaseLogger);

use strict;
use Sys::Syslog ();

# override superclass bung
use constant SYSLOG_DEFAULT_LOG_LEVEL => 'error';
use constant SYSLOG_DEFAULT_FACILITY => 'local5';

sub init
  {
    my $self = shift;

    $self->{log_level} = SYSLOG_DEFAULT_LOG_LEVEL;
    $self->{facility} = SYSLOG_DEFAULT_FACILITY;

    return 1;
  }

sub open
  {
    my $self = shift;
    warn "opening log with facility $self->{facility} and level $self->{log_level}\n";
    Sys::Syslog::openlog('ao', 'ndelay,pid', $self->{facility});

    $self->crit('woah!');
  }

sub close
  {
    my $self = shift;
    Sys::Syslog::closelog();
  }

sub emerg
  {
    my $self = shift;
    Sys::Syslog::syslog('emerg', @_);
  }

sub alert
  {
    my $self = shift;
    Sys::Syslog::syslog('alert', @_);
  }

sub crit
  {
    my $self = shift;
    Sys::Syslog::syslog('crit', @_);
  }

sub err
  {
    my $self = shift;
    Sys::Syslog::syslog('err', @_);
  }

sub warn
  {
    my $self = shift;
    Sys::Syslog::syslog('warning', @_);
  }

sub notice
  {
    my $self = shift;
    Sys::Syslog::syslog('notice', @_);
  }

sub info
  {
    my $self = shift;
    Sys::Syslog::syslog('info', @_);
  }

sub debug
  {
    my $self = shift;
    Sys::Syslog::syslog('debug', @_);
  }

sub log_level
  {
    my $self = shift;
    if (@_)
      {
        $self->{log_level} = shift;
        Sys::Syslog::setlogmask($self->{log_level});
      }

    return $self->{log_level};
  }

sub facility
  {
    my $self = shift;
    if (@_)
      {
        $self->{facility} = shift;
        $self->close();
        $self->open();
      }

    return $self->{facility};
  }

1;
