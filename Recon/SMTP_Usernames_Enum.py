#!/usr/bin/python

import socket
import sys


if len (sys.arg) != 3:
  print "usage: vrfy.py <username> <ip>"
  sys.exit(0)
  
s= socket.socket(socket.AF_INET, socket.SOCK_STREAM) #Create a socket
connect = s.connect((sys.argv[2],25))
banner=s.recv(1024)
print baner
s.send('VRFY ' + sys.argv[1] + '\r\n')
result = s.recv(1024)
print result
s.close()
