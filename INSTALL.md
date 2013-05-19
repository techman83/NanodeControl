RASPBERRY PI/Debian based Distro Installation:

Run ./install.pl

It should take care of all installation requirements and configuration.

Browse to http://host:port when finished.

NOTE: Installing on the Pi takes considerable time (DBD takes ~30mins to compile/test). Coffee/Beverage of choice recommended.

FOR MANUAL INSTALL:
These install instructions need fleshing out, however I'll include enough
to at least get you up and running.

This is desinged to run on a Raspberry Pi, but should be fine on anything
linux based.

You will need the following perl libraries

via cpanm - http://cpanmin.us

cpanm -S Dancer::Template::TemplateToolkit Template LWP::Simple \
Plack::Handler::FCGI Plack::Runner Plack::Handler::Starman JSON::Parse \
JSON DBD::SQLite YAML Dancer Config::Crontab

or apt-get. You will probably still need a few things via cpan, if you
come across any let me know and I will add it to the doco

apt-get install libyaml-perl libdancer-perl libtemplate-perl libplack-perl \
libfcgi-perl libjson-perl libdbd-sqlite3-perl 

you will definitely need the following from cpanm/cpan if using the apt method

cpanm -S Config::Crontab Plack::Handler::Starman

I use daemon tools to launch a plack instance, but to run once you have met the
deps you just need to set the path in the config.yml and run

perl bin/app.pl

I use daemon tools to launch the Plack instance (included the run script)

apt-get install daemontools daemontools-run

update the service/nanode/run file with your install path and then start it

svc -u /etc/service/nanode

The above runs the server to a socket which then can be proxied by nginx

apt-get install nginx

I've inclued a sample config for this as well.

browse to 

http://host 

and the frontend should be running!
