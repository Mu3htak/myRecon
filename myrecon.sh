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

echo "> PLEASE WAIT WHILE WE AUTOMATE YOUR LITTLE PIECE OF SHIT..."

#Sublist3r enumeration
printf "[+] Running sublist3r\n"
python3 /home/h4ck3r/opt/Sublist3r/sublist3r.py -d $domain -o domains.txt > /dev/null

#Assetfinder enumeration
printf "[+] Running assetfinder\n"
assetfinder -subs-only $domain >> domains.txt

#Running Findomain
printf "[+] Running findomain\n"
findomain -q -t $domain >> domains.txt

#Running Subfinder
printf "[+] Running subfinder\n"
subfinder -d $domain -silent >> domains.txt

#Running waybackurls + unfurl to find subdomains
printf "[+] Running waybackurls + unfurl to find subdomains\n"
waybackurls $domain |  unfurl -u domains >> domains.txt

#Removing duplicate entries
printf "[+] Removing Duplicates from domains.txt\n"
sort -u domains.txt > final_domains.txt

printf "[+] Removed Duplicates and Saved as final_domains.txt\n"

#Checking for alive domains using httpx
printf "[+] Checking for alive domain\n"
cat final_domains.txt | httpx -silent -mc 200 > alive.txt

printf "[+] Saved alive domains in alive.txt\n"

#Waybackurls
printf "[+] Collecting URLs using waybackurls\n"
cat alive.txt | waybackurls | sort -u > wayback.txt

#GF
printf "[+] Collecting parameters for SSRF, SQLI, IDOR, XSS, REDIRECT using GF\n\n"
cat wayback.txt | gf idor | tee -a idor.txt

cat wayback.txt | gf xss | tee -a xss.txt

cat wayback.txt | gf redirect | tee -a redirect.txt

cat wayback.txt | gf ssrf | tee -a ssrf.txt

cat wayback.txt | gf sqli | tee -a sqli.txt

wc -l *.txt

printf "\nDONEEEE!!!!!!\n"
