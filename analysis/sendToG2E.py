# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 14:03:23 2016

@author: Luke
"""

import json
import requests
import numpy as np

from pymongo import MongoClient
client = MongoClient('azu', 27017)
db = client['L1000_POL']
cdColl = db['cd']

with open(r'D:\Qiaonan Working\projects\search\app\data\POLgenes.json','r') as pf:
    polGenes = json.load(pf)


pert_ids = cdColl.distinct('pert_id')
payloads = []
for pert_id in pert_ids:
    print(pert_id)
    docs = [doc for doc in cdColl.find({'pert_id':pert_id})]
    # signature X genes    
    mat = np.array([doc['chdirFull'] for doc in docs])
    vec = np.mean(mat,axis=0)
    vecGenes = [[polGenes[i],val] for i,val in enumerate(vec)]
    vecGenesSorted = sorted(vecGenes,key=lambda x:np.absolute(x[1]),reverse=True)
    payload = {
        "ranked_genes":vecGenesSorted[:500],
        'diffexp_method': 'chdir',
        'tags': ['testp4'],
        'cell': None,
        'perturbation': docs[0]['pert_iname'],
    }
    payloads.append(payload)
#    r = requests.post('http://amp.pharm.mssm.edu/g2e/api/extract/upload_gene_list',
#                     data=json.dumps(payload))
with open('examplePayloads.json','w') as ef:
    json.dump(payloads,ef)
    
with open('examplePayloads.json','r') as ef:
    payloads = json.load(ef)

for payload in payloads:
    payload['tags'] = ['testp7']
    r = requests.post('http://amp.pharm.mssm.edu/g2e/api/extract/upload_gene_list',
                     data=json.dumps(payload))
            