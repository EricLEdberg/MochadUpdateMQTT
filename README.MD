# MochadUpdateMqtt 
Mochad Update MQTT is as it's name suggests, a tool that uses the Mochad program to query and return the status of X10 devices hosted on an X10 CM15 controller.  It sends the X10 "st" command to list device status and then publishes each X10 device state as MQTT topics.

Basically, this program queries an X10 CM15 controller for the state of all X10 devices it has detected.  Each X10 state is then published as 2 MQTT topics.   This program is run on-demand, often by cron.  Other 3rd-party applications e.g.: HomeAssistant, can inspect and/or monitor the state values and update their local values.

This program does NOT transmit real-time changes and is only intended to "correct" or initialize values.

There is another program that supports real-time MQTT updates.  I need to update my GIT repository for this tool soon...

## Requirements
- A working X10 CM15 or CM19 controller connected to a USB port (RPI or Linux typical)
- A Mochad process that can access the USB port, accept incomming TCP connections, and query the X10 controller
- A MQTT server that will host mqtt topics managed by this program

These requirements are beyond the initial scope of this document.

## Installation

- Install this program on any system supporting BASH
- Edit the program and update the MQTT:  user, password, and server_id values
-- The server_id value identifies what X10 controller is being monitored.

    TODO:  Create secure method to store/use credentials
    local HA_USER="UpdateUsernameHere"
    local HA_PASS="UpdatePasswordHere"
    local SERVER_ID="UpdateServerIDHere"

- Manually execute the program
- Using MQTT Browser (or other tool) verify that each device has 2 topics created

```
e.g.:
mosquitto_sub -h 192.168.0.141 -p 1883 -u MqttUser -P MqttPass -v -t "mochad/MqttServerID/#"
```

## Example X10 CM15 "st" Status Output
```
04/19 13:48:39 Device selected
04/19 13:48:39 House C: 2
04/19 13:48:39 House O: 9
04/19 13:48:39 Device status
04/19 13:48:39 House C: 1=0,2=0,3=0,4=0,5=0,6=0,7=0,8=0
04/19 13:48:39 House O: 1=1,2=1,3=0,4=0,5=0,6=1,7=1,8=1,9=1,10=0,11=0,12=0,13=0,14=0,15=0,16=0
04/19 13:48:39 Security sensor status
04/19 13:48:39 End status
```

## Example MQTT Topics As A Result Of ST Output Above
```
mochad/IL/c/1/statedata {"dt":"1776624519"}, "x10id":"c1", "st":"0"}
mochad/IL/c/1/statevalue 0
mochad/IL/c/2/statedata {"dt":"1776624520"}, "x10id":"c2", "st":"0"}
mochad/IL/c/2/statevalue 0
mochad/IL/c/3/statedata {"dt":"1776624520"}, "x10id":"c3", "st":"0"}
mochad/IL/c/3/statevalue 0
mochad/IL/c/4/statedata {"dt":"1776624520"}, "x10id":"c4", "st":"0"}
mochad/IL/c/4/statevalue 0
mochad/IL/c/5/statedata {"dt":"1776624520"}, "x10id":"c5", "st":"0"}
mochad/IL/c/5/statevalue 0
mochad/IL/c/6/statedata {"dt":"1776624520"}, "x10id":"c6", "st":"0"}
mochad/IL/c/6/statevalue 0
mochad/IL/c/7/statedata {"dt":"1776624520"}, "x10id":"c7", "st":"0"}
mochad/IL/c/7/statevalue 0
mochad/IL/c/8/statedata {"dt":"1776624520"}, "x10id":"c8", "st":"0"}
mochad/IL/c/8/statevalue 0
mochad/IL/o/1/statedata {"dt":"1776624520"}, "x10id":"o1", "st":"1"}
mochad/IL/o/1/statevalue 1
mochad/IL/o/2/statedata {"dt":"1776624520"}, "x10id":"o2", "st":"1"}
mochad/IL/o/2/statevalue 1
mochad/IL/o/3/statedata {"dt":"1776624520"}, "x10id":"o3", "st":"0"}
mochad/IL/o/3/statevalue 0
mochad/IL/o/4/statedata {"dt":"1776624520"}, "x10id":"o4", "st":"0"}
mochad/IL/o/4/statevalue 0
mochad/IL/o/5/statedata {"dt":"1776624520"}, "x10id":"o5", "st":"0"}
mochad/IL/o/5/statevalue 0
mochad/IL/o/6/statedata {"dt":"1776624520"}, "x10id":"o6", "st":"1"}
mochad/IL/o/6/statevalue 1
mochad/IL/o/7/statedata {"dt":"1776624520"}, "x10id":"o7", "st":"1"}
mochad/IL/o/7/statevalue 1
mochad/IL/o/8/statedata {"dt":"1776624520"}, "x10id":"o8", "st":"1"}
mochad/IL/o/8/statevalue 1
mochad/IL/o/9/statedata {"dt":"1776624520"}, "x10id":"o9", "st":"1"}
mochad/IL/o/9/statevalue 1
mochad/IL/o/10/statedata {"dt":"1776624520"}, "x10id":"o10", "st":"0"}
mochad/IL/o/10/statevalue 0
mochad/IL/o/11/statedata {"dt":"1776624520"}, "x10id":"o11", "st":"0"}
mochad/IL/o/11/statevalue 0
mochad/IL/o/12/statedata {"dt":"1776624520"}, "x10id":"o12", "st":"0"}
mochad/IL/o/12/statevalue 0
mochad/IL/o/13/statedata {"dt":"1776624520"}, "x10id":"o13", "st":"0"}
mochad/IL/o/13/statevalue 0
mochad/IL/o/14/statedata {"dt":"1776624520"}, "x10id":"o14", "st":"0"}
mochad/IL/o/14/statevalue 0
mochad/IL/o/15/statedata {"dt":"1776624520"}, "x10id":"o15", "st":"0"}
mochad/IL/o/15/statevalue 0
mochad/IL/o/16/statedata {"dt":"1776624520"}, "x10id":"o16", "st":"0"}
mochad/IL/o/16/statevalue 0
```