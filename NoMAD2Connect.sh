#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	     									    	  #
# 	THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE				  #
# 	AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT	    			  #
#											  #
#	BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE IS UNDER NO OBLIGATION 	  #
#       TO SUPPORT, DEBUG, OR OTHERWISE	MAINTAIN THIS SCRIPT				  #
#	     									   	  #
#	THIS SCRIPT IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 		  #
#	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 	  #
#       AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 		  #
#	JAMF SOFTWARE, LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 	  #
#	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT   #
#	OF SUBSTITUTE GOODS OR SERVICES;LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 	  #
#	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 	  #
#	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING   #
#	IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 		  #
#	POSSIBILITY OF SUCH DAMAGE.							  #
#	     									   	  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	     									    	  #
#	This script will remove all versions of Jamf Connect and NoMAD/NoMAD Login.	  #
#	Before running this script unscope the Configuration Profile deploying the	  #
#	.plist. If Jamf Connect Login/NoMAD Login is installed it will log out the user.  #
#	     									    	  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	     									    	  #
#	Last Modified - October 18, 2022       			  #
#	     									    	  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

ORGANIZATION="Mortenson"

# Find if there's a console user or not. Blank return if not.
consoleuser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# get the UID for the user
uid=$(/usr/bin/id -u "$consoleuser")

###########################################
######	Checking and Removing NoMAD  ######
###########################################

#Creates variables for NoMAD Locations
echo "Checking for NoMAD..."
nloc="/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist"
napp="/Applications/NoMAD.app"
nplist="/Library/Managed Preferences/com.trusourcelabs.NoMAD.plist"
nshare="/Library/Managed Preferences/menu.nomad.shares.plist"
nprefplist="/Library/Preferences/com.trusourcelabs.NoMAD.plist"
nprefshare="/Library/Preferences/menu.nomad.shares.plist"
nuserplist="/Users/$consoleuser/Library/Preferences/com.trusourcelabs.NoMAD.plist"
nusershare="/Users/$consoleuser/Library/Preferences/menu.nomad.shares.plist"


#Check for NoMAD
if [ -f "$nloc" ] || [ -d "$napp" ] || [ -f "$nplist" ] || [ -f "$nshare" ] || [ -f "$nprefplist" ] || [ -f "$nprefshare" ] || [ -f "$nuserplist" ] || [ -f "$nusershare" ];
then
	echo "NoMAD was found"

#Removes NoMAD LaunchAgent if found
	if [ -f "$nloc" ];
	then
		/bin/launchctl bootout gui/"$uid" "$nloc"
		/bin/rm "$nloc"
		echo "NoMAD LaunchAgent has been removed from the Computer"
	else
		echo "NoMAD LaunchAgent not found"
	fi

#Removes NoMAD Application if found
	if [ -d "$napp" ];
	then
		/bin/rm -rf "$napp"
		echo "Removed NoMAD Application"
	else
		echo "NoMAD Application not found"
	fi
#Removes NoMAD .plist if found
	if [ -f "$nplist" ];
	then
		/bin/rm "$nplist"
		echo "Removed the NoMAD .plist"
	else
		echo "NoMAD .plist not found"
	fi
#Removes NoMAD Share .plist if found
	if [ -f "$nshare" ];
	then
		/bin/rm "$nshare"
		echo "Removed the NoMAD share .plist"
	else
		echo "NoMAD Share .plist not found"
	fi
#Removes Preferences NoMAD .plist if found
	if [ -f "$nprefplist" ];
	then
		/bin/rm "$nprefplist"
		echo "Removed the User Preferences NoMAD .plist"
	else
		echo "User Preferences NoMAD .plist not found"
	fi
#Removes Preferences NoMAD Share .plist if found
	if [ -f "$nprefshare" ];
	then
		/bin/rm "$nprefshare"
		echo "Removed the Preferences NoMAD Share .plist"
	else
		echo "Preferences NoMAD Share .plist not found"
	fi
#Removes User Preferences NoMAD .plist if found
	if [ -f "$nuserplist" ];
	then
		/bin/rm "$nuserplist"
		echo "Removed the User Preferences NoMAD .plist"
	else
		echo "User Preferences NoMAD .plist not found"
	fi
#Removes User Preferences NoMAD Share if found
	if [ -f "$nusershare" ];
	then
		/bin/rm "$nusershare"
		echo "Removed the User Preferences NoMAD Share"
	else
		echo "User Preferences NoMAD Share not found"
	fi
#NoMAD is not found on the computer
else
	echo "NoMAD not found on the Computer"
fi

#################################################
######	Checking and Removing NoMAD Login  ######
#################################################

#Creates Variables for NoMAD Login Locations
echo ""
echo "Checking for NoMAD Login..."
nlloc="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
nlplist="/Library/Managed Preferences/menu.nomad.login.ad.plist"
nluserpref="/Library/Preferences/menu.nomad.login.ad.plist"
nlpref="/Users/$consoleuser/Library/Preferences/menu.nomad.login.ad.plist"

#Check for NoMAD Login and changes Login Window back to Apples
if [ -e "$nlloc" ] || [ -f "$nlplist" ] || [ -f "$nluserpref" ] || [ -f "$nlpref" ];
then
	echo "NoMAD Login was found"
	/usr/local/bin/authchanger -reset

#Removes NoMAD Login and .plist if found and resets the loginwindow to Apples
	if [ -e "$nlloc" ];
	then
		/bin/rm -rf "$nlloc"
		echo "NoMAD Login Application has been removed from the Computer"
	else
		echo "NoMAD Login Application not found on the Computer"
	fi

#Removes NoMAD Login .plist
	if [ -f "$nlplist" ];
	then
		/bin/rm "$nlplist"
		echo "NoMAD Login .plist has been removed from the Computer"
	else
		echo "NoMAD Login .plist not found the Computer"
	fi
#Removes NoMAD Login Preferences .plist if found
	if [ -f "$nlpref" ];
	then
		/bin/rm "$nlpref"
		echo "Removed the NoMAD Login Preferences .plist"
	else
		echo "NoMAD Login Preference .plist not found"
	fi
#Removes NoMAD Login User Preference .plist if found
	if [ -f "$nluserpref" ];
	then
		/bin/rm "$nluserpref"
		echo "Removed the NoMAD Login User Preference .plist"
	else
		echo "NoMAD Login User Preference .plist not found"
	fi

#NoMAD Login is not found on the computer
else
	echo "NoMAD Login not found on the Computer"
fi


# Create uninstall confirmation file to un-scope NoMAD profiles

/usr/bin/touch /Users/Shared/.nomadRemoved
/usr/local/bin/jamf recon
sleep 1

# Install Jamf Connect from Jamf Pro
/usr/bin/jamf policy -event installJamfConnect
/usr/bin/jamf recon

# Present instructions on migrating local users before continuing with installing Jamf Connect

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

buttonClicked=$($jamfHelper -windowType hud -title "NoMAD 2 Jamf Connect" -heading "Complete your Jamf Connect migration!" -description "NoMAD has uninstalled, please click Continue to log out. Log back in using your $ORGANIZATION email, then choose your local user account to complete the Jamf Connect migration." -button1 "Continue")

if [[ $buttonClicked == 0 ]]; then
	# Continue pressed, logout
	killall loginwindow
fi


exit 0
