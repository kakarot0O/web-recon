#!/bin/bash
	
	# Check if a valid URL is provided as an argument
	if [ -z "$1" ]; then
	    echo "Usage: $0 <target_url>"
	    exit 1
	fi
	
	# Set the target URL from the argument
	url="$1"
	
	# Create directory structure
	directories=("recon" "recon/scans" "recon/httprobe" "recon/potential_takeovers" "recon/wayback" "recon/wayback/params" "recon/wayback/extensions" "recon/gowitness")
	for dir in "${directories[@]}"; do
	    if [ ! -d "$url/$dir" ]; then
	        mkdir -p "$url/$dir"
	    fi
	done
	
	# Harvest subdomains using assetfinder
	echo "[+] Harvesting subdomains with assetfinder..."
	assetfinder "$url" >> "$url/recon/assets.txt"
	grep "$1" "$url/recon/assets.txt" >> "$url/recon/final.txt"
	rm "$url/recon/assets.txt"
	
	#echo "[+] Double checking for subdomains with amass..."
	#amass enum -d $url >> $url/recon/f.txt
	#sort -u $url/recon/f.txt >> $url/recon/final.txt
	#rm $url/recon/f.txt
	 
	echo"[+] Probing for alive domains..."
	cat $url/recon/final.txt |sort -u |httprobe -s -p https:443 |sed 's/https\?:\/\///'|tr -d ':443'>>$url/recon/httprobe/a.txt
	sort -u $url/recon/httprobe/a.txt >$url/recon/httprobe/alive.txt
	rm $url/recon/httprobe/a.txt
	 
	echo"[+] Checking for possible subdomain takeover..."
	 
	if[ !-f"$url/recon/potential_takeovers/potential_takeovers.txt"];then
	    touch $url/recon/potential_takeovers/potential_takeovers.txt
	fi
	 
	subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt
	 
	echo"[+] Scanning for open ports..."
	nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt
	 
	echo"[+] Scraping wayback data..."
	cat $url/recon/final.txt |waybackurls >>$url/recon/wayback/wayback_output.txt
	sort -u $url/recon/wayback/wayback_output.txt
	 
	echo"[+] Pulling and compiling all possible params found in wayback data..."
	cat $url/recon/wayback/wayback_output.txt |grep '?*='|cut -d '='-f 1 |sort -u >>$url/recon/wayback/params/wayback_params.txt
	forlinein$(cat $url/recon/wayback/params/wayback_params.txt);doecho$line'=';done
	 
	echo"[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
	forlinein$(cat $url/recon/wayback/wayback_output.txt);do
	    ext="${line##*.}"
	    if[[ "$ext"=="js"]];then
	        echo$line>>$url/recon/wayback/extensions/js1.txt
	        sort -u $url/recon/wayback/extensions/js1.txt >>$url/recon/wayback/extensions/js.txt
	    fi
	    if[[ "$ext"=="html"]];then
	        echo$line>>$url/recon/wayback/extensions/jsp1.txt
	        sort -u $url/recon/wayback/extensions/jsp1.txt >>$url/recon/wayback/extensions/jsp.txt
	    fi
	    if[[ "$ext"=="json"]];then
	        echo$line>>$url/recon/wayback/extensions/json1.txt
	        sort -u $url/recon/wayback/extensions/json1.txt >>$url/recon/wayback/extensions/json.txt
	    fi
	    if[[ "$ext"=="php"]];then
	        echo$line>>$url/recon/wayback/extensions/php1.txt
	        sort -u $url/recon/wayback/extensions/php1.txt >>$url/recon/wayback/extensions/php.txt
	    fi
	    if[[ "$ext"=="aspx"]];then
	        echo$line>>$url/recon/wayback/extensions/aspx1.txt
	        sort -u $url/recon/wayback/extensions/aspx1.txt >>$url/recon/wayback/extensions/aspx.txt
	    fi
	done
	 
	rm $url/recon/wayback/extensions/js1.txt
	rm $url/recon/wayback/extensions/jsp1.txt
	rm $url/recon/wayback/extensions/json1.txt
	rm $url/recon/wayback/extensions/php1.txt
	rm $url/recon/wayback/extensions/aspx1.txt
	echo "[+] Running gowitness against all compiled domains..."
	gowitness file -s  $url/recon/httprobe/alive.txt -d $url/recon/gowitness"
	
	# Completed message
	echo "[+] Script completed successfully."
	
	exit 0
	
