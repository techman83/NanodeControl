#!/usr/bin/perl

if ( $> > 0 ) {
  print "This installer must be run as root \n";
  print "     sudo $0 \n";
#  exit 1; 
}

my $pi = &Prompt("Are you installing on a Pi? (y/n) ","y");
lc($pi);

if ( $pi eq "n" ) {
  my $distro = &Prompt("Is this distro debian/ubuntu based? (y/n) ", "y");
  lc($distro);
} else {
  my $wiringpi = &Prompt("Would you like me to install WiringPi (will include git-core)? (y/n) ", "y");
  lc($wiringpi);
  my $pipins = &Prompt("Would you like the Pi Pins configured low on boot? (y/n) ", "y");  
  lc($pipins);
}

if ( $distro eq "y" || $pi eq "y" ) {
  my $nginx = &Prompt("Would you like me to attempt to install/configure nginx? (y/n)", "y");
  lc($nginx);
  if ( $nginx eq "y" ) {
    my $port &Prompt("Set webserver port to 8080? (change to 80 if you are sure no other webserver is running", "8080");
  }
  my $dtools = &Prompt("Would you like me to attempt to install/configure daemontools (runs NanodeControl service)? (y/n)", "y");
  lc($dtools);
}

my $installpath = &Prompt("Install path", "/usr/local/NanodeControl");

sub Prompt { # inspired from here: http://alvinalexander.com/perl/edu/articles/pl010005
  my ($question,$default) = @_;
  if ($default) {
    print $question, "[", $default, "]: ";
  } else {
    print $question, ": ";
  }
  
  $| = 1;               # flush
  $_ = <STDIN>;         # get input

  chomp;
  if ("$default") {
    return $_ ? $_ : $default;    # return $_ if it has a value
  } else {
    return $_;
  }
}

sub wiringpi {
#  apt-get install git-core
#  cd /tmp/
#  git clone git://git.drogon.net/wiringPi
#  cd wiringPi
#  ./build
}

sub nginx {
#  apt-get install nginx
}

sub daemontools {

}

sub install {

}
