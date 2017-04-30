#!/usr/bin/env python

import re

def doit(file_name):
    item = ""
    in_item = False
    f = open(file_name, 'r')
    items = set()
    c = 0
    for line in f.read().split('\n'):
        top = re.search(r'itemtopbg', line)
        bot = re.search(r'itembotbg', line)

        if top:
            in_item = True
        if in_item:
            item += " %s" % (line,) 
        if bot:
            in_item = False
            item = re.sub("(<.+?>)+", "#", item).strip()
            item = re.sub("\s*#\s*(#)+\s*", "#", item)
            #procs = re.search(r'^#(.+?)#.*Effect:\s*#?(.+?)#?\s*\(Combat', item)
            procs = re.search(r'Effect.*Combat', item)
            if procs:
                namre = re.search(r'^#(.+?)#', item)
                name = namre.group(1)

                procre = re.search(r'Effect:[\s#]+?\s*([^#]+?)#?\s*\(', item)
                proc = procre.group(1)

                nodropre = re.search(r'NO DROP', item)
                nodrop = "Yes" if nodropre else "No"

                levelre = re.search(r'at Level ([0-9]+)', item)
                level = "1" if levelre is None else levelre.group(1)

                skillre = re.search(r'Skill:\s*(.+?)\s*Atk', item)
                skill = skillre.group(1)

                print "%s~%s~%s~%s~%s" % (level, name, proc, skill, nodrop)
            item = ""

def main():
    doit("raw")

if __name__ == '__main__':
    main()
