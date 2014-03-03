#!/usr/bin/env python

import socket

from threading import Thread

DEFAULT_TIMEOUT=60

class NetworkScanner(object):
    def __init__(self):
        self.status  = {}
        self.threads = {}

    def scan_host_port(self, ip, port, timeout=DEFAULT_TIMEOUT):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        self.status[ip][port] = s.connect_ex((str(ip), port))
        s.close()

    def scan_network(self, ips, ports, timeout=DEFAULT_TIMEOUT):
        for ip in ips:
            self.status[ip] = {}
            for port in ports:
                self.threads[port] = Thread(target=self.scan_host_port, args=(ip, port, timeout))
                self.threads[port].start()
        for ip in ips:
            for port in ports:
                self.threads[port].join()
        return self.status

    def __str__(self):
        s = []
        for ip in sorted(self.status.keys()):
            for port in sorted(self.status[ip].keys()):
                try:
                    port_state = 'open' if self.status[ip][port] == 0 else 'closed'
                except KeyError, e:
                    port_state = 'unknown'
                s.append("%s:%s %s" % (ip, port, port_state))
        return "\n".join(s)
