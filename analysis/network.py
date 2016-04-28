# -*- coding: utf-8 -*-



from pymongo import MongoClient
client = MongoClient('azu', 27017)
db = client['L1000_POL']
cdColl = db['cd']

import networkx as nx
import numpy as np
from scipy.spatial.distance import pdist
from scipy.spatial.distance import squareform

mat = []
docs = []
for doc in cdColl.find({},{'sig_id':True,'chdirLm':True,'pert_mfc_id':True,
                       'pvalue':True,'pert_id':True,'pert_dose':True,
                       'pert_iname':True,'pert_time':True,'cell_id':True,
                       '_id':False}):
    mat.append(doc['chdirLm'])
    docs.append(doc)

mat = np.asmatrix(mat)
dist = pdist(mat,'cosine')
dist = squareform(dist)
thres = 0.5
binaryDist = dist<=thres
np.fill_diagonal(binaryDist,False)
G = nx.from_numpy_matrix(binaryDist)

attributesByIndex = {}
for i,doc in enumerate(docs):
    for key in doc:
        if key == 'chdirLm':
            continue
        if key not in attributesByIndex:
            attributesByIndex[key] = {}
        attributesByIndex[key][i] = doc[key]
            
for key in attributesByIndex:
    nx.set_node_attributes(G,key,attributesByIndex[key])
    
nx.write_gexf(G,'POL.gexf')