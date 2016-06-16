#!/bin/bash
####################################################################################################################
#
# Alert   scanning  tool
# Author: Grigol Sirbiladze 
# Date:   03/10/2016
#
# Configure  "alertwatcher.conf" file for your needs
# You can monitor multiple files, but with common filter
# To receive alterts by e-mail, setup mailer on your system and list recipients in "alertwatcher.conf"
# List lookup filters in "match.filter" file
# List excluded filters in "exclude.filter" file (NOTE: exclude filter overwrites lookup filter)
#
####################################################################################################################


script="`which $0`"
script_name="`basename $script`"
script_location_dir="`echo $script | sed s/$script_name//`"
alert_conf_file="$script_location_dir/alertwatcher.conf"
script_flag="$script_location_dir/itsRunning"
exclude_filter="$script_location_dir/exclude.filter"
match_filter="$script_location_dir/match.filter"
mail_sender=/bin/mailx
unset IFS

print_message()
{
        print_date="{$(date)}"
        whole_str_len="$(expr ${#1} \+ ${#print_date} \+ 2)"
	[ ! -z $3 ] && printf "\n%${whole_str_len}s\n" | tr "\ " "-"
	printf "{$(date)}  %s\n"   "$1";
	[ ! -z $2 ] && printf "%${whole_str_len}s\n" | tr "\ " "-"
}

# check the flag if it's set then no reason to continue
if [ -f "$script_flag" ];
then
	print_message "ALERT WATCHER IS STILL RUNNING!" 1 2
	exit 1
fi

if [ ! -f "$alert_conf_file" ];
then
	print_message "Couldn't find configuration file ... " 1 2
	exit 1
fi


if [ ! -f "$match_filter" ];
then
        touch "$match_filter"
fi


if [ ! -f "$exclude_filter" ];
then
        touch "$exclude_filter"
fi


# set running flag
touch "$script_flag"

curr_host="$(hostname)"

#print_message "---------  START TIME:            `date`";

for record_position in `grep -vn "^#\|^$" "$alert_conf_file" | awk -F ":" '{ print $1 }'`
do
	# Read parameters and put in Array
	IFS=":"
	parameters=($(sed -n ${record_position}p $alert_conf_file))
	unset IFS

	if [ ! -f "${parameters[0]}" ];
	then
		print_message "FILE: '${parameters[0]}' dosn't exist............." 1 2
		continue
	fi

	if [ ! -z $(grep "[^0-9]" <<< "${parameters[1]}") ] || [ -z "${parameters[1]}" ]; then  parameters[1]=1;  fi
	if [ ! -z $(grep "[^0-9]" <<< "${parameters[2]}") ] || [ -z "${parameters[2]}" ]; then  parameters[2]=30; fi
	if [ ! -z $(grep "[^0-9]" <<< "${parameters[3]}") ] || [ -z "${parameters[3]}" ]; then  parameters[3]=0;  fi

	alert_position_in_log=`grep -n -f "$match_filter" "${parameters[0]}" | grep -v -f "$exclude_filter" | awk -F ":" '{print $1}' | tail -n 1`
	[ "$alert_position_in_log" == "" ] && alert_position_in_log=0;

	
        if [ $alert_position_in_log -ne ${parameters[3]} ];
        then
		print_message "Parsing '${parameters[0]}' file............." 1 2;
                curr_log=$(basename "${parameters[0]}");
		
		# creating "sed" expression
		expression="$(expr $alert_position_in_log \- ${parameters[1]}),$(expr $alert_position_in_log \+ ${parameters[2]})p"

                #if "recipients_list" is not set then just print output
                if [ -z "${parameters[5]}" ] || [ ! -f ${mail_sender} ]; then
			sed -n $expression "${parameters[0]}";
                else
			sed -n $expression "${parameters[0]}" | $mail_sender -s "${parameters[4]}: log file($curr_log)" ${parameters[5]}
                fi
	        #update counter
	        sed -i "$record_position s:.*:${parameters[0]}\:${parameters[1]}\:${parameters[2]}\:$alert_position_in_log\:${parameters[4]}\:${parameters[5]}:"  "$alert_conf_file"
        fi
done

#print_message "-----------  END TIME:            `date`";

#remove flag
if [ -f "$script_flag" ]; then
        rm -f "$script_flag"
else
        print_message "Wierd!!! no running flag file................" 1 2
fi


