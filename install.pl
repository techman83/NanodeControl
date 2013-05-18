#!/usr/bin/perl
use strict;
use Data::Dumper;

if ( $> > 0 ) {
  print "This installer must be run as root \n";
  print "     sudo $0 \n";
#  exit 1; 
}

my ($self) = {};
bless $self;

$self->{gpio_init} = "set_pi_gpios.sh";

# Gather install information
$self->{pi} = &Prompt("Are you installing on a Pi? (y/n) ","y");
lc($self->{pi});

if ( $self->{pi} eq "n" ) {
  $self->{distro} = &Prompt("Is this distro debian/ubuntu based? (y/n) ", "y");
  lc($self->{distro});
} else {
  $self->{wiringpi} = &Prompt("Would you like me to install WiringPi (will include git-core)? (y/n) ", "y");
  lc($self->{wiringpi});
  $self->{pipins} = &Prompt("Would you like the Pi Pins configured low on boot? (y/n) ", "y");  
  lc($self->{pipins});
}

if ( $self->{distro} eq "y" || $self->{pi} eq "y" ) {
  my $self->{nginx} = &Prompt("Would you like me to attempt to install/configure nginx? (y/n)", "y");
  lc($self->{nginx});
  if ( $self->{nginx} eq "y" ) {
    my $self->{port} &Prompt("Set webserver port to 8080? (change to 80 if you are sure no other webserver is running", "8080");
  }
  my $self->{dtools} = &Prompt("Would you like me to attempt to install/configure daemontools (runs NanodeControl service)? (y/n)", "y");
  lc($self->{dtools});
}

my $self->{installpath} = &Prompt("Install path", "/usr/local/NanodeControl");

# Run install
unless (-d $self->{installpath}) {
  print Dumper($self);
  nanode($self);

  if ($self->{nginx} eq "y") {
    nginx($self);
  }
  
  if ($self->{dtools} eq "y") {
    daemontools($self);
  }
  
  if ($self->{pi} eq "y") {
    wiringpi($self);
  }

} else {
  print "Possibly already installed at $self->{instalpath} \n";
  exit;
}


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
    print "$_ \n";
    return $_;
  }
}

sub wiringpi { # Need to ponder a better method, this doesn't account for failures.
  my ($self) = @_;
  aptget($self,"git-core");

  my $script =<<EOF;
#!/bin/sh
cd /tmp/
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build
EOF

  open (SCRIPT, '>>/wiringpi.sh');
  print SCRIPT $script;
  close (SCRIPT); 
  system("/bin/sh /tmp/wiringpi.sh");

  my $gpioconf = <<EOF;
#!/bin/bash
# Setting intial gpio values
gpio_pins=(2, 3, 4, 7, 8, 9, 10, 11, 14, 15, 17, 18, 22, 23, 24, 25, 27)

function set_exports() {
    for i in "\${gpio_pins[@]}"
    do
        /usr/local/bin/gpio export \$i out
        /usr/local/bin/gpio -g write \$i 0
        echo -n "Pin \$i value: "
        /usr/local/bin/gpio -g read  \$i
    done
}

case "\$1" in
        start)
            echo "Exporting gpios and setting intial values to zero..."
            set_exports
            echo -n "Done"
            echo "."
            ;;
        stop)
            echo -n "Clearing Exports."
            /usr/local/bin/gpio unexportall
            echo -n "Done"
            echo "."
            ;;
        restart)
            echo "Resetting gpios:"
            /usr/local/bin/gpio unexportall
            set_exports
            echo -n "Done"
            echo "."
            ;;

*)  echo "Usage: \$0 {start|stop|restart}"

exit 1
;;

esac

exit 0
EOF

  open (SCRIPT, ">>/etc/init.d/$self->{gpio_init}");
  print SCRIPT $gpioconf;
  close (SCRIPT); 
  my $mode = 0775;   
  chmod $mode, "/etc/init.d/$self->{gpio_init}"; 
  system("/usr/sbin/update-rc.d $self->{gpio_init} defaults");
  system("/etc/init.d/$self->{gpio_init} start");

  return;
}

sub nginx {
  my ($self) = @_;

  aptget($self,"nginx");

  my $nginxconf = <<EOF;
upstream backendurl {
    server unix:/tmp/nanode.sock;
}

server {
  listen       $self->{port};

  access_log $self->{installpath}/logs/access.log;
  error_log  $self->{installpath}/logs/error.log info;

  root $self->{installpath}/public;
  location / {
    try_files \$uri \@proxy;
    access_log off;
    expires max;
  }

  location \@proxy {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass       http://backendurl;
  }

}
EOF

  open (NGINXCONF, '>>/etc/nginx/sites-available/nanodecontrol');
  print NGINXCONF $nginxconf;
  close (NGINXCONF); 
  symlink('/etc/nginx/sites-available/nanodecontrol','/etc/nginx/sites-enabled/nanodecontrol') or die print "$!\n";
  if ($self->{port} == 80) {
    unlink('/etc/nginx/sites-enabled/default');
  }
  system('/etc/init.d/nginx restart');
  return;
}

sub daemontools {
  my ($self) = @_;

  aptget($self,"daemontools daemontools-run");

  my $dtconf = <<EOF;
#!/bin/sh

  path=$self->{installpath}

# if your application is not installed in @INC path:
export PERL5LIB="\$path/lib"

exec 2>&1 \
su www-data -c "/usr/local/bin/plackup -E production -s Starman --workers=2 -l /tmp/nanode.sock -a \$path/bin/app.pl"
EOF

  mkdir "/etc/service/nanode";
  open (DTCONF, '>>/etc/service/nanode/run');
  print DTCONF $dtconf;
  close (DTCONF); 

  system("svc -u /etc/service/nanode");
  
  return;
}

sub aptget  { # Need to ponder a better method, this doesn't account for failures.
  my ($self,$packages) = @_;

  unless (defined $self->{apt_updated}) {
    print "Updating apt....";
    system("apt-get update");
    print "Done.\n";
    $self->{apt_updated} = 1;
  }

  print "Installing: $packages....";
  system("apt-get -y install $packages");
  print "Done \n";

  return;
}

sub nanode {
  my ($self) = @_;
  
  # I wonder if there is a better way to do these without a module.
  system("cp -R NanodeControl $self->{installpath}"); 
  system("chown -R www-data:www-data $self->{installpath}/logs"); 
  system("chown -R www-data:www-data $self->{installpath}/db"); 

  return;
}
