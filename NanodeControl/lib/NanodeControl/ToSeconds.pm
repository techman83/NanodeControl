package NanodeControl::ToSeconds;
use strict;
use base 'Exporter';

our @EXPORT = qw(to_seconds);

# quick hack to conver 1 day, 00:00:00 to seconds. If I find a better way I'll use it!

sub to_seconds {
  my ($time) = @_;
  $time =~ m{
     ^
     (?<days> \d+).
     (day|days).\s
     (?<hours> \d+).
     (?<minutes> \d+).
     (?<seconds> \d+)
     $
  }ix;

  my $seconds = $+{days} * 86400;
  $seconds = $seconds + ($+{hours} * 3600);
  $seconds = $seconds + ($+{minutes} * 60);
  $seconds = $seconds + $+{seconds};
  print "$seconds \n";
  return $seconds;
}
