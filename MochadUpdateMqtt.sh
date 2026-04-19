# ---------------------------------------------------------------------------
# Script:  MochadUpdateHaMqtt.sh
# Description:  Query Mochad for X10 device status.  Publish states as MQTT topics.
# Query Mochad using the "st" command to get the status of all learned X10 devices since it's last restart.
# Publish the state of each device as an MQTT topic:  mochad/$Loc/$HouseCode/$UnitCode/statedata | statevalue
# Other program may then subscribe a topic and take appropriate action.
# This program should be executed periodically (e.g. every 60 minutes?) to monitor latest X10 device status and update each topic.
# The next task will be to program HomeAssistant automations to subscribe to topics and update the state of corresponding HomeAssistant entities.
#   When HomeAssistant updates/corrects the state of an entity it should NOT trigger automations related to the entity, only correct it's current state value.
#
# Eric L. Edberg - 2026-04-18 ele@EdbergNet.com
#
# ---------------------------------------------------------------------------


PROG_PATH="`dirname \"$0\"`"                # could be relative
PROG_PATH="`( cd \"$PROG_PATH\" && pwd )`"  # now its absolute

export X10_MOCHAD_LOGDIR="${PROG_PATH}"

export MOCHAD_SERVER="127.0.0.1 1099"

export HA_SERVER="192.168.0.141"
export HA_PORT="1883"

export NETCAT="/bin/nc"
export NETCAT_LOG="${X10_MOCHAD_LOGDIR}/nc-log.txt"
export NETCAT_DEVICE_LOG="${X10_MOCHAD_LOGDIR}/nc-devices-log.txt"

TIMESTAMP() {
    echo "`date +'%m/%d %H:%M:%S'`"
}

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
X10_GETDEVICES() {
    # allow netcat 3 seconds to return
    # /bin/echo "st" | /bin/netcat -w 3 -q 3 127.0.0.1 1099
    /bin/echo "st" | ${NETCAT} -w 3 -q 3 ${MOCHAD_SERVER} > ${NETCAT_DEVICE_LOG}
    local xRet="$?"

    return ${xRet}
}


# ---------------------------------------------------------------------------
# Query Mochad for status of all X10 devices it has detected since the controllers last restart.
# Publish to MQTT topics
# ---------------------------------------------------------------------------
MOCHAD_STATUS_MQTT_PUBLISH() {
    
    X10_GETDEVICES
    local xRet="$?"
    
    if [ ${xRet} -ne 0 ]
    then
        echo "$(TIMESTAMP): MOCHAD_STATUS_MQTT_PUBLISH: ERROR: X10_GETDEVICES returned error: ${xRet}"
        return ${xRet}
    fi
  
    _devicestatus=0

    echo
    echo "MOCHAD X10 Device Status:"
    echo "----------------------------------"
    cat ${NETCAT_DEVICE_LOG}
    echo

    while read -r line
    do
        if echo ${line} | grep -i "Device status" > /dev/null
        then
            _devicestatus=1
            continue
        fi 
        
        # found start of next status line e.g.:  Security sensor status
        if echo ${line} | grep -i "Security sensor status" > /dev/null
        then
            _devicestatus=0
            continue
        fi 
        
        [ ${_devicestatus} -eq 0 ] && continue
        
        echo -e "\nline: ${line}"
        echo "----------------------------------"
        
		local xHouseCode="`echo ${line} | awk '{print $4}' - | cut -c1`"
        local xUnitCodes="`echo ${line} | awk '{print $5}' -`"

        IFS=","
        read -ra _unitarr <<< "${xUnitCodes}"
        for xUnitCode in ${_unitarr[@]} 
        do
            local xState="`echo ${xUnitCode} | cut -d"=" -f2`"
            local xUnitCode="`echo ${xUnitCode} | cut -d"=" -f1`"
            MOSQUITTO_MQTT_PUBLISH "${xHouseCode}" "${xUnitCode}" "${xState}"
        done
        IFS=" "

    done < ${NETCAT_DEVICE_LOG}

    return 0
}

# ---------------------------------------------------------------------------
# publish each learned Mochad X10 devices state as an MQTT topic:  mochad/$Server/$HouseCode/$UnitCode/statedata|statevalue
# ---------------------------------------------------------------------------
MOSQUITTO_MQTT_PUBLISH() {

    # TODO:  Create secure method to store/use credentials
    local HA_USER="UpdateUsernameHere"
    local HA_PASS="UpdatePasswordHere"
    local SERVER_ID="UpdateServerIDHere"
    local MYDEBUG="1"
    
    local _HouseCode="$1"
    local _UnitCode="$2"
    local _x10state="$3"
    local _dt="$(date -u +%s)"

    echo "$(TIMESTAMP): MOSQUITTO_MQTT_PUBLISH: housecode: ${_HouseCode}, unitcode: ${_UnitCode} state: ${_x10state}"
    
    [ -z "${_HouseCode}" ]  && return
    [ -z "${_UnitCode}" ]   && return
    [ -z "${_x10state}" ]   && return

    if echo ${_HouseCode} | egrep "\b([A-P])\b" > /dev/null
    then : #continue
    else return
    fi

    # convert to lowercase
    _HouseCode="`echo ${_HouseCode} | tr '[:upper:]' '[:lower:]'`"
    _UnitCode="` echo ${_UnitCode}  | tr '[:upper:]' '[:lower:]'`"
    _ID="${_HouseCode}${_UnitCode}"

    local _mqtt_topic="mochad/${SERVER_ID}/${_HouseCode}/${_UnitCode}/statedata"

    # publish data about the X10 event in a json-formatted message for later processing
    /usr/bin/mosquitto_pub -h ${HA_SERVER} -p ${HA_PORT} -u ${HA_USER} -P ${HA_PASS} --retain -t ${_mqtt_topic} -m "{\"dt\":\"${_dt}\"}, \"x10id\":\"${_ID}\", \"st\":\"${_x10state}\"}"

    # publish just the state value as a separate topic for easier use in HomeAssistant automations that detect value changes/states
    local _mqtt_topic="mochad/${SERVER_ID}/${_HouseCode}/${_UnitCode}/statevalue"
    /usr/bin/mosquitto_pub -h ${HA_SERVER} -p ${HA_PORT} -u ${HA_USER} -P ${HA_PASS} --retain -t ${_mqtt_topic} -m "${_x10state}"

    _xRet=$?     

    return $_xRet
}

MOCHAD_STATUS_MQTT_PUBLISH

echo
echo "----------------------------------"
echo "$(TIMESTAMP): MOCHAD_STATUS_MQTT_PUBLISH: Completed"
echo 
