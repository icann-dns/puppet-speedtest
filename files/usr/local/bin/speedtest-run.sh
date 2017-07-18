#!/bin/bash

export PATH=/bin:/usr/bin:/usr/local/bin

OUTPUT=/opt/speedtest/speedtest-$(hostname).csv

SERVERS=""
while getopts m OPT; do
	case $OPT in
	m ) 
		#User requested for multiple queries
	   	API=7bd3111d-8418-44be-b395-9caba712073b
		HOST=$(hostname -a | cut -c-3)
		CITY="$(curl -s -k "https://iatacodes.org/api/v6/cities?code=${HOST}&api_key=${API}" | python -m json.tool | grep city| cut -d '"' -f4)"  #'
		SERVERS="$(speedtest-cli --list|grep "${CITY}" | cut -d ")" -f1)"
		if [ -z "${SERVERS}" ] ; then SERVERS="multi" ; fi
		;;
	* )
	    echo "Option unknown" >&2
		exit 1
		;;
	esac
done

if [ -z "${SERVERS}" ] ; then 
   	speedtest-cli --csv >> ${OUTPUT}
elif [ ${SERVERS} = "multi" ] ; then
   	speedtest-cli --csv >> ${OUTPUT}
	sleep 1
   	speedtest-cli --csv >> ${OUTPUT}
	sleep 1
   	speedtest-cli --csv >> ${OUTPUT}	
else
	for i in ${SERVERS}; do
		speedtest-cli --csv --server ${i} >> ${OUTPUT}
	done
fi
