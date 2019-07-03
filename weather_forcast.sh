#!/usr/bin/env bash

${DIALOG_OK=0}
${DIALOG_CANCEL=1}

#Display message box
dialog_box(){
	dialog --clear --msgbox "$1" 0 0 2>&1 1>&3
}

#Make List
list_maker(){
	output=""
	for i in $1; do
		output="$output\n     - $i"
	done
	echo $output
}

#User info:
user_menu(){
	while true; do
		choice=$(dialog \
			--backtitle "User Information" \
			--clear \
			--menu "You are logged in as ${USER} with id=$(id -u)." 0 0 3 \
			"1" "Primary group" \
			"2" "List groups numerically" \
			"3" "List group names" \
			2>&1 1>&3)
		return_value=$?
		case $return_value in
			$DIALOG_OK)
				case $choice in
					1)
						dialog_box "Your primary group is $(id -g)";;
					2)
						dialog_box "You are a member of groups with the following numbers: $(id -G $(USER))";;
					3)
						dialog_box "You are a member of the following groups: $(id -Gn $(USER))";;
				esac;;
			$DIALOG_CANCEL)
				return;;
		esac
	done
}

#System Menu:
system_menu(){
	while true; do
		choice=$(dialog \
			--backtitle "System Information" \
			--clear \
			--menu "System Information." 0 0 5 \
			"1" "Number of processors" \
			"2" "Memory" \
			"3" "Disk space" \
			"4" "Home directory size" \
			"5" "Hostname and IP address" \
			2>&1 1>&3)
		return_value=$?
		case $return_value in
			$DIALOG_OK)
				case $choice in
					1)
						dialog_box "The are $(grep -c ^processor /proc/cpuinfo) processors";;
					2)
						dialog_box "$(free -h|grep Mem|tr -s ' '|cut -f3 -d ' ') have been used, $(free -h|grep Mem|tr -s ' '|cut -f4 -d ' ') are still free";;
					3)
						dialog_box "$(df -h --total|grep total|tr -s ' '|cut -f3 -d ' ') have been used, $(df -h --total|grep total|tr -s ' '|cut -f4 -d ' ') are still free";;
					4)
						dialog_box "The user's home directory takes up $(du -s -h ~/ | cut -f1)";;
					5)
						#dialog_box "The host is $(hostname) and the IP address is $(ifconfig|grep -A 1 eth0|grep -v eth0|tr -s ' '|cut -f3 -d ' ')";;
						dialog_box "The host is $(hostname) and the IP address is $(curl -s ipinfo.io/ip)";;
				esac;;
			$DIALOG_CANCEL)
				return;;
		esac
	done
}

#Local Menu:
local_menu(){
	while true; do
		choice=$(dialog \
			--backtitle "System Information" \
			--clear \
			--menu "Location and Weather." 0 0 2 \
			"1" "Current Location" \
			"2" "Weather Forecast" \
			2>&1 1>&3)
		return_value=$?
		case $return_value in
			$DIALOG_OK)
				case $choice in
					1)
						find_location;;			#Go to find location
					2)
						find_weather;;			#Go to find weather
				esac;;
			$DIALOG_CANCEL)
				return;;
		esac
	done
}

#Find Location:
find_location(){
	echo 0 | dialog --title "Getting IP Address." --gauge "Please wait ...." 10 60		#Display Loading Bar
	myIP=$(curl -s ipinfo.io/ip)														#Get current IP address
	echo 33 | dialog --title "Getting Latitude." --gauge "Please wait ...." 10 60		#Display Loading Bar
	lat=$(curl -s https://ipvigilante.com/$myIP|jq '.data.latitude'|tr -d '"')			#Get my latitude
	echo 66 | dialog --title "Getting Longitude." --gauge "Please wait ...." 10 60		#Display Loading Bar
	long=$(curl -s https://ipvigilante.com/$myIP|jq '.data.longitude'|tr -d '"')		#Get my longitude
	echo 100 | dialog --title "Finalizing." --gauge "Done ...." 10 60					#Display Loading Bar
	dialog_box "Current latitude is ${lat} and longitude is ${long}"					#Display latitude and longitude
}

#Find Weather:
find_weather(){
	echo 0 | dialog --title "Getting IP Address." --gauge "Please wait ...." 10 60									#Display Loading Bar
	myIP=$(curl -s ipinfo.io/ip)																					#Get current IP address
	echo 20 | dialog --title "Getting Latitude." --gauge "Please wait ...." 10 60									#Display Loading Bar
	lat=$(curl -s https://ipvigilante.com/$myIP|jq '.data.latitude'|tr -d '"'|sed 's/.$//')							#Get my latitude
	echo 40 | dialog --title "Getting Longitude." --gauge "Please wait ...." 10 60									#Display Loading Bar
	long=$(curl -s https://ipvigilante.com/$myIP|jq '.data.longitude'|tr -d '"'|sed 's/.$//')						#Get my longitude
	echo 60 | dialog --title "Getting Forcast Link." --gauge "Please wait ...." 10 60								#Display Loading Bar
	forcastLink=$(curl -s https://api.weather.gov/points/${lat},${long}|jq '.properties.forecast' | tr -d '"')		#Get weather api link to forcast for my latitude and longitude
	echo 80 | dialog --title "Getting Forcast Information." --gauge "Please wait ...." 10 60						#Display Loading Bar
	currentForcast=$(curl -s $forcastLink | jq '.properties.periods[0].detailedForecast' | tr -d '"')				#Store the Detailed forcast to display in message box.
	echo 100 | dialog --title "Finalizing." --gauge "Done ...." 10 60												#Display Loading Bar
	dialog_box "$currentForcast"																					#Display Forcast
}

#Main menu
while true; do
	exec 3>&1
	choice=$(dialog \
		--backtitle "Information Center - $(date)" \
		--clear \
		--menu "Choose from the following:" 0 0 3 \
		"1" "User information" \
		"2" "System information" \
        "3" "Local information" \
		2>&1 1>&3)
	return_value=$?
	case $return_value in
		$DIALOG_OK)
			case $choice in
				1)
					user_menu;;			#User Menu
				2)
					system_menu;;		#System Menu
                3)
					local_menu;;		#Local Menu
			esac;;
		$DIALOG_CANCEL)
			exec 3>&-
			clear
			echo "Thanks!";
			exit;;
	esac
done