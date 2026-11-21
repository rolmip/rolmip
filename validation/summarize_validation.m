function summarize_validation
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-validation');
for implementation={'reference','opt'}
 files=dir(fullfile(out,implementation{1},'*.mat'));records={};
 for k=1:numel(files)
  s=load(fullfile(files(k).folder,files(k).name),'result');records{end+1}=s.result;
 end
 fid=fopen(fullfile(out,[implementation{1} '_results.json']),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
 if ~isempty(records)
  states=cellfun(@(r) r.status,records,'UniformOutput',false);names=unique(states);
  fprintf('%s: %d cases\n',implementation{1},numel(records));for k=1:numel(names),fprintf('  %s: %d\n',names{k},sum(strcmp(states,names{k})));end
 end
end
end
