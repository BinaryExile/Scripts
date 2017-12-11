#!/usr/bin/env python
#remove headers that wireshark is having a problem with
from scapy.all import *

packets = []
def strip_packet(packet):
	if packet.addr1 != "00:00:de:ad:be:ef":
		wrpcap('/root/sec660/bootcap3/filtered.pcap', packet, append=True)

sniff(offline="/root/sec660/bootcap3/wifimirror.dump",prn=strip_packet)

#wrpcap("out.dump", packets)

#INPUT="eth0"
#OUTPUT="mon0"
#conf.verb=0

#fp = open("payloads.dat","wb")

#pcap = rdpcap('/root/sec660/bootcap3/wifimirror.dump')

#def write(pkt):
#	wrpcap('filtered.pcap',pkt, append=Trud)

#for pkt in pcap:
#	if pkt.


#def handler(packet):
#        fp.write(str(packet.payload.payload.payload))
#sniff(offline="/root/sec660/bootcap3/wifimirror.dump",prn=handler, filter="tcp or udp")


#def inject(pkt):
#	fakemac="00:00:de:ad:be:ef"
#	sendp(RadioTap()/Dot11(type=2, addr1=fakemac, addr2=fakemac, addr3=fakemac)/pkt, iface=OUTPUT)

#sniff(store=0,prn=inject,iface=INPUT)
