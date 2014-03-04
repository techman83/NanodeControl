package NanodeControl::Schedule;
use strict;
use Dancer qw(:syntax);
use Config::Crontab;
use DateTime::Format::Strptime;
use base 'Exporter';
our $appdir = config->{appdir};

our @EXPORT = qw(set_cron);

sub set_cron {
  my ($schedule,$state) = @_;
  my $return;

  if ($state =~ /true/i) {
    $return->{result} = add_cron($schedule);
    $return->{state} = 'true';
  } elsif ($state =~/false/i) {
    $return->{result} = remove_cron($schedule);
    $return->{state} = '';
  }
  return $return;
}

sub add_cron {
  my ($schedule) = @_;
  debug("Enabling Cron: ", $schedule);

  # Convert Date
  my $parse = DateTime::Format::Strptime->new(
    pattern => '%H:%M:%S',
    on_error => 'croak',
  );

  my $starttime = $parse->parse_datetime($schedule->{starttime});

  # Convert Days
  my $dows = join(",", @{$schedule->{dow}});

  # Read cron
  my $ct = new Config::Crontab; $ct->read;
  
  # Write new entry
  my $event = new Config::Crontab::Event( -minute  => $starttime->minute(),
                                          -hour    => $starttime->hour(),
                                          -dow     => $dows,
                                          -command => "$appdir/bin/runschedule.pl $schedule->{apikey}");
  my $block = new Config::Crontab::Block;
  $block->last($event);
  $ct->last($block);
  $ct->write;
  debug("Cron Enable: ", $ct);

  # Check it got written
  $ct->read;
  my @event = $ct->select( -type       => 'event',
                           -command_re => "(?:$schedule->{apikey})");
  debug("Event: ", @event);

  if (defined $event[0]->{_active}) {
    debug("Cron: Success");
    return "success";
  } else {
    debug("Cron: Failure");
    return "failure";
  }
}

sub remove_cron {
  my ($schedule) = @_;
  debug("Disabling Cron: ", $schedule);
  my $ct = new Config::Crontab; $ct->read;
  my @event = $ct->select( -type       => 'event',
                           -command_re => "(?:$schedule->{apikey})");
  debug("Event: ", @event);
  my $block = $ct->block($event[0]);
  debug("Block: ", $block);
  $ct->remove($block);
  $ct->write;
  debug("Cron Disable: ", $ct);
  
  # Check it got written
  $ct->read;
  @event = $ct->select( -type       => 'event',
                           -command_re => "(?:$schedule->{apikey})");
  debug("Event: ", @event);

  unless (defined $event[0]->{_active}) {
    debug("Cron: Success");
    return "success";
  } else {
    debug("Cron: Failure");
    return "failure";
  }
}

sub get_cron {
  my $ct = new Config::Crontab;
  $ct->read;
  debug("Cron: ", $ct);
  return $ct;
}

__END__
{'days' => ['1','5','7'],'duration' => '0 Day, 00:05:00','name' => 'Test','starttime' => '16:24','stations' => ['10001'],'successpop' => 1,'url' => '/addschedule'}{'message' => 'Schedule added and enabled successfully.','title' => 'Success'}
