#!/usr/bin/env python

import re
import requests
import time

def doit(c):
    url = "https://wiki.project1999.com/Special:ClassSlotEquip/%s/Primary/AllItems"% (c,)
    r = requests.get(url)
    print r.text

def main():
    for c in ["Bard", "Cleric", "Druid", "Enchanter", "Magician", "Monk", "Necromancer", "Paladin", "Ranger", "Rogue", "Shadow_Knight", "Shaman", "Warrior"]:
        doit(c)
        time.sleep(1)

if __name__ == '__main__':
    main()
