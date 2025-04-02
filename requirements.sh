# Update System
sudo apt update && sudo apt upgrade -y

# Install Golang (Required for many tools)
sudo apt install golang -y
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# Install Python3 & Pip
sudo apt install python3 python3-pip -y

# Install Git
sudo apt install git -y

# Install Assetfinder
go install github.com/tomnomnom/assetfinder@latest

# Install Subfinder
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Install Findomain
wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O findomain
chmod +x findomain
sudo mv findomain /usr/local/bin/

# Install Httpx
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Install Gau
go install github.com/lc/gau/v2/cmd/gau@latest

# Install Waybackurls
go install github.com/tomnomnom/waybackurls@latest

# Install Unfurl
go install github.com/tomnomnom/unfurl@latest

# Install Nuclei
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
nuclei -update-templates  # Update templates

# Install GF (Good Filters)
go install github.com/tomnomnom/gf@latest
mkdir -p ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns ~/Gf-Patterns
cp ~/Gf-Patterns/*.json ~/.gf/

# Install Subjack (Subdomain Takeover)
go install github.com/haccer/subjack@latest

# Install TKO-Subs (Another Subdomain Takeover tool)
git clone https://github.com/anshumanbh/tko-subs.git
cd tko-subs
go build
sudo mv tko-subs /usr/local/bin/

# Install Naabu (Port Scanner)
go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Install FFUF (Fuzzing)
go install github.com/ffuf/ffuf@latest

# Install Dirsearch (Content Discovery)
git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch
pip3 install -r requirements.txt
chmod +x dirsearch.py
sudo ln -s $(pwd)/dirsearch.py /usr/local/bin/dirsearch

# Install Katana (URL Crawling)
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Install Sublist3r
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
pip3 install -r requirements.txt
chmod +x sublist3r.py
sudo ln -s $(pwd)/sublist3r.py /usr/local/bin/sublist3r

# Install Aquatone (Screenshot Tool)
go install github.com/michenriksen/aquatone@latest

# Install Gowitness (Another Screenshot Tool)
go install github.com/sensepost/gowitness@latest

# Install DNSX (DNS Resolver)
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# Install MassDNS (Fast DNS Resolver)
git clone https://github.com/blechschmidt/massdns.git
cd massdns
make
sudo mv bin/massdns /usr/local/bin/

# Install GitHound (Finding Secrets in GitHub)
git clone https://github.com/tillson/git-hound.git
cd git-hound
go build
sudo mv git-hound /usr/local/bin/

# Install TruffleHog (Secrets Detection)
pip3 install trufflehog

# Install LinkFinder (JS File Analysis)
git clone https://github.com/GerbenJavado/LinkFinder.git
cd LinkFinder
pip3 install -r requirements.txt
python3 setup.py install

# Install SubJS (Extract JS Files from URLs)
go install github.com/lc/subjs@latest

# Install X8 (API Parameter Testing)
go install github.com/Sh1Yo/x8@latest

# Install Feroxbuster (Content Discovery)
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install.sh | bash
sudo mv feroxbuster /usr/local/bin/

# Install S3Scanner (S3 Bucket Enumeration)
git clone https://github.com/sa7mon/S3Scanner.git
cd S3Scanner
pip3 install -r requirements.txt
chmod +x S3Scanner.py
sudo ln -s $(pwd)/S3Scanner.py /usr/local/bin/S3Scanner

# Install Chaos (Live Asset Monitoring)
go install github.com/projectdiscovery/chaos-client/cmd/chaos@latest
