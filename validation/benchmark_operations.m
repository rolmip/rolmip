function benchmark_operations(implementation)
% Isolated warm operations on prepared inputs; no optimization.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-operation-benchmark');
restoredefaultpath;addpath(fullfile(root,'ROLMIP_opt_34','validation'));
addpath(genpath('/home/ricfow/.cache/rolmip-review/YALMIP'));
if strcmp(implementation,'reference'),addpath(fullfile(root,'ROLMIP_github','rolmip'));addpath(fullfile(out,'timer_api'));
else,addpath(fullfile(root,'ROLMIP_opt_34','rolmip'));rolmipopt('codegen','off');end
if ~exist(fullfile(out,implementation),'dir'),mkdir(fullfile(out,implementation));end
S.c=load(fullfile(root,'baseSis_c.mat'));S.d=load(fullfile(root,'baseSis_d.mat'));records={};counter=0;
for domain={'c','d'},for metric={'hinf','h2'},for n=2:5,for N=2:5,for degree=0:4
 c=struct('domain',domain{1},'n',n,'N',N,'i',1,'metric',metric{1},'degree',degree,'rho',0,'relax',0,'zeroD',strcmp(domain{1},'c')&&strcmp(metric{1},'h2'));
 yalmip('clear');sys=S.(c.domain).BASE{n,N,1}.sys;if c.zeroD,sys.D=cellfun(@(d) zeros(size(d)),sys.D,'UniformOutput',false);end
 [G,P,eta]=validation_model(sys,c);A=rolmipvar(sys.A,'A',N,1);At=A';Qraw=sdpvar(n);Q=rolmipvar(Qraw,'Q');nd=max(getvariables(Qraw));
 C={};for j=1:numel(G),cfs=coefs(G{j});if ~iscell(cfs),cfs={cfs};end;C{end+1}=cfs(:)';end
 if strcmp(c.metric,'hinf'),kinds={'multiply','homogenize','constraints','yalmip_only'};else,kinds={'constraints','yalmip_only'};end
 for ki=1:numel(kinds)
  kind=kinds{ki};id=sprintf('%s_%s_n%d_v%d_%s_p%d',kind,c.domain,n,N,c.metric,degree);dest=fullfile(out,implementation,[id '.mat']);counter=counter+1;
  if exist(dest,'file'),old=load(dest,'result');records{end+1}=old.result;continue;end
  if any(strcmp(kind,{'multiply','homogenize'})),batch=3;else,batch=1;end
  for j=1:2,R=operation(kind,At,P,Q,G,C);end
  times=zeros(1,7);
  for j=1:7
   rolmip_begin;
   for z=1:batch,R=operation(kind,At,P,Q,G,C);end
   times(j)=rolmip_end([])/batch;
  end
  [basis,shapes,exponents,V,L]=canonical(R,kind,nd);
  rel=0;abserr=0;
  if ~strcmp(implementation,'reference')
   ref=load(fullfile(out,'reference',[id '.mat']));assert(isequal(shapes,ref.shapes),'Shape mismatch');assert(same_exponents(exponents,ref.exponents),'Exponent mismatch');assert(isequal(size(basis),size(ref.basis)),'Affine dimensions mismatch');abserr=norm(basis-ref.basis,inf);rel=abserr/max(1,norm(ref.basis,inf));assert(rel<1e-12);assert(V==ref.result.V&&L==ref.result.L);
  end
  rng(600+n*100+N*10+degree);assign(recover(1:nd),randn(nd,1));point_error=0;
  if strcmp(kind,'multiply')||strcmp(kind,'homogenize')
   samples=[eye(N),ones(N,1)/N];
   for z=1:size(samples,2)
    a=samples(:,z);pv=value(evalpar(P,{a'}));
    if strcmp(kind,'multiply')
     av=zeros(n);for j=1:N,av=av+a(j)*sys.A{j};end
     expected=av'*pv;actual=value(evalpar(R,{a'}));point_error=max(point_error,norm(actual-expected,'fro')/max(1,norm(expected,'fro')));
    else
     expected={value(Qraw),pv};
     for j=1:2,actual=value(evalpar(R{j},{a'}));point_error=max(point_error,norm(actual-expected{j},'fro')/max(1,norm(expected{j},'fro')));end
    end
   end
   assert(point_error<1e-9);
  end
  if strcmp(kind,'yalmip_only')
   other=load(fullfile(out,implementation,strrep([id '.mat'],'yalmip_only_','constraints_')));assert(isequal(shapes,other.shapes));assert(norm(basis-other.basis,inf)/max(1,norm(other.basis,inf))<1e-12);assert(V==other.result.V&&L==other.result.L);
  end
  result=struct('id',id,'case',c,'operation',kind,'seconds',times,'median_seconds',median(times),'min_seconds',min(times),'max_seconds',max(times),'batch',batch,'warmups',2,'repetitions',7,'V',V,'L',L,'absolute_model_error',abserr,'relative_model_error',rel,'point_error',point_error);
  % Save coefficient representations in both versions for direct-YALMIP equivalence checks.
  save(dest,'result','basis','shapes','exponents','-v7');records{end+1}=result;
  fprintf('%d/960 %s %.6g s\n',counter,id,median(times));
 end
end,end,end,end,end
fid=fopen(fullfile(out,['timings_' implementation '.json']),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
end
function R=operation(kind,At,P,Q,G,C)
switch kind
 case 'multiply',R=At*P;
 case 'homogenize',R=homogenize(Q,P);
 case 'constraints',R=[];for j=1:numel(G),R=[R,G{j}>=0];end
 case 'yalmip_only',R=[];for j=1:numel(C),group=[];for k=1:numel(C{j}),group=group+(C{j}{k}>=0);end;R=[R,group];end
end
end
function [basis,shapes,exponents,V,L]=canonical(R,kind,nd)
C={};exponents={};V=0;L=0;
if any(strcmp(kind,{'constraints','yalmip_only'}))
 info=lmiinfo(R);L=sum(info.sdp(:,1));V=numel(getvariables(R));
 for j=1:length(R),C{end+1}=sdpvar(R(j));end
else
 if ~iscell(R),R={R};end
 for j=1:numel(R)
  st=struct(R{j});for k=1:numel(st.data),C{end+1}=st.data(k).value;exponents{end+1}=st.data(k).exponent;end
 end
end
parts={};shapes=[];
for j=1:numel(C)
 M=C{j};shapes(end+1,:)=[size(M,1),size(M,2)];part=sparse(numel(M),nd+1);
 if isa(M,'sdpvar'),part(:,[1 getvariables(M)+1])=getbase(M);else,part(:,1)=M(:);end
 parts{end+1}=part;
end
basis=vertcat(parts{:});
end

function tf=same_exponents(a,b)
% Constant monomials may store scalar zero or one zero per simplex vertex.
if ~isequal(size(a),size(b)),tf=false;return;end
for i=1:numel(a)
 if ~isequal(size(a{i}),size(b{i})),tf=false;return;end
 for j=1:numel(a{i})
  if all(a{i}{j}(:)==0),a{i}{j}=0;end
  if all(b{i}{j}(:)==0),b{i}{j}=0;end
 end
end
tf=isequal(a,b);
end
