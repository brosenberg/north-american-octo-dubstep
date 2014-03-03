#!/usr/bin/env python

import errno
import resource
import socket
import threading

DEFAULT_TIMEOUT=60
MAX_THREADS = resource.getrlimit(resource.RLIMIT_NOFILE)[0]-15

class NetworkScanner(object):
    def __init__(self):
        self.status  = {}
        self.threads = {}

    def scan_host_port(self, ip, port, timeout=DEFAULT_TIMEOUT):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        try:
            s.connect((str(ip), port))
            self.status[ip][port] = 'open'
        except IOError, e:
            if e.errno == errno.EACCES:
                self.status[ip][port] = 'denied'
            elif e.errno == errno.ECONNREFUSED:
                self.status[ip][port] = 'closed'
            elif e.errno == errno.EHOSTUNREACH:
                self.status[ip][port] = 'unreachable'
            elif e.errno == errno.ETIME or e.errno == errno.ETIMEDOUT:
                self.status[ip][port] = 'filtered'
            else:
                self.status[ip][port] = 'unknown'
        except socket.timeout:
            self.status[ip][port] = 'filtered'
        except Exception, e:
            self.status[ip][port] = 'Exception: %s' % (e,)
        s.close()

    def wait_on_scans(self, timeout=DEFAULT_TIMEOUT):
        while threading.active_count() >= MAX_THREADS:
            for thread in threading.enumerate():
                try:
                    thread.join(timeout)
                except RuntimeError:
                    pass

    def scan_network(self, ips, ports, timeout=DEFAULT_TIMEOUT):
        for ip in ips:
            self.status[ip] = {}
            self.threads[ip] = {}
            for port in ports:
                threading.Thread(target=self.scan_host_port, args=(ip, port, timeout)).start()
                self.wait_on_scans()
        self.wait_on_scans(timeout)
        return self.status

    def __str__(self):
        s = []
        for ip in sorted(self.status.keys()):
            for port in sorted(self.status[ip].keys()):
                s.append("%s:%s %s" % (ip, port, self.status[ip][port]))
        return "\n".join(s)
