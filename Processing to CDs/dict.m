function [elems] = dict(arr,matchFunc)

   matchIdx = cellfun(matchFunc,arr,'UniformOutput',false);
   matchIdx = [matchIdx{:}];
   elems = arr(matchIdx);
   if numel(elems)==1
       elems = elems{1};
   end

end