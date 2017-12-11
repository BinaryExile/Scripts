#!/usr/bin/env python
from scapy.all import *
INPUT="eth0"
OUTPUT="mon0"
conf.verb=0

def inject(pkt):
	fakemac="00:00:de:ad:be:ef"
	sendp(RadioTap()/Dot11(type=2, addr1=fakemac, addr2=fakemac, addr3=fakemac)/pkt, iface=OUTPUT)

sniff(store=0,prn=inject,iface=INPUT)
