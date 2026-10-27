function [G,P,eta,geom]=validation_model(sys,c)
n=c.n;N=c.N;m=size(sys.B{1},2);p=size(sys.C{1},1);tol=1e-6;
A=rolmipvar(sys.A,'A',N,1);B=rolmipvar(sys.B,'B',N,1);
C=rolmipvar(sys.C,'C',N,1);D=rolmipvar(sys.D,'D',N,1);
P=rolmipvar(n,n,'P','sym',N,c.degree);eta=sdpvar(1);E=rolmipvar(eta,'eta');
Pc=P;Pn=P;dotP=rolmipvar(zeros(n),'dotP');geom=struct('H',[],'current',[],'next',[]);
if c.rho>0
 if strcmp(c.domain,'c')
  dotP=diff(P,repmat([-c.rho c.rho],N,1));
  test=diff(rolmipvar([1 0],'alpha',2,1),repmat([-c.rho c.rho],N,1));
  h=[evalpar(test,{[1 0],[1 0]}),evalpar(test,{[1 0],[0 1]})];
  assert(norm(sort(h)-[-c.rho c.rho],inf)<1e-10);geom.H=[h;-h];
 else
  shifts=discshift(P,1,repmat([-c.rho c.rho],N,1));Pc=shifts{1};Pn=shifts{2};
  q=discshift(rolmipvar([1 0],'alpha',2,1),1,repmat([-c.rho c.rho],N,1));
  a=cell2mat(coefficients(q{1}));b=cell2mat(coefficients(q{2}));geom.current=[a;1-a];geom.next=[b;1-b];
  assert(max(abs(geom.next(:)-geom.current(:)))<=c.rho+1e-9);
  A=simpltransf(A,1,2,geom.current);B=simpltransf(B,1,2,geom.current);
  C=simpltransf(C,1,2,geom.current);D=simpltransf(D,1,2,geom.current);
 end
end
if strcmp(c.domain,'c')
 if strcmp(c.metric,'hinf')
  K=[-A'*Pc-Pc*A-dotP, -Pc*B, -C';-B'*Pc,E*eye(m),-D';-C,-D,eye(p)];
 else
  K=[-A'*Pc-Pc*A-dotP,C';C,eye(p)];
 end
else
 if strcmp(c.metric,'hinf')
  K=[Pc,zeros(n,m),A'*Pn,C';zeros(m,n),E*eye(m),B'*Pn,D';Pn*A,Pn*B,Pn,zeros(n,p);C,D,zeros(p,n),eye(p)];
 else
  K=[Pc,A'*Pn,C';Pn*A,Pn,zeros(n,p);C,zeros(p,n),eye(p)];
 end
end
ks=struct(K);nk=size(ks.data(1).value,1);
G={Pc-tol*eye(n),K-tol*eye(nk),E};
if strcmp(c.metric,'h2')
 if strcmp(c.domain,'c'),cost=trace(B'*Pc*B);else,cost=trace(B'*Pn*B+D'*D);end
 G{end+1}=E-cost;
end
if c.relax>0
 for j=1:numel(G)
  sg=struct(G{j});
  if any(sg.vertices>0),G{j}=polya(G{j},c.relax);end
 end
end
end
function C=coefficients(P)
C=coefs(P);if ~iscell(C),C={C};end
end
