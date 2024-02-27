#call_it
#!/bin/bash

# Function to generate a random MAC address
generate_random_mac() {
    echo -n "00:"
    od -An -N3 -t xC /dev/urandom | tr -s ' ' | tr ' ' ':' | cut -d: -f1-3
}

# Function to generate a random hostname
generate_random_hostname() {
    echo "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
}

# Set random MAC address and hostname
NEW_MAC=$(generate_random_mac)
NEW_HOSTNAME=$(generate_random_hostname)

# Function to spoof MAC address for a given interface
spoof_mac() {
    interface=$1
    sudo ifconfig $interface down
    sudo ifconfig $interface hw ether $NEW_MAC
    sudo ifconfig $interface up
}

# Spoof MAC address for eth0
spoof_mac "eth0"

# Check if wlan0 interface exists and spoof MAC address
if [[ $(ifconfig -a | grep wlan0) ]]; then
    spoof_mac "wlan0"
fi

# Check if wlan1 interface exists and spoof MAC address
if [[ $(ifconfig -a | grep wlan1) ]]; then
    spoof_mac "wlan1"
fi

# Change hostname
sudo hostnamectl set-hostname $NEW_HOSTNAME

# Display current MAC address and hostname for verification
echo "Current MAC address (eth0): $(cat /sys/class/net/eth0/address)"
echo "Current MAC address (wlan0): $(cat /sys/class/net/wlan0/address)"
echo "Current MAC address (wlan1): $(cat /sys/class/net/wlan1/address)"
echo "Current hostname: $(hostname)"

