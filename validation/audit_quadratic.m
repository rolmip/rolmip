function audit_quadratic
% Independent common Lyapunov certificate, without ROLMIP operations.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-validation');
restoredefaultpath;
addpath(genpath('/home/ricfow/.cache/rolmip-review/YALMIP'));
addpath(genpath('/home/ricfow/Dropbox/MatLab/andre/andre_08set26/Solvers/SeDuMi'));
records={};inventory={};
for domain={'c','d'}
 s=load(fullfile(root,['baseSis_' domain{1} '.mat']));
 for n=2:5
  for N=2:5
   for i=1:5
    yalmip('clear');sys=s.BASE{n,N,i}.sys;P=sdpvar(n);F=P>=eye(n);
    for j=1:N
     A=sys.A{j};
     if strcmp(domain{1},'c'),F=[F,-A'*P-P*A>=eye(n)];else,F=[F,P-A'*P*A>=eye(n)];end
    end
    opts=sdpsettings('solver','sedumi','verbose',0,'sedumi.eps',1e-8);
    sol=optimize(F,trace(P),opts);Pv=value(P);res=-Inf;
    if all(isfinite(Pv(:)))
     res=min(eig((Pv+Pv')/2-eye(n)));
     for j=1:N
      A=sys.A{j};if strcmp(domain{1},'c'),M=-A'*Pv-Pv*A;else,M=Pv-A'*Pv*A;end
      res=min(res,min(eig((M+M')/2-eye(n))));
     end
    end
    records{end+1}=struct('domain',domain{1},'n',n,'N',N,'i',i,'problem',sol.problem,'residual',res,'passed',sol.problem==0 && res>=-1e-6,'P',Pv);
    inventory{end+1}=struct('domain',domain{1},'n',n,'N',N,'i',i,'Dmax',max(cellfun(@(d) norm(d,'fro'),sys.D)),'nw',size(sys.B{1},2),'nz',size(sys.C{1},1));
   end
  end
 end
end
fid=fopen(fullfile(out,'quadratic_certificates.json'),'w');fprintf(fid,'%s',jsonencode(records));fclose(fid);
fid=fopen(fullfile(out,'inventory.json'),'w');fprintf(fid,'%s',jsonencode(inventory));fclose(fid);
fprintf('Common quadratic certificates: %d / %d passed.\n',sum(cellfun(@(r) r.passed,records)),numel(records));
end
