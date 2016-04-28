# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 14:53:49 2016

@author: Luke
"""

import json
import requests

with open('examplePayloads.json','r') as ef:
    payloads = json.load(ef)

for payload in payloads:
    payload['tags'] = ['testp7']
    r = requests.post('http://amp.pharm.mssm.edu/g2e/api/extract/upload_gene_list',
                     data=json.dumps(payload))