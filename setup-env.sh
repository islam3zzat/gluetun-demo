#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored text
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to read secure input
read_secure() {
    local prompt="$1"
    local var_name="$2"
    local input

    while true; do
        read -s -p "$prompt: " input
        echo
        if [ -z "$input" ]; then
            echo "Value cannot be empty. Please try again."
        else
            break
        fi
    done

    eval "$var_name='$input'"
}

print_color "${YELLOW}" "NordVPN Gluetun Environment Setup"
echo "This script will help you set up your .env file for Gluetun with NordVPN."
echo ""

# Check if .env file exists and backup if it does
if [ -f .env ]; then
    echo "Existing .env file found. Creating backup..."
    cp .env .env.backup
    echo "Backup created as .env.backup"
fi

# Get NordVPN token
print_color "${YELLOW}" "\nStep 1: NordVPN Token"
echo "To get your NordVPN token:"
echo "1. Log in to your NordVPN account"
echo "2. Go to https://my.nordaccount.com/dashboard/nordvpn/access-tokens/"
echo "3. Generate a new key or use an existing one"
echo "4. Copy the token"
echo ""
read_secure "Enter your NordVPN token" NORDVPN_TOKEN

# Fetch WireGuard private key
print_color "${YELLOW}" "\nFetching WireGuard private key..."
WIREGUARD_PRIVATE_KEY=$(curl -s -u "token:${NORDVPN_TOKEN}" https://api.nordvpn.com/v1/users/services/credentials | jq -r .nordlynx_private_key)

if [ -z "$WIREGUARD_PRIVATE_KEY" ] || [ "$WIREGUARD_PRIVATE_KEY" == "null" ]; then
    print_color "${RED}" "Error: Failed to fetch WireGuard private key. Please check your token and try again."
    exit 1
fi

print_color "${GREEN}" "Successfully obtained WireGuard private key!"

# Create .env file
print_color "${GREEN}" "\nCreating .env file..."
cat >.env <<EOF
# NordVPN Configuration
NORDVPN_TOKEN=${NORDVPN_TOKEN}
WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}

# Gluetun Configuration
VPN_SERVICE_PROVIDER=nordvpn
VPN_TYPE=wireguard
# possible settings for NordVPN: https://nordvpn.com/servers/#ServerOverview_02
SERVER_CATEGORIES="Standard VPN servers" # Dedicated IP, Double VPN, Onion Over VPN, P2P, Standard VPN servers
SERVER_COUNTRIES="United States"
GLUETUN_TZ=Europe/London
GLUETUN_LOG_LEVEL=debug
GLUETUN_UPDATER_PERIOD=24h
EOF

# Set proper permissions
chmod 600 .env

print_color "${GREEN}" "\nEnvironment setup complete!"
echo "The .env file has been created with secure permissions."
echo "You can now start your containers with: docker-compose up -d"
echo ""
echo "To verify your setup, you can check the logs:"
echo "docker-compose logs -f gluetun"
