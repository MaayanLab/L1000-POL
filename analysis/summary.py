# -*- coding: utf-8 -*-
"""
Created on Wed Apr 20 16:50:44 2016

@author: Luke
"""

import json
import pandas as pd

from pymongo import MongoClient
client = MongoClient('azu', 27017)
db = client['L1000_POL']
cdColl = db['cd']

perts = [(doc['pert_id'],doc['pert_iname']) for doc in cdColl.find()]
uniqPerts = list(set(perts))

with open('perts.txt','w') as pf:
    for uniqPert in uniqPerts:
        pf.write(uniqPert[0]+'\t'+uniqPert[1]+'\n')



