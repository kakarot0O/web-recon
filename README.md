# Web Reconnaissance and Enumeration Script

This Bash script automates various steps of web reconnaissance and enumeration to gather information about a target domain. It's designed to streamline the process of discovering subdomains, alive domains, potential subdomain takeovers, open ports, and more.

## Features

- Subdomain harvesting using `assetfinder`
- Alive domain probing with `httprobe`
- Subdomain takeover checks with `subjack`
- Port scanning using `nmap`
- Wayback Machine data scraping with `waybackurls`
- Parameter and file extension enumeration from Wayback data
- Screenshot generation with `gowitness`

## Requirements

- Bash
- `assetfinder`
- `httprobe`
- `subjack`
- `nmap`
- `waybackurls`
- `gowitness`

## Usage

1. Clone the repository:
   git clone https://github.com/your-username/your-repo-name.git
2. Make the script executable :
   chmod +x recon-script.sh
3. Run the script with the target URL as an argument:
   ./recon-script.sh target-domain.com

## Output

The script creates a directory structure to organize the results of the reconnaissance process. Results include subdomains, alive domains, potential takeover candidates, open ports, Wayback data, and screenshots.

## Disclaimer
Make sure to use this script responsibly and only on domains you have explicit permission to scan. Unauthorized scanning can be against the law and violate terms of service.
