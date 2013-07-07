#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
use lib "$Bin/NanodeControl/lib";
use lib "$Bin/lib";
use NanodeInstall::Common;
use File::Path qw(remove_tree);
#use Data::Dumper;

if ( $> > 0 ) {
  print "This installer must be run as root \n";
  print "     sudo $0 \n";
  exit 1; 
}

my ($self) = {};
bless $self;

$self->{gpio_init} = "set_pi_gpios.sh";

# Gather install information
$self->{pi} = &Prompt("Are you upgrading on a Pi? (y/n) ","y");

if ( $self->{pi} eq "n" ) {
  $self->{distro} = &Prompt("Is this distro debian/ubuntu based? (y/n) ", "y");
  $self->{wiringpi} = 'n';
} else {
  $self->{wiringpi} = &Prompt("Would you like me to upgrade WiringPi (will include git-core)? (y/n) ", "y");
  $self->{pipins} = 'n';  
}

$self->{installpath} = &Prompt("Install path", "/usr/local/NanodeControl");

$self->{perl} = &Prompt("Upgrade cpanm + required perl modules? (y/n)", "y");

if ($self->{perl} eq "y") {
  $self->{test_perl} = &Prompt("Enable cpanm tests (testing takes a _long time_ on the pi) (y/n)", "n");
}

#print Dumper($self);

# Run upgrade 
if (-d $self->{installpath}) {
  if ($self->{perl} eq "y") {
    install_modules($self);
  }

  nanode($self);

  if ($self->{wiringpi} eq "y") {
    wiringpi($self);
  }

} else {
  print "Not installed at $self->{instalpath}, set correct path or run install if not currently installed. \n";
  exit;
}

sub nanode {
  use NanodeControl::ImportExport;
  my ($self) = @_;
  print "Backing up config...";
  my $data = nanode_export("all",$self->{installpath}); 
  print "Done \n";
  
  if (-e "$self->{installpath}/tmp/nanodecontrol.pid") {
    print "Stopping Nanode Control...";
    system("/etc/init.d/nanodecontrol stop");
    print "Done \n";
  }
  remove_tree( $self->{installpath}, {keep_root => 1} ); 

  # I wonder if there is a better way to do these without a module.
  print "Copying files...";
  system("cp -R NanodeControl/* $self->{installpath}"); 
  print "Done\nImporting Data...";
  my $import->{filename} = $data->{data};
  $import->{type} = 'application/zip';
  $import->{temp} = $data->{data};
  nanode_import($import,$self->{installpath});
  print "Done \nFixing perms...";
  system("chown -R www-data:www-data $self->{installpath}/logs"); 
  system("chown -R www-data:www-data $self->{installpath}/db"); 
  system("chown -R www-data:www-data $self->{installpath}/tmp"); 
  print "Done\nStarting Nanode Control...";
  system("/etc/init.d/nanodecontrol start"); 
  print "Done\nInstallation Complete!\n";
  return;
}
