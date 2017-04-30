#!/usr/bin/env python

import re
import requests
import time

def doit(c):
    url = "https://wiki.project1999.com/Special:ClassSlotEquip/%s/Primary/AllItems"% (c,)
    
    r = requests.get(url)
    item_name = None
    level = None
    no_drop = False
    effect_name = ""
    
    for line in r.text.split('\n'):
        m = re.search(r'class="itemtitle">\s*(.+?)\s*</div>', line)
        if m:
            item_name = m.group(1)
            continue
        nd = re.search(r'MAGIC ITEM.+?(NO DROP)?', line)
        if nd:
            if nd.group(1) is not None:
                no_drop = True
            else:
                no_drop = False
        e = re.search(r'Effect:.*[Cc]ombat.*', line)
        if e:
            l = re.search(r'Effect:.*[Cc]ombat.*[Ll]evel ([0-9]+)', line)
            if l is None:
                level = 1
            else:
                level = l.group(1)
            n = re.search(r'Effect:\s*(<a.+?>)?\s*(.+?)\s*(</a>)?\s*\(Combat.*', line)
            if n is None:
                effect_name = ""
            else:
                effect_name = n.group(2)
            print "%s~%s~%s~%s~%s" % (level, item_name, effect_name, no_drop, c)


def main():
    for c in ["Bard", "Cleric", "Druid", "Enchanter", "Magician", "Monk", "Necromancer", "Paladin", "Ranger", "Rogue", "Shadow_Knight", "Shaman", "Warrior"]:
        doit(c)
        time.sleep(1)

if __name__ == '__main__':
    main()
