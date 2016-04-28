load('fields');
% load('bigMeta');

[coll,client] = getdbcoll('LINCS_L1000','meta2014');


for i = 40669:size(meta,1)
    for j = 1:numel(fields)
        field = fields{j};
        value = meta{i,j};
        value = strrep(value,'''','');
        eval(sprintf('doc.%1$s = ''%2$s'';',field,value));
    end
    coll.save(json2dbobj(savejson('',doc)));
    clear doc;
end

%% add batch field
import com.mongodb.BasicDBObject;
import java.util.regex.Pattern;
[coll,client] = getdbcoll('LINCS_L1000','meta2014');
filter = BasicDBObject();
filter.append('det_plate',Pattern.compile('CPC')).append('batch',json2dbobj('{$exists:false}'));
cursor = coll.find(filter,json2dbobj('{_id:0,distil_id:1}'));
for i = 1:cursor.count()
    doc = j2m(cursor.next());
    batch = doc.distil_id(1:stridx(doc.distil_id,3,'_')-1);
    coll.update(json2dbobj(sprintf('{distil_id:"%s"}',doc.distil_id)),...
        json2dbobj(sprintf('{$set:{batch:"%s"}}',batch)));
end