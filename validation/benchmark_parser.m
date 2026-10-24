function benchmark_parser(implementation)
% Seven warm measurements per case; two discarded warmups. No solver.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-validation');
restoredefaultpath;addpath(fullfile(root,'ROLMIP_opt_34','validation'));
addpath(genpath('/home/ricfow/.cache/rolmip-review/YALMIP'));
addpath(genpath('/home/ricfow/Dropbox/toolboxes/MPT/mpt'));addpath(genpath('/home/ricfow/Dropbox/toolboxes/MPT/cddmex'));mptopt('lpsolver','cdd');
if strcmp(implementation,'reference')
 addpath(fullfile(root,'ROLMIP_github','rolmip'));addpath(fullfile(out,'timer_api'));
else
 addpath(fullfile(root,'ROLMIP_opt_34','rolmip'));rolmipopt('codegen','off');
end
S.c=load(fullfile(root,'baseSis_c.mat'));S.d=load(fullfile(root,'baseSis_d.mat'));plan=load(fullfile(out,['plan_' implementation '.mat']));
records={};nrep=7;nwarm=2;
for k=1:numel(plan.cases)
 c=plan.cases(k);id=sprintf('%s_n%d_v%d_i%d_%s_p%d_r%g_q%d_z%d',c.domain,c.n,c.N,c.i,c.metric,c.degree,c.rho,c.relax,c.zeroD);
 sys=S.(c.domain).BASE{c.n,c.N,c.i}.sys;
 if c.zeroD,sys.D=cellfun(@(d) zeros(size(d)),sys.D,'UniformOutput',false);end
 times=zeros(1,nrep);Vs=zeros(1,nrep);Ls=zeros(1,nrep);
 for j=1:(nwarm+nrep)
  yalmip('clear');
  rolmip_begin;
  [G,P,eta,geom]=validation_model(sys,c); %#ok<ASGLU>
  F=[];for q=1:numel(G),F=[F,G{q}>=0];end
  [seconds,V,L]=rolmip_end(F);
  if j>nwarm,times(j-nwarm)=seconds;Vs(j-nwarm)=V;Ls(j-nwarm)=L;end
 end
 baseline=load(fullfile(out,implementation,[id '.mat']),'result');
 assert(all(Vs==baseline.result.V) && all(Ls==baseline.result.L));
 % Compare final repeated construction with all affine coefficients, untimed.
 ref=load(fullfile(out,'reference',[id '.mat']));nd=getvariables(eta);pos=0;shapeidx=0;err=0;
 for q=1:numel(G)
  C=coefs(G{q});if ~iscell(C),C={C};end
  for h=1:numel(C)
   M=C{h};shapeidx=shapeidx+1;assert(size(M,1)==ref.shapes(shapeidx));
   part=sparse(numel(M),nd+1);
   if isa(M,'sdpvar'),part(:,[1 getvariables(M)+1])=getbase(M);else,part(:,1)=M(:);end
   err=max(err,norm(part-ref.basis(pos+(1:numel(M)),:),inf));pos=pos+numel(M);
  end
 end
 assert(pos==size(ref.basis,1) && err==0);
 records{end+1}=struct('id',id,'case',c,'seconds',times,'median_seconds',median(times),'min_seconds',min(times),'max_seconds',max(times),'V',V,'L',L,'model_error',err,'warmups',nwarm,'repetitions',nrep);
 fprintf('%d/%d %s median %.6g s, V=%d L=%d\n',k,numel(plan.cases),id,median(times),V,L);
end
fid=fopen(fullfile(out,['timings_' implementation '.json']),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
end
