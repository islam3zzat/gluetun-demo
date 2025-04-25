# Gluetun VPN Demo

This project demonstrates how to use [Gluetun](https://github.com/qdm12/gluetun) as a VPN container to route other services through a NordVPN connection. It provides a simple setup to run services behind a VPN using Docker Compose.

## Features

- NordVPN integration using WireGuard
- Automatic WireGuard key generation
- Secure environment variable management
- Example service (curl) to demonstrate VPN routing
- Easy setup script

## Prerequisites

- Docker and Docker Compose installed
- NordVPN account
- `curl` and `jq` installed on your system

### Installing Dependencies

#### macOS
```bash
brew install curl jq
```

#### Ubuntu/Debian
```bash
sudo apt-get install curl jq
```

## Setup

1. Clone this repository:
```bash
git clone <repository-url>
cd gluetun-demo
```

2. Make the setup script executable:
```bash
chmod +x setup-env.sh
```

3. Run the setup script:
```bash
./setup-env.sh
```
   - The script will:
     - Ask for your NordVPN token
     - Automatically fetch your WireGuard private key
     - Create the necessary .env file
     - Set up proper file permissions

4. Start the services:
```bash
docker-compose up -d
```

## Configuration

The setup script creates a `.env` file with the following configuration:

- `NORDVPN_TOKEN`: Your NordVPN API token
- `WIREGUARD_PRIVATE_KEY`: Automatically fetched WireGuard private key
- `VPN_SERVICE_PROVIDER`: Set to "nordvpn"
- `VPN_TYPE`: Set to "wireguard"
- `SERVER_CATEGORIES`: Set to "P2P"
- `SERVER_COUNTRIES`: Set to "Netherlands"
- `GLUETUN_TZ`: Timezone setting
- `GLUETUN_LOG_LEVEL`: Log verbosity
- `GLUETUN_UPDATER_PERIOD`: Server list update frequency

## Usage

### Verifying VPN Connection

The `curl-container` service continuously checks the public IP address. You can view its logs to verify the VPN connection:

```bash
docker-compose logs -f curl-container
```

### Adding New Services

To add a new service that should route through the VPN, add it to the `docker-compose.yaml` file with:

```yaml
your-service:
  network_mode: "service:gluetun"
  # other configuration...
```

## Security Notes

- The `.env` file contains sensitive information and is excluded from version control
- The setup script sets strict file permissions (600) on the .env file
- Always keep your NordVPN token and WireGuard private key secure

## Troubleshooting

### Common Issues

1. **VPN Connection Fails**
   - Check the Gluetun logs: `docker-compose logs -f gluetun`
   - Verify your NordVPN token is correct
   - Ensure your system has the required dependencies

2. **Service Can't Connect**
   - Verify the service is using `network_mode: "service:gluetun"`
   - Check if Gluetun is running: `docker-compose ps`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Gluetun](https://github.com/qdm12/gluetun) for the VPN container
- [NordVPN](https://nordvpn.com) for the VPN service
