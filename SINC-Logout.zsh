#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2022.01.05.
# Version 2.00
# Organization: Stony Brook University/DoIT
#
# In order to get a script to run at logout on macOS we have to run it as a
# user LaunchAgent. The script runs and goes to sleep until it detects one of the
# following: SIGINT SIGHUP SIGTERM SIGQUIT SIGABRT.
#
# At which point the script kicks in and gets user logged in, the home directory,
# and the computer name. A home Directory touch is done so the script that removes
# home directories and users after 3-4 days can better calculate the time, and then
# it turns the sound down. Finally the user and computer is curled up to a server
# which proceses and tracks users.
#
# There is a possibility that this will not work when the computer is abruptly
# rebooted such as our setup to kick users off who hog lab computers. Needs to be tested.

onLogout() {
	/bin/echo "" >> ${myLog}
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Starting ${me}, v${myVers}" >> ${myLog}

		# Get user, home directory and computer name.
	myUser=$( /usr/bin/defaults read /Library/Preferences/com.apple.loginwindow lastUserName )
	myHome=$( /usr/bin/dscl . read /Users/${myUser} home 2>/dev/null | /usr/bin/awk '{print $2}' )
	compName=$( /usr/sbin/networksetup -getcomputername )
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: User: ${myUser}" >> ${myLog}
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Home: ${myHome}" >> ${myLog}
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Computer: ${compName}" >> ${myLog}

		# Touch the home directory as a time stamp so the removal script will better assess.
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Touching ${myHome}" >> ${myLog}
	/usr/bin/touch ${myHome}
		 # Set the volume to zero.
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Setting volume to zero" >> ${myLog}
	/usr/bin/osascript -e "set volume 0"

		# SINC Logoff Tracker. Curl the data up to the web site.   !! ONLY WORKS FROM SINC NETWORK !!
	myResult=$(/usr/bin/curl -s -X POST -F Username=${myUser} -F ComputerName=${compName} https://stats.sinc.stonybrook.edu/api/logoff/update)
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: ${myResult}" >> ${myLog}
	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) ${me}[$$]: Ending ${me}, v${myVers}" >> ${myLog}
	exit 0
}

myLog="/Users/Shared/$(/usr/bin/basename ${0} | /usr/bin/cut -d "." -f 1).log"
myVers="2.00"
me=$(/usr/bin/basename ${0})
trap 'onLogout' SIGINT SIGHUP SIGTERM SIGQUIT SIGABRT
sleep 86400 &
while wait $!
do sleep 86400 &
done

