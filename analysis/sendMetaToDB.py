# -*- coding: utf-8 -*-
"""
Created on Thu Apr  7 11:36:02 2016

@author: Luke
"""

import json
import pandas as pd

from pymongo import MongoClient
client = MongoClient('azu', 27017)
db = client['L1000_POL']
instColl = db['inst']
sigColl = db['sig']


with open('instinfo.txt','r') as sf:
    header = next(sf)
    header = header.strip('\r\n\t').split('\t')
    header.append('batch')
    for row in sf:
        splits = row.strip('\r\n\t').split('\t')
        batch = '_'.join(splits[0].split('_')[:3])
        splits.append(batch)
        doc = dict(zip(header,splits))
        instColl.save(doc)
    
with open('siginfo.txt','r') as sf:
    header = next(sf)
    header = header.strip('\r\n\t').split('\t')
    for row in sf:
        splits = row.strip('\r\n\t').split('\t')
        splits2 = []
        for split in splits:
            furtherSplits = split.split('|')
            if len(furtherSplits)>1:
                splits2.append(furtherSplits)
            else:
                splits2.append(split)
        doc = dict(zip(header,splits2))
        sigColl.save(doc)