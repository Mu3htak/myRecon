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

# Create recon folder for domain
#mkdir -p recon/$domain && cd recon/$domain

echo "[+] Starting Recon for $domain"

# 1. Subdomain Enumeration
echo "[+] Running amass"
amass enum -passive -d $domain -o amass.txt

echo "[+] Running assetfinder"
assetfinder -subs-only $domain >> assetfinder.txt

echo "[+] Running findomain"
findomain -q -t $domain >> findomain.txt

echo "[+] Running subfinder"
subfinder -d $domain -silent >> subfinder.txt

echo "[+] Running waybackurls + unfurl"
waybackurls $domain | unfurl -u domains >> wayback_unfurl.txt

# 2. Combine and deduplicate all domains
cat amass.txt assetfinder.txt findomain.txt subfinder.txt wayback_unfurl.txt | sort -u > domains.txt

echo "[+] Resolving DNS using dnsx"
dnsx -silent -l domains.txt > resolved.txt

# 3. Filter valid domains
echo "[+] Checking alive domains"
httpx -l resolved.txt -mc 200 -silent -o alive.txt

# 4. Clean URLs using gau and uro
echo "[+] Gathering URLs and cleaning..."
cat alive.txt | gau 2>/dev/null | uro > clean_urls.txt

# 5. JavaScript file extraction (optional)
# echo "[+] Extracting JavaScript Files"
# while read sub; do gau $sub 2>/dev/null; done < alive.txt | grep -E '\.js$' | uro > js_files.txt

# 6. Nuclei Scans
echo "[+] Running Nuclei Scans"
#nuclei -l alive.txt -t misconfiguration/ -o misconfig.txt
#nuclei -l alive.txt -t vulnerabilities/ -silent -o nuclei_vulnerabilities.txt
nuclei -l alive.txt -t takeovers/ -o takeover_results.txt
nuclei -l alive.txt -t exposed-panels/ -o panels.txt
nuclei -l alive.txt -t default-logins/ -o logins.txt
# 7. Reflected XSS Detection with kxss
echo "[+] Scanning for reflected XSS using kxss"
while read sub; do
  gau "$sub" 2>/dev/null
done < alive.txt |
grep -vE "\.(json|js|jpe?g|gif|css|tiff?|png|ttf|woff2?|ico|svg)(\?|$)" |
uro |
kxss > xss_results.txt

# 8. Parameter Discovery using Arjun
echo "[+] Discovering hidden parameters using Arjun"
cat clean_urls.txt | while read url; do
  arjun -u "$url" -m GET -oT -q >> arjun_params.txt
done

# 9. Optional Subdomain Takeover Detection
# echo "[+] Checking for subdomain takeover"
# subzy run --targets domains.txt --hide_fails --output takeover_results.txt

# 10. Completion
echo "[+] Recon Completed for $domain! Results saved in recon/$domain"
notify -silent -data "Recon completed for $domain"

# Summary
echo -e "\n[+] Summary:"
wc -l *.txt
