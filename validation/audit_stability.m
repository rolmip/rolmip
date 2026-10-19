function audit_stability
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-validation');records={};
for domain={'c','d'}
 s=load(fullfile(root,['baseSis_' domain{1} '.mat']));
 for n=2:5
  for N=2:5
   for i=1:5
    sys=s.BASE{n,N,i}.sys;rng(1700+n*100+N*10+i);
    r=-log(rand(N,200));samples=[eye(N),ones(N,1)/N,r./sum(r,1)];
    worst=-Inf;alpha=[];
    for j=1:size(samples,2)
     A=zeros(n);for k=1:N,A=A+samples(k,j)*sys.A{k};end
     if strcmp(domain{1},'c'),margin=max(real(eig(A)));else,margin=max(abs(eig(A)))-1;end
     if margin>worst,worst=margin;alpha=samples(:,j);end
    end
    records{end+1}=struct('domain',domain{1},'n',n,'N',N,'i',i,'max_margin',worst,'alpha',alpha,'points',size(samples,2));
   end
  end
 end
end
fid=fopen(fullfile(out,'stability_samples.json'),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
fprintf('Stability audit: %d systems, %d sampled unstable witnesses.\n',numel(records),sum(cellfun(@(r) r.max_margin>=0,records)));
end
