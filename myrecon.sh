#!/bin/bash

usage() {
    echo -e "Usage: ./myrecon.sh -d domain.com" 1>&2;
    exit 1;
}

while getopts ":d:" o; do
    case "${o}" in
        d)
            domain=${OPTARG} ;;
        *)
            usage ;;
    esac
done
shift $((OPTIND - 1))

echo "[+] Starting Recon for $domain"

# Subdomain Enumeration
echo "[+] Running Sublist3r"
python3 /home/h4ck3r/opt/Sublist3r/sublist3r.py -d $domain -o domains.txt > /dev/null

echo "[+] Running assetfinder"
assetfinder -subs-only $domain >> domains.txt

echo "[+] Running findomain"
findomain -q -t $domain >> domains.txt

echo "[+] Running subfinder"
subfinder -d $domain -silent >> domains.txt

echo "[+] Running waybackurls + unfurl"
waybackurls $domain | unfurl -u domains >> domains.txt

# JS File Analysis
echo "[+] Extracting JavaScript Files"
waybackurls $domain | grep -E '\\.js$' | tee js_files.txt

# Subdomain Takeover Detection
echo "[+] Checking for subdomain takeover"
subjack -w domains.txt -o takeover_results.txt

# Nuclei Scanning
echo "[+] Running Nuclei Scans"
nuclei -l domains.txt -t cves/ -o nuclei_cves.txt
nuclei -l domains.txt -t vulnerabilities/ -o nuclei_vulnerabilities.txt

# Parameter Discovery
echo "[+] Extracting parameters"
waybackurls $domain | gf parameters > params.txt

# Finalizing
echo "[+] Recon Completed!"
