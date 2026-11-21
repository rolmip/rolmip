function benchmark_degree(implementation,pilot)
% Degree scaling on the same databases; no optimization. Independent sessions.
if nargin<2,pilot=false;end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-degree-benchmark');
restoredefaultpath;addpath(fullfile(root,'ROLMIP_opt_34','validation'));
addpath(genpath('/home/ricfow/.cache/rolmip-review/YALMIP'));
if strcmp(implementation,'reference'),addpath(fullfile(root,'ROLMIP_github','rolmip'));addpath(fullfile(out,'timer_api'));
else,addpath(fullfile(root,'ROLMIP_opt_34','rolmip'));rolmipopt('codegen','off');end
S.c=load(fullfile(root,'baseSis_c.mat'));S.d=load(fullfile(root,'baseSis_d.mat'));
cases=struct('domain',{},'n',{},'N',{},'i',{},'metric',{},'degree',{},'rho',{},'relax',{},'zeroD',{});
for d={'c','d'},for m={'hinf','h2'},for n=2:5,for N=2:5,for degree=0:4
 c=struct('domain',d{1},'n',n,'N',N,'i',1,'metric',m{1},'degree',degree,'rho',0,'relax',0,'zeroD',strcmp(d{1},'c')&&strcmp(m{1},'h2'));cases(end+1)=c;
end,end,end,end,end
for d={'c','d'},for m={'hinf','h2'},for i=2:5,for degree=[1 4]
 c=struct('domain',d{1},'n',5,'N',5,'i',i,'metric',m{1},'degree',degree,'rho',0,'relax',0,'zeroD',strcmp(d{1},'c')&&strcmp(m{1},'h2'));cases(end+1)=c;
end,end,end,end
if pilot,cases=cases([cases.n]==5 & [cases.N]==5 & [cases.degree]==4 & [cases.i]==1);nrep=1;nwarm=1;folder=[implementation '_pilot'];
else,nrep=7;nwarm=2;folder=implementation;end
if ~exist(fullfile(out,folder),'dir'),mkdir(fullfile(out,folder));end
records={};
for k=1:numel(cases)
 c=cases(k);id=sprintf('%s_n%d_v%d_i%d_%s_p%d',c.domain,c.n,c.N,c.i,c.metric,c.degree);dest=fullfile(out,folder,[id '.mat']);
 if exist(dest,'file'),old=load(dest,'result');records{end+1}=old.result;continue;end
 sys=S.(c.domain).BASE{c.n,c.N,c.i}.sys;if c.zeroD,sys.D=cellfun(@(d) zeros(size(d)),sys.D,'UniformOutput',false);end
 times=zeros(1,nrep);Vs=zeros(1,nrep);Ls=zeros(1,nrep);
 for j=1:nwarm+nrep
  yalmip('clear');rolmip_begin;
  [G,P,eta]=validation_model(sys,c);F=[];for q=1:numel(G),F=[F,G{q}>=0];end
  [seconds,V,L]=rolmip_end(F);
  if j>nwarm,times(j-nwarm)=seconds;Vs(j-nwarm)=V;Ls(j-nwarm)=L;end
 end
 assert(all(Vs==V) && all(Ls==L));
 nd=getvariables(eta);[basis,shapes]=canonical(G,nd);
 modelerr=0;modelrel=0;
 if ~strcmp(implementation,'reference')
  ref=load(fullfile(out,'reference',[id '.mat']));assert(isequal(shapes,ref.shapes),'LMI block sizes differ');assert(isequal(size(basis),size(ref.basis)),'Affine matrix dimensions differ');modelerr=norm(basis-ref.basis,inf);modelrel=modelerr/max(1,norm(ref.basis,inf));assert(modelrel<1e-12,'Affine coefficients differ beyond floating-point tolerance');assert(V==ref.result.V && L==ref.result.L,'V/L differ');
 end
 rng(710+c.n*100+c.N*10+c.degree);assign(recover(1:nd),randn(nd,1));
 formulaerr=check_formula(G,P,eta,sys,c);assert(formulaerr<1e-9);
 result=struct('id',id,'case',c,'seconds',times,'median_seconds',median(times),'min_seconds',min(times),'max_seconds',max(times),'V',V,'L',L,'monomials_P',nchoosek(c.N+c.degree-1,c.degree),'nw',size(sys.B{1},2),'nz',size(sys.C{1},1),'model_error',modelerr,'model_relative_error',modelrel,'formula_error',formulaerr,'warmups',nwarm,'repetitions',nrep);
 if strcmp(implementation,'reference'),save(dest,'result','basis','shapes','-v7');else,save(dest,'result','-v7');end
 records{end+1}=result;
 fprintf('%d/%d %s median %.6g s, M=%d V=%d L=%d\n',k,numel(cases),id,median(times),result.monomials_P,V,L);
end
fid=fopen(fullfile(out,['timings_' folder '.json']),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
end
function [basis,shapes]=canonical(G,nd)
parts={};shapes=[];
for j=1:numel(G)
 C=coefs(G{j});if ~iscell(C),C={C};end
 for k=1:numel(C)
  M=C{k};shapes(end+1)=size(M,1);part=sparse(numel(M),nd+1);
  if isa(M,'sdpvar'),part(:,[1 getvariables(M)+1])=getbase(M);else,part(:,1)=M(:);end
  parts{end+1}=part;
 end
end
basis=vertcat(parts{:});
end
function err=check_formula(G,P,eta,sys,c)
N=c.N;n=c.n;m=size(sys.B{1},2);p=size(sys.C{1},1);tol=1e-6;
r=rand(N,3);samples=[eye(N),ones(N,1)/N,r./sum(r,1)];err=0;e=value(eta);
for k=1:size(samples,2)
 a=samples(:,k);A=blend(sys.A,a);B=blend(sys.B,a);C=blend(sys.C,a);D=blend(sys.D,a);Pa=value(evalpar(P,{a'}));
 if strcmp(c.domain,'c')
  if strcmp(c.metric,'hinf'),K=[-A'*Pa-Pa*A,-Pa*B,-C';-B'*Pa,e*eye(m),-D';-C,-D,eye(p)];else,K=[-A'*Pa-Pa*A,C';C,eye(p)];end
 else
  if strcmp(c.metric,'hinf'),K=[Pa,zeros(n,m),A'*Pa,C';zeros(m,n),e*eye(m),B'*Pa,D';Pa*A,Pa*B,Pa,zeros(n,p);C,D,zeros(p,n),eye(p)];else,K=[Pa,A'*Pa,C';Pa*A,Pa,zeros(n,p);C,zeros(p,n),eye(p)];end
 end
 expected={Pa-tol*eye(n),K-tol*eye(size(K)),e};
 if strcmp(c.metric,'h2')
  if strcmp(c.domain,'c'),cost=trace(B'*Pa*B);else,cost=trace(B'*Pa*B+D'*D);end
  expected{end+1}=e-cost;
 end
 for j=1:numel(G)
  sg=struct(G{j});if all(sg.vertices==0),actual=value(double(G{j}));else,actual=value(evalpar(G{j},{a'}));end
  err=max(err,norm(actual-expected{j},'fro')/max(1,norm(expected{j},'fro')));
 end
end
end
function M=blend(V,a)
M=zeros(size(V{1}));for j=1:numel(V),M=M+a(j)*V{j};end
end
