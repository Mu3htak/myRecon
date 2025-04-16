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

if [ -z "$domain" ]; then
    usage
fi

echo "[+] Starting Recon for $domain"

# Subdomain Enumeration
echo "[+] Running Sublist3r"
sublist3r -d $domain -o domains.txt > /dev/null

echo "[+] Running assetfinder"
assetfinder -subs-only $domain >> domains.txt

echo "[+] Running findomain"
findomain -q -t $domain >> domains.txt

echo "[+] Running subfinder"
subfinder -d $domain -silent >> domains.txt

echo "[+] Running waybackurls + unfurl"
waybackurls $domain | unfurl -u domains >> domains.txt

# Deduplicate and Check Alive
sort -u domains.txt > unique_domains.txt
httpx -l unique_domains.txt -silent -o alive.txt

# JS File Analysis
echo "[+] Extracting JavaScript Files"
while read sub; do gau $sub 2>/dev/null; done < alive.txt | grep -E '\.js$' | tee js_files.txt

# Subdomain Takeover Detection
echo "[+] Checking for subdomain takeover"
subzy run --targets unique_domains.txt --hide_fails --output takeover_results.txt

# Nuclei Scanning
echo "[+] Running Nuclei Scans"
nuclei -l alive.txt -t network/misconfig/ -silent -o nuclei_misconfig.txt
nuclei -l alive.txt -t vulnerabilities/ -silent -o nuclei_vulnerabilities.txt

# Parameter Discovery
echo "[+] Extracting parameters (XSS, SSRF, IDOR, etc)"
while read sub; do waybackurls $sub; done < alive.txt | tee wayback_all.txt \
| gf xss >> gf_xss.txt \
| gf ssrf >> gf_ssrf.txt \
| gf idor >> gf_idor.txt \
| gf lfi >> gf_lfi.txt \
| gf sqli >> gf_sqli.txt

# Combine all gf results
cat gf_*.txt | sort -u > params.txt

# Reflected XSS Detection using kxss
echo "[+] Scanning for reflected XSS using kxss"
while read sub; do gau $sub 2>/dev/null; done < alive.txt | kxss | tee xss_results.txt

# Finalizing
echo "[+] Recon Completed for"  $domain ! "Results saved in corresponding output files." | notify -silent

wc -l *.txt
