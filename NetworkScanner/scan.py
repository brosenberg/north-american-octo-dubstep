#!/usr/bin/env python

import argparse
import netaddr
import networkscanner
import re
import time

def scan_network(network, ports, timeout=None):
    net = netaddr.IPNetwork(network)
    s = networkscanner.NetworkScanner()
    s.scan_network(list(net), ports, timeout)
    print s

def main():
    p = argparse.ArgumentParser()
    p.add_argument('-n', '--network', type=str, required=True, help='Network in CIDR notation. Ex: 192.168.0.1/24')
    p.add_argument('-p', '--ports', type=str, required=True, help='Comma delimited port list. Ex: 22,80')
    p.add_argument('-t', '--timeout', type=int, default='5', help='Timeout in seconds. Ex: 5')
    args = p.parse_args()

    ports = [int(x) for x in args.ports.split(',')]

    start = time.time()
    scan_network(args.network, ports, args.timeout)
    print "Scan took %.3f seconds" % (time.time() - start,)

if __name__ == '__main__':
    main()
