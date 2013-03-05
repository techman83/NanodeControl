package NanodeControl::Schedule;
use strict;
use Dancer qw(:syntax);
use Config::Crontab;
use NanodeControl::DBsqlite;
use base 'Exporter';
my $appdir = config->{appdir};

our @EXPORT = qw(add_cron remove_cron get_cron);

sub add_cron {
  my ($scheduleid) = @_;
  debug("Enabling Cron: ", $scheduleid);
  my $schedule = get_schedule($scheduleid);
  my $ct = new Config::Crontab; $ct->read;
  my $event = new Config::Crontab::Event( -minute  => $schedule->{minutes},
                                          -hour    => $schedule->{hours},
                                          -dow     => $schedule->{days},
                                          -command => "$appdir/bin/runschedule.pl --schedule=$schedule->{id}");
  my $block = new Config::Crontab::Block;
  $block->last($event);
  $ct->last($block);
  $ct->write;
  debug("Cron Enable: ", $ct);
  return;
}

sub remove_cron {
  my ($scheduleid) = @_;
  debug("Disabling Cron: ", $scheduleid);
  my $ct = new Config::Crontab; $ct->read;
  my @event = $ct->select( -type       => 'event',
                           -command_re => "(?:$scheduleid)");
  debug("Event: ", @event);
  my $block = $ct->block(@event[0]);
  debug("Block: ", $block);
  $ct->remove($block);
  $ct->write;
  debug("Cron Disable: ", $ct);
  return;
}

sub get_cron {
  my $ct = new Config::Crontab;
  $ct->read;
  debug("Cron: ", $ct);
  return $ct;
}

__END__
{'days' => ['1','5','7'],'duration' => '0 Day, 00:05:00','name' => 'Test','starttime' => '16:24','stations' => ['10001'],'successpop' => 1,'url' => '/addschedule'}{'message' => 'Schedule added and enabled successfully.','title' => 'Success'}
