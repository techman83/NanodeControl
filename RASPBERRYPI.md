If you are planning to use a pi, unless you want to drive one of the 8 way
boards with external power here:
http://arduino-info.wikispaces.com/ArduinoPower

You'll want to ensure all the pins are set to low during the boot process.
I've included a shell script which can be copied into init.d and then run:

update-rc.d set_pi_gpios.sh defaults

To set all usuable pins as outputs and low. Modify as you wish if you want
to exclude some pins.

This project uses the following shell library:
https://projects.drogon.net/raspberry-pi/wiringpi/download-and-install/

Mainly due to the perl libraries required root priviledges to be run, there
is probably a way for some kind of sudo for perl, but I've as yet to research
and the above project met my requirements.

It would be trivial to change the PIcontrol library if need be.
