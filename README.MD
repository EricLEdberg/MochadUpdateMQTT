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
`
    # TODO:  Create secure method to store/use credentials
    local HA_USER="UpdateUsernameHere"
    local HA_PASS="UpdatePasswordHere"
    local SERVER_ID="UpdateServerIDHere"
`
- Manually execute the program
- Using MQTT Browser (or other tool) verify that each device has 2 topics created

e.g.:
mosquitto_sub -h 192.168.0.141 -p 1883 -u MqttUser -P MqttPass -v -t "mochad/MqttServerID/#"


