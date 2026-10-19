function validate_database(implementation, allowDzero, first, last, retryWarnings)
% Reproducible analysis campaign. Run reference before opt, separate sessions.
% No source MAT file is modified. All generated files go to output/opt34-validation.
if nargin<5,retryWarnings=false;end
if nargin<2,allowDzero=false;end
if nargin<3,first=1;end
if nargin<4,last=Inf;end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
restoredefaultpath;
addpath(fullfile(root,'ROLMIP_opt_34','validation'));
addpath(genpath('/home/ricfow/.cache/rolmip-review/YALMIP'));
addpath(genpath('/home/ricfow/Dropbox/MatLab/andre/andre_08set26/Solvers/SeDuMi'));
addpath(genpath('/home/ricfow/Dropbox/toolboxes/MPT/mpt'));
addpath(genpath('/home/ricfow/Dropbox/toolboxes/MPT/cddmex'));
mptopt('lpsolver','cdd');
if strcmp(implementation,'reference'),folder='ROLMIP_github';else,folder='ROLMIP_opt_34';end
addpath(fullfile(root,folder,'rolmip'));
out=fullfile(root,'output','opt34-validation');
if strcmp(implementation,'reference'),addpath(fullfile(out,'timer_api'));end
if ~exist(fullfile(out,implementation),'dir'),mkdir(fullfile(out,implementation));end
cases=plan(allowDzero);save(fullfile(out,['plan_' implementation '.mat']),'cases');
S.c=load(fullfile(root,'baseSis_c.mat'));S.d=load(fullfile(root,'baseSis_d.mat'));
fprintf('Implementation %s, %d cases, selected %d..%d\n',implementation,numel(cases),first,min(last,numel(cases)));
for k=first:min(last,numel(cases))
 c=cases(k);id=caseid(c);dest=fullfile(out,implementation,[id '.mat']);
 if exist(dest,'file')
  previous=load(dest,'result');
  if ~strcmp(previous.result.status,'error') && ~(retryWarnings && any(strcmp(previous.result.status,{'solver_warning','feasible_solver_warning','numerical_check_failed'}))),fprintf('SKIP existing %s\n',id);continue;end
  if retryWarnings
   archive=fullfile(out,'initial_warnings');if ~exist(archive,'dir'),mkdir(archive);end
   if ~exist(fullfile(archive,[id '.mat']),'file'),copyfile(dest,fullfile(archive,[id '.mat']));end
  end
 end
 result=struct('id',id,'case',c,'status','error');
 try
  yalmip('clear');rng(341700+c.n*100+c.N*10+c.i);
  sys=S.(c.domain).BASE{c.n,c.N,c.i}.sys;
  if c.zeroD,sys.D=cellfun(@(d) zeros(size(d)),sys.D,'UniformOutput',false);end
  t=tic;rolmip_begin;[G,P,eta,geom]=validation_model(sys,c);F=[];
  for j=1:numel(G),F=[F,G{j}>=0];end
  [result.parse_seconds,result.V,result.L]=rolmip_end(F);
  nd=getvariables(eta);[basis,shapes]=canonical(G,nd);
  result.build_seconds=toc(t);result.decisions=nd;result.constraints=numel(shapes);result.rows=size(basis,1);
  assign(recover(1:nd),randn(1,nd));
  [err,~,~]=sample_check(G,P,eta,geom,sys,c,false);
  result.formula_error=err;assert(err<1e-9,'Independent formula check failed.');
  if strcmp(implementation,'reference')
   result.status='reference_built';save(dest,'result','basis','shapes','-v7');
  else
   ref=load(fullfile(out,'reference',[id '.mat']));
   assert(isequal(shapes,ref.shapes) && isequal(size(basis),size(ref.basis)),'Model dimensions differ.');
   result.model_error=norm(basis-ref.basis,inf)/max(1,norm(ref.basis,inf));
   assert(result.model_error<1e-10,'Reference affine model differs.');
   solvereps=1e-8;maxiter=150;
   if retryWarnings,solvereps=1e-7;maxiter=300;end
   result.solver_eps=solvereps;
   options=sdpsettings('solver','sedumi','verbose',0,'sedumi.eps',solvereps,'sedumi.maxiter',maxiter);
   t=tic;diagnostics=optimize(F,eta,options);result.solve_seconds=toc(t);
   result.problem=diagnostics.problem;result.info=diagnostics.info;
   result.eta=value(eta);result.bound=sqrt(max(0,result.eta));
   result.residual=NaN;result.relative_residual=NaN;result.point_residual=NaN;result.sample_lower_bound=NaN;
   if any(diagnostics.problem==[0 4]) && all(isfinite(value(recover(1:nd))))
    x=value(recover(1:nd));numeric=basis*[1;x(:)];position=0;absres=Inf;relres=Inf;
    for j=1:numel(shapes)
     n=shapes(j);M=reshape(numeric(position+(1:n*n)),n,n);position=position+n*n;
     eigmin=min(eig((M+M')/2));absres=min(absres,eigmin);relres=min(relres,eigmin/(1+norm(M,2)));
    end
    result.residual=absres;result.relative_residual=relres;
    [err,pointres,lower]=sample_check(G,P,eta,geom,sys,c,true);
    result.solved_formula_error=err;result.point_residual=pointres;result.sample_lower_bound=lower;
    if absres>=-1e-7 && relres>=-1e-7 && pointres>=-1e-7 && err<1e-8 && result.bound+1e-5*max(1,lower)>=lower
     if diagnostics.problem==0,result.status='validated';else,result.status='feasible_solver_warning';end
    else,result.status='numerical_check_failed';end
    Pvalue=cellfun(@value,coefficients(P),'UniformOutput',false);
    save(dest,'result','x','Pvalue','-v7');
   else
    if diagnostics.problem==1,result.status='infeasible_condition';else,result.status='solver_warning';end
    save(dest,'result','-v7');
   end
  end
 catch exception
  result.error=exception.message;result.stack=exception.stack;save(dest,'result');
 end
 fprintf('%d/%d %s: %s',k,numel(cases),id,result.status);
 if isfield(result,'bound'),fprintf(' bound=%.8g',result.bound);end
 if isfield(result,'error'),fprintf(' ERROR %s',result.error);end
 fprintf('\n');
end
end

function cases=plan(allowDzero)
cases=struct('domain',{},'n',{},'N',{},'i',{},'metric',{},'degree',{},'rho',{},'relax',{},'zeroD',{});
for domain={'c','d'}
 for n=2:5
  for N=2:5
   for i=1:5
    for metric={'hinf','h2'}
     zeroD=strcmp(domain{1},'c') && strcmp(metric{1},'h2');
     if zeroD && ~allowDzero,continue;end
     c=struct('domain',domain{1},'n',n,'N',N,'i',i,'metric',metric{1},'degree',0,'rho',0,'relax',0,'zeroD',zeroD);
     cases(end+1)=c;
     if i==1
      c.degree=1;cases(end+1)=c;
      if n==2 && N==2,c.relax=1;cases(end+1)=c;c.relax=0;end
      if N==2
       if strcmp(domain{1},'c'),rates=[.1 1];else,rates=[.2 .5];end
       for rho=rates,c.rho=rho;cases(end+1)=c;end
      end
     end
    end
   end
  end
 end
end
end
function id=caseid(c)
id=sprintf('%s_n%d_v%d_i%d_%s_p%d_r%g_q%d_z%d',c.domain,c.n,c.N,c.i,c.metric,c.degree,c.rho,c.relax,c.zeroD);
end
function C=coefficients(P)
C=coefs(P);if ~iscell(C),C={C};end
end
function [basis,shapes]=canonical(G,nd)
parts={};shapes=[];
for j=1:numel(G)
 C=coefficients(G{j});
 for k=1:numel(C)
  M=C{k};n=size(M,1);assert(n==size(M,2));
  if isa(M,'sdpvar')
   b=getbase(M);ids=getvariables(M);part=sparse(numel(M),nd+1);part(:,[1 ids+1])=b;
  else,part=[sparse(M(:)),sparse(numel(M),nd)];end
  parts{end+1}=part;shapes(end+1)=n;
 end
end
basis=vertcat(parts{:});
end
function [error,minimum,lower]=sample_check(G,P,eta,geom,sys,c,computeNorm)
N=c.N;tol=1e-6;n=c.n;m=size(sys.B{1},2);p=size(sys.C{1},1);
PV=cellfun(@value,coefficients(P),'UniformOutput',false);e=value(eta);
error=0;minimum=Inf;lower=0;
if c.rho>0 && strcmp(c.domain,'d'),nv=size(geom.current,2);else,nv=N;end
samples=[eye(nv),ones(nv,1)/nv];
rng(710+c.n*100+c.N*10+c.i);r=rand(nv,3);samples=[samples,r./sum(r,1)];
for j=1:size(samples,2)
 if c.rho>0 && strcmp(c.domain,'d')
  beta=samples(:,j);a=geom.current*beta;an=geom.next*beta;al={a',beta'};nu=zeros(N,1);
 else
  a=samples(:,j);an=a;al={a'};nu=zeros(N,1);
  if c.rho>0,beta=zeros(2,1);beta(mod(j-1,2)+1)=1;nu=geom.H*beta;al={a',beta'};end
 end
 A=blend(sys.A,a);B=blend(sys.B,a);C=blend(sys.C,a);D=blend(sys.D,a);
 if c.degree==0,Pa=PV{1};Pn=Pa;Pd=zeros(n);else,Pa=blend(PV,a);Pn=blend(PV,an);Pd=blend(PV,nu);end
 if strcmp(c.domain,'c')
  if strcmp(c.metric,'hinf'),K=[-A'*Pa-Pa*A-Pd,-Pa*B,-C';-B'*Pa,e*eye(m),-D';-C,-D,eye(p)];else,K=[-A'*Pa-Pa*A-Pd,C';C,eye(p)];end
 else
  if strcmp(c.metric,'hinf'),K=[Pa,zeros(n,m),A'*Pn,C';zeros(m,n),e*eye(m),B'*Pn,D';Pn*A,Pn*B,Pn,zeros(n,p);C,D,zeros(p,n),eye(p)];else,K=[Pa,A'*Pn,C';Pn*A,Pn,zeros(n,p);C,zeros(p,n),eye(p)];end
 end
 expected={Pa-tol*eye(n),K-tol*eye(size(K)),e};
 if strcmp(c.metric,'h2')
  if strcmp(c.domain,'c'),cost=trace(B'*Pa*B);else,cost=trace(B'*Pn*B+D'*D);end
  expected{end+1}=e-cost;
 end
 for k=1:numel(G)
  sg=struct(G{k});actual=value(evalpar(G{k},al(1:numel(sg.vertices))));ref=expected{k};
  error=max(error,norm(actual-ref,'fro')/max(1,norm(ref,'fro')));
  minimum=min(minimum,min(eig((ref+ref')/2))/(1+norm(ref,2)));
 end
 if computeNorm
  if strcmp(c.domain,'c'),plant=ss(A,B,C,D);else,plant=ss(A,B,C,D,1);end
  if strcmp(c.metric,'h2'),v=norm(plant,2);else,v=norm(plant,inf);end
  lower=max(lower,v);
 end
end
end
function M=blend(V,a)
M=zeros(size(V{1}));for k=1:numel(V),M=M+a(k)*V{k};end
end
