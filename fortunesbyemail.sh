#!/bin/bash
#
################################
#
# fortunesbyemail.sh
# -----------------------------
#
# template version .1
# ver:	3		date:
################################

################################
# includes

################################
# variables
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/var/local/sbin:/sbin:/var/local/sbin:/sbin
PDIR=${0%`basename $0`}
LCK_FILE=$PDIR/`basename $0`.lck
myVer=".6"
VTMP="/tmp"
tempNAME="$VTMP/fortune4today.tmp"

# set these in the .conf file
#mailSubject="Your fortune for today: `date +'%A %B %e %Y'`"
#sendTO=""
#fortunelist="firefly community"

################################
# functions

#
customHeader() {
	if [ -f "${PDIR}/customHeader.sh" ]; then
		source ${PDIR}/customHeader.sh
	fi
}

readConf() {
	if [ -f "${PDIR}/fortunesbyemail.conf" ]; then
		source ${PDIR}/fortunesbyemail.conf
	else
		echo "No conf file found. Exiting..."
		exit
	fi
}

checkStatus() {
	# if this function sees this script already running, then exit.
	# checks for a stuck process.
	if [ -f "${LCK_FILE}" ]; then

	# The file exists so read the PID to see if it is still running
	MYPID=`head -n 1 "${LCK_FILE}"`

	TEST_RUNNING=`ps -p ${MYPID} | grep ${MYPID}`

	if [ -z "${TEST_RUNNING}" ]; then
		# The process is not running
		# Echo current PID into lock file
		echo $$ > "${LCK_FILE}"
	else
		#echo "`basename $0` is already running [${MYPID}]"
		exit 0
	fi
	else
		echo $$ > "${LCK_FILE}"
	fi
}

cleanup() {
	if [ -e $tempNAME ]
	then 
		rm $tempNAME
		rm -f $LCK_FILE
	fi
}

whichFortune() {
	if [ `command -v fortune` ]
	then
	    {
	    fortunePATH="`command -v fortune`"
	    }
	else
	    {
	    echo "fortune not found -- exiting"
	    echo "is fortune installed and in the PATH?"
	    exit 1
	    }
	fi
}

checkMailx() {
	if [ -e /usr/bin/mailx ] && [ "$sendTO" != "" ]
	then
	    {
	    #echo "found mailx"
	    mailxPATH="`which mailx`"
	    }
	else {
	    echo "mailx not found -- exiting"
	    echo "You may try sudo apt-get install mailutils"
	    echo "and check that sendTO is set"
	    exit 1
	    }
	fi
}

mailfortune() {
for i in "${sendTO[@]}"
do
        cat $tempNAME | $mailxPATH -s "$mailSubject" $i
done
}

createfortune() {
	for i in $fortunelist
	do
		echo "Here is your $i fortune:" >> $tempNAME
		$fortunePATH $i >> $tempNAME
		echo -e "\n" >> $tempNAME
	done
	echo "***************************************************" >> $tempNAME
	echo "It is day `date +%j` in week `date +%U` of the year `date +%G`." >> $tempNAME
	echo "End of your fortunes for today. Enjoy." >> $tempNAME
	echo "Now go and have a good day." >> $tempNAME
       echo "This is script version $myVer." >> $tempNAME
    }

###############################
# WORK WORK WORK

readConf
checkStatus
whichFortune
case $1 in
        '-t')
				#echo "testing"
				customHeader
				createfortune
				cat "$tempNAME"
				;;

		'-m')
			#	echo "mailfortune"
                checkMailx
                customHeader
                createfortune
                mailfortune
				;;

		*)
				echo "Usage: $0 { -t | -m }"
				exit 1
				;;
esac

cleanup

### Always exit with 0 status
exit 0
