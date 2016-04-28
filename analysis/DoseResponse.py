# -*- coding: utf-8 -*-
"""
Created on Fri Apr 22 16:17:37 2016

@author: Luke
"""
import pandas as pd
from itertools import combinations
import numpy as np
from scipy.spatial.distance import cdist,pdist
from scipy.misc import comb
import matplotlib.pyplot as plt

from pymongo import MongoClient
client = MongoClient('azu', 27017)
db = client['L1000_POL']
cdColl = db['cd']

cdColl.aggregate([{'$group':{'_id':{'pert_id':'$pert_id','pert_dose':'$pert_dose'},
                             'cell_id':{'$addToSet':"$cell_id"},
                            'sig_id':{'$addToSet':'$sig_id'}}},
                 {'$out':'byPertDose'}])

byPertDoseColl = db['byPertDose']
sigCountByDose = [len(doc['sig_id']) for doc in byPertDoseColl.find()]
sigCountByDose = pd.Series(sigCountByDose)
sigCountByDose.hist()

uniqPert_ids = byPertDoseColl.distinct('_id.pert_id')
for pert_id in uniqPert_ids:
    print(pert_id)
    # add cd to each dose group of pert
    byDoseGroups = list(byPertDoseColl.find({'_id.pert_id':pert_id}))
    for group in byDoseGroups:
        group['cds'] = []
        group['pairwiseCount'] = int(comb(len(group['sig_id']),2))
        for sig_id in group['sig_id']:
            doc = cdColl.find_one({'sig_id':sig_id})
            group['cds'].append(doc['chdirLm'])
    
    # compute the cosine distances between CDs of different doses
    cosDistsBetweenCdOfDifferentDose = []
    for combinationByDose in combinations(byDoseGroups,2):
        distMat = cdist(np.asmatrix(combinationByDose[0]['cds']),
                      np.asmatrix(combinationByDose[1]['cds']),'cosine')
        dists = list(np.asarray(distMat).reshape(-1))
        cosDistsBetweenCdOfDifferentDose += dists
    
    # null distribution of averages of cosine distances of "sigCount" CDs
    sampleCount = 10000    
    nullDistributions = {}
    for pairwiseCount in set([group['pairwiseCount'] for group in byDoseGroups]):
        nullDistributions[pairwiseCount] = np.array([np.average(
        np.random.choice(cosDistsBetweenCdOfDifferentDose,
                         pairwiseCount,False)) for i in range(sampleCount)])
    
    # compute pvalues for each dose group and send to MongoDB
    for group in byDoseGroups:
        dists = pdist(np.asmatrix(group['cds']),'cosine')
        group['avgDist'] = np.average(dists)
        group['pvalue'] = np.sum(nullDistributions[group['pairwiseCount']] 
        < group['avgDist']) / sampleCount
        byPertDoseColl.update_one({'_id':group['_id']},
                                   {'$set':{'avgDist':group['avgDist'],
                                            'pvalue':group['pvalue']}})
    
pvalues = [doc['pvalue'] for doc in byPertDoseColl.find()] 
plt.hist(pvalues)

byPertDoseColl.aggregate([{'$group':{'_id':'$_id.pert_id',
                                     'byDose':{'$addToSet':{
                                     'pert_dose':'$_id.pert_dose',
                                     'avgDist':'$avgDist',
                                     'pvalue':'$pvalue'}}}},
                        {'$out':'byPert'}])

# add more descriptive information to byPert collection
idToName = {}
for doc in cdColl.find():
    idToName[doc['pert_id']] = doc['pert_iname']
byPertColl = db['byPert']
for doc in byPertColl.find():
    byPertColl.update_one({'_id':doc['_id']},
                           {'$set':{'pert_iname':idToName[doc['_id']]}})

# create a table of dose specific significance
with open('dosePert.txt','w') as df:
    df.write('pert_iname\tpert_id\tsignificance count\tdose,pvalue\n')
    for doc in byPertColl.find():
        count = sum([item['pvalue']<0.01 for item in doc['byDose']])
        dosePval = [[item['pert_dose'],item['pvalue']] for item in doc['byDose']]
        dosePval = sorted(dosePval,key=lambda x:float(x[0]))
        detail = '\t'.join([item[0]+'um,'+str(item[1]) for item in dosePval])
        df.write('{0}\t{1}\t{2}\t{3}\n'.format(doc['pert_iname'],
                 doc['_id'],count,detail))
    