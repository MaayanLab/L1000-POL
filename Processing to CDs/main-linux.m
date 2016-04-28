import com.mongodb.BasicDBObject;
import java.util.regex.Pattern;
import com.mongodb.util.JSON;
import com.mongodb.MongoClient;
mongoClient = MongoClient('10.91.53.79',27017);
db = mongoClient.getDB('LINCS_L1000');
readColl = db.getCollection('meta2014');
writeColl = db.getCollection('cpc2014');

filter = BasicDBObject();
filter.append('det_plate',Pattern.compile('CPC'));
batches = readColl.distinct('batch',filter);
batches = j2m(batches);

bigMatPath = 'smb://venus/newdata/q2norm_n1328098x22268.gctx';
load('smb://venus/newdata/id2gene');
load('smb://venus/newdata/newMatRid');
geneSymbols = cell(22268,1);
lmIdx = false(22268,1);
for i = 1:numel(rid)
    geneSymbols{i} = dict(rid{i}).gene;
    lmIdx(i) = dict(rid{i}).islm;
end
%%
for i = 243:numel(batches)
    batch = batches{i};
    fprintf('%s %d\n',batch,i);
    filter = BasicDBObject();
    filter.append('det_plate',Pattern.compile(batch));
    plates = readColl.distinct('det_plate',filter);
    plates = j2m(plates);
    
%     % replcate data on this plate has been removed from db
%     idx = strcmp('LJP005_MCF10A_3H_X2_B17',plates);
%     plates(idx) = [];
    platesRes = cell(1,numel(plates));
    
    tic
    % compute chdir for replicates on each plate
    for j = 1:numel(plates)
        plate = plates{j};
        query = BasicDBObject();
        query.append('det_plate',plate);
        cursor = readColl.find(query);
        arr = cell(cursor.count,1);
        cids = cell(cursor.count,1);
        for k = 1:cursor.count
            arr{k} = j2m(cursor.next());
            cids{k} = arr{k}.distil_id;
        end
        t = parse_gctx(bigMatPath,'cid',cids);
        % t.cid matches the order of cids
        for k = 1:numel(cids)
            arr{k}.data = t.mat(:,k);
        end
     
        plateRes = getChdir_2(arr,lmIdx);
        platesRes{j} = plateRes';
    end
    toc
    
    % get unique experiments' sig_ids.
    jsonQuery = sprintf('[{$match:{batch:"%s",pert_type:{$ne:"ctl_vehicle"}}},{$group:{_id:{"batch":"$batch","pert_id":"$pert_id","pert_dose":"$pert_dose"},replicateCount:{$sum:1}}}]',batch);
    aggregateOutput = readColl.aggregate(JSON.parse(jsonQuery));
    sigIdStructs = j2m(aggregateOutput.results());
    
    % merge chdir replicates and computeSignficance
    chdirArr = mergeReplicates(platesRes,sigIdStructs);
    
    % save chdir arr to db.
    tic
    for j = 1:numel(chdirArr)
        chdirStruct = chdirArr{j};
        writeColl.save(json2dbobj(savejson('',chdirStruct)));
    end
    toc
end
