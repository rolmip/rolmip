function check_transferred_certificate
% Verify an existing rate-bounded certificate on the frozen affine model.
% Keep the unsuccessful optimizer output intact; this is a separate certificate.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-validation');
target='d_n4_v2_i1_hinf_p1_r0_q0_z0';source='d_n4_v2_i1_hinf_p1_r0.2_q0_z0';
t=load(fullfile(out,'reference',[target '.mat']));s=load(fullfile(out,'opt',[source '.mat']));
assert(strcmp(s.result.status,'validated'));assert(size(t.basis,2)==numel(s.x)+1);
assert(s.result.case.n==t.result.case.n && s.result.case.N==t.result.case.N);
% P is constructed first with identical n,N,degree; eta is constructed last.
% Thus the global decision ordering is identical before rate transformations.
v=t.basis*[1;s.x(:)];pos=0;res=Inf;rel=Inf;
for j=1:numel(t.shapes)
 n=t.shapes(j);M=reshape(v(pos+(1:n*n)),n,n);pos=pos+n*n;
 e=min(eig((M+M')/2));res=min(res,e);rel=min(rel,e/(1+norm(M,2)));
end
% Direct physical check, independent of polynomial evaluation.
b=load(fullfile(root,'baseSis_d.mat'));sys=b.BASE{4,2,1}.sys;P=s.Pvalue;eta=s.result.eta;
rng(710+4*100+2*10+1);a=rand(2,3);a=[eye(2),[.5;.5],a./sum(a,1)];point=Inf;lower=0;
for k=1:size(a,2)
 A=blend(sys.A,a(:,k));B=blend(sys.B,a(:,k));C=blend(sys.C,a(:,k));D=blend(sys.D,a(:,k));Pa=blend(P,a(:,k));
 n=size(A,1);m=size(B,2);p=size(C,1);
 K=[Pa,zeros(n,m),A'*Pa,C';zeros(m,n),eta*eye(m),B'*Pa,D';Pa*A,Pa*B,Pa,zeros(n,p);C,D,zeros(p,n),eye(p)];
 for M={Pa-1e-6*eye(n),K-1e-6*eye(size(K)),eta}
  H=M{1};point=min(point,min(eig((H+H')/2))/(1+norm(H,2)));
 end
 lower=max(lower,norm(ss(A,B,C,D,1),inf));
end
bound=sqrt(eta);passed=res>=-1e-7 && rel>=-1e-7 && point>=-1e-7 && bound+1e-5*max(1,lower)>=lower;
r=struct('target',target,'source',source,'status','transferred_certificate','passed',passed,'eta',eta,'bound',bound,'residual',res,'relative_residual',rel,'point_residual',point,'sample_lower_bound',lower,'optimality_claim',false);
fid=fopen(fullfile(out,'transferred_certificate.json'),'w');fprintf(fid,'%s',jsonencode(r));fclose(fid);
x=s.x;Pvalue=P;save(fullfile(out,'transferred_certificate.mat'),'r','x','Pvalue');
disp(r);assert(passed,'Transferred certificate failed independent validation.');
end
function M=blend(V,a)
M=zeros(size(V{1}));for j=1:numel(V),M=M+a(j)*V{j};end
end
