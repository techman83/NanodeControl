#!/bin/bash
#
# Setting intial gpio values
#gpio_pins=( 2, 3, 5, 7, 8, 10, 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 24, 26)
gpio_pins=(2, 3, 4, 7, 8, 9, 10, 11, 14, 15, 17, 18, 22, 23, 24, 25, 27)

function set_exports() {
    for i in "${gpio_pins[@]}"
    do
        /usr/local/bin/gpio export $i out
        /usr/local/bin/gpio -g write $i 0
        echo -n "Pin $i value: "
        /usr/local/bin/gpio -g read  $i
    done
}

case "$1" in
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

*)  echo "Usage: $0 {start|stop|restart}"

exit 1
;;




esac

exit 0
