#!/bin/bash
# sudo apt install jq 
# 7seg display:
#   need 2display for show value
#   need 2displayDP for show kW value XX.YY
# checkdata: watch cat /dev/shm/*power

DEVICEIP=10.0.0.11
USER=1C6102DE5A22
PASS=32427658
REQUEST="http://${DEVICEIP}/getLastData?user=${USER}&password=${PASS}"
JFILE=/dev/shm/shrdzm-${DEVICEIP}.json
POWERFILE=/dev/shm/power
INPOWERFILE=/dev/shm/inpower
OUTPOWERFILE=/dev/shm/outpower
#FILEDATE=$(date "+%Y-%m-%d-%H-%M")
#CSVFILE=/var/log/shrdzm/energie-${FILEDATE}.csv
CSVFILE=/var/log/shrdzm/energie.csv
DISPLAY=0
SHOWDATA=1
WRITECSV=1

echo settings:
[ ${DISPLAY} -eq 1 ] && 2display init  
[ ${DISPLAY} -eq 0 ]  && echo " - no display" 
[ ${SHOWDATA} -eq 1 ] && echo " - output data to stdout"
[ ${WRITECSV} -eq 1 ] && echo " - write csv file ${CSVFILE}"
echo ""
[ ${SHOWDATA} -eq 1 ] && echo "   Date   ;   Time   ;Ouput power (W);Input power (W);Power (W);Power (kW)"
echo - > ${POWERFILE}
echo - > ${INPOWERFILE}
echo - > ${OUTPOWERFILE}
while true; do
    curl -s ${REQUEST} > ${JFILE} 
    if [ $? -eq 0 ]; then
      MYDATE=$(date "+%d.%m.%Y")
      MYTIME=$(date "+%T.%1N") 
      OUTPOWER=$(jq -r '."2.7.0"' ${JFILE})
      INPOWER=$(jq -r '."1.7.0"' ${JFILE})
      POWER=$(expr ${INPOWER} - ${OUTPOWER})   
      POWER4=$(echo "${INPOWER} ${OUTPOWER}" | awk '{printf "%04d", ($1 - $2)/10}')
      if [ $? -ne 0 ]; then
        echo error calculating power >&2
        echo - > ${POWERFILE}
      else 
        echo ${POWER} > ${POWERFILE}
      fi
      echo ${INPOWER} > ${INPOWERFILE}
      echo ${OUTPOWER} > ${OUTPOWERFILE}
      [ ${SHOWDATA} -eq 1 ] && echo "${MYDATE};${MYTIME};${OUTPOWER};${INPOWER};${POWER};${POWER4}" 
      [ ${WRITECSV} -eq 1 ] && echo "${MYDATE};${MYTIME};${OUTPOWER};${INPOWER};${POWER}" >> ${CSVFILE}
      if [ ${DISPLAY} -eq 1 ]; then
        [ ${POWER} -gt 9999 ] && POWER=9999
        [ ${POWER} -lt -999 ] && POWER=-999
        2display ${POWER}
        #2displayDP ${POWER4}
      fi
    else
      echo SHRDZM device not working >&2
      echo - > ${POWERFILE}
      echo - > ${INPOWERFILE}
      echo - > ${OUTPOWERFILE}
      [ ${DISPLAY} -eq 1 ] && 2display lost
    fi      
    sleep 4
done

