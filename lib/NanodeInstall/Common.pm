package NanodeInstall::Common;
use base 'Exporter';
our @EXPORT = qw(Prompt install_modules wiringpi aptget);
our $modules = "Dancer::Template::TemplateToolkit Template LWP::Simple Plack::Handler::FCGI Plack::Runner JSON::Parse JSON DBD::SQLite YAML Dancer Config::Crontab Text::CSV::Slurp Archive::Zip Plack::Handler::Starman File::Slurp IPC::System::Simple File::MimeInfo::Magic";

sub Prompt { # inspired from here: http://alvinalexander.com/perl/edu/articles/pl010005
  my ($question,$default) = @_;
  if ($default) {
    print $question, "[", $default, "]: ";
  } else {
    print $question, ": ";
  }
  
  $| = 1;               # flush
  $_ = <STDIN>;         # get input
  
  if ($_ =~ m/^y|^n/i) {
    $_ = lc $_;
  }

  chomp;
  if ("$default") {
    return $_ ? $_ : $default;    # return $_ if it has a value
  } else {
    return $_;
  }
}

sub install_modules {
  my ($self) = @_;
  system("curl -L http://cpanmin.us | perl - App::cpanminus");

  unless ($self->{test_perl} eq 'y') {
    system("cpanm -nS $modules");
  } else {
    system("cpanm -S $modules");
  }
  return;
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

  open (SCRIPT, '>>/tmp/wiringpi.sh');
  print SCRIPT $script;
  close (SCRIPT); 
  system("/bin/sh /tmp/wiringpi.sh");

  if ($self->{pipins} eq 'y') {
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
  }

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

  return $self;
}

1;
