package NanodeControl::PiInfo;
use IPC::System::Simple qw(capture);
use Dancer ':syntax';
use base 'Exporter';
our @EXPORT    = qw(get_pi_info);

my $vcgencmd = config->{vcgencmd};

sub get_pi_info {
  my $data;

  # Get clock speeds
  my @clocks = qw(arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi);

  foreach my $clock (@clocks) {
    $data->{clocks}{$clock} = measure_clock($clock);
  }

  # Get voltages
  my @volts = qw(core sdram_c sdram_i sdram_p);

  foreach my $volt (@volts) {
    $data->{volts}{$volt} = measure_volts($volt);
  }

  # Get temp
  my @temps = qw(core);

  foreach my $temp (@temps) {
    $data->{temps}{$temp} = measure_temp($temp);
  }
  debug($data);

  return $data;
}

sub measure_clock {
  my ($component) = @_;
  my $clock = capture("$vcgencmd measure_clock $component");
  $clock =~ m/.*\=(\d+)/;
  $clock = $1/1000000;
  return $clock;
}

sub measure_volts {
  my ($component) = @_;
  my $volts = capture("$vcgencmd measure_volts $component");
  $volts =~ m/.*\=(\d+.\d+)/;
  return $1;
}

sub measure_temp {
  my $temp = capture("$vcgencmd measure_temp");
  $temp =~ m/.*\=(\d+.\d+)/;
  return $1;
}

1
