function report = test_robustness_opt34(outputFile)
% Independent recursive monomial enumeration and convolution oracle.
% Requires YALMIP and this ROLMIP on path. Does not change library sources.
if nargin<1,outputFile='';end
opts=rolmipopt; cleanup=onCleanup(@() restore(opts)); %#ok<NASGU>
rng(3424,'twister');
report=struct('checks',0,'max_relative_error',0,'failures',{{}},'cases',0);
rolmipopt('codegen','off');
for v=1:6
 for d=0:6
  E=enumerate(v,d);T=generate_homogeneous_exponents(v,d);
  check(isequal(E,T),'recursive exponent order');
  check(size(T,1)==nchoosek(v+d-1,d),'monomial count');
  check(isequal(rolmipopt_index(T),(1:size(T,1))'),'independent rank order');
 end
end
check(isequal(generate_homogeneous_exponents(0,0),0),'absent simplex');
for mode={'off','on'}
 rolmipopt('codegen',mode{1});
 % Degree-zero aliases admitted by the updated constructor.
 for e={0,[0 0],[0 0 0],[0 0 0 0]}
  try
   P=rolmipvar({{e{1},7}},'P',3,0);
   near(evalpar(P,{[.2 .3 .5]}),7,'zero-degree evaluation');
   near(evalpar(P+P,{[.2 .3 .5]}),14,'zero-degree addition');
   near(evalpar(P*P,{[.2 .3 .5]}),49,'zero-degree product');
  catch err, fail(sprintf('degree-zero alias length %d, codegen %s: %s',numel(e{1}),mode{1},err.message));end
 end
 bad={@()rolmipvar(1,'P',-1,1),@()rolmipvar(1,'P',2,-1), ...
  @()rolmipvar(1,'P',2,.5),@()rolmipvar(1,'P',0,1), ...
  @()rolmipvar(1,'P',[2 3],1),@()rolmipvar(1,'P',NaN,1)};
 for k=1:numel(bad),reject(bad{k},'invalid vertices/degrees');end
 for e={[-1 2],[.5 .5],[NaN 0],[Inf 0],[1;0],[1 0 0],[],[2 0]}
  reject(@()rolmipvar({{e{1},1}},'P',2,1),'invalid exponent');
 end
 try
  P=rolmipvar({{0,[1 0],3},{0,[0 1],4}},'P',[0 2],[0 1]);
  near(evalpar(P,{1,[.25 .75]}),3.75,'absent simplex mixed polynomial');
 catch err,fail(['absent simplex mixed: ' err.message]);end
end
rolmipopt('codegen','off');
configs={2,3,4,5,[2 2],[2 3],[1 3],[2 2 2]};
budgets=[64*1024^2,8*1024^2;0,1024;1024,1024;64*1024^2,1024];
for c=1:64
 v=configs{mod(c-1,numel(configs))+1};ns=numel(v);
 if ns==1,d=randi([0 4],1,ns);q=randi([0 3],1,ns);else,d=randi([0 2],1,ns);q=randi([0 2],1,ns);end
 rows=randi(3);inner=randi(3);cols=randi(3);
 E=grid(v,d);F=grid(v,q);G=grid(v,d+q);H=grid(v,max(d,q));
 a=randn(rows,inner,size(E,1));b=randn(inner,cols,size(F,1));s=randn(rows,inner,size(F,1));
 a(:,:,rand(1,size(E,1))<.5)=0;b(:,:,rand(1,size(F,1))<.5)=0;
 expected=convolve(E,a,F,b,G);
 summed=lift(E,a,v,max(d,q)-d,H)+lift(F,s,v,max(d,q)-q,H);
 P=build(E,a,v,d,'P');Q=build(F,b,v,q,'Q');S=build(F,s,v,q,'S');
 baseline=[];
 for budget=1:size(budgets,1)
  rolmipopt('cachebytes',budgets(budget,1));rolmipopt('workbytes',budgets(budget,2));
  % Retain live objects while resizing and clearing caches.
  if mod(c,2)==0,rolmipopt('clearcache');end
  try
   R=P*Q;U=P+S;h=homogenize(P,S);
   actual=values_on_grid(R,G,v);near(actual,expected,'numeric product coefficients');
   near(values_on_grid(U,H,v),summed,'sum with independent lifting');
   near(values_on_grid(h{1},H,v),lift(E,a,v,max(d,q)-d,H),'homogenization coefficients');
   if budget==1,baseline=actual;else,check(isequal(actual,baseline),'exact equality across budgets');end
   for point=1:3
    alpha=cell(1,ns);
    for j=1:ns
     if point==1,alpha{j}=zeros(1,v(j));alpha{j}(1)=1;
     elseif point==2,alpha{j}=ones(1,v(j))/v(j);
     else,alpha{j}=rand(1,v(j));alpha{j}=alpha{j}/sum(alpha{j});end
    end
    av=evaluate(E,a,alpha);bv=evaluate(F,b,alpha);
    near(evalpar(R,alpha),av*bv,'product point identity');
    near(evalpar(U,alpha),av+evaluate(F,s,alpha),'sum point identity');
    near(evalpar(P.',alpha),av.','rectangular transpose');
   end
   st=rolmipopt('cachestats');check(st.bytes<=budgets(budget,1),'cache payload limit');
  catch err,fail(sprintf('numeric case %d, budget %d: %s',c,budget,err.message));end
 end
 report.cases=report.cases+1;
end
% Affine YALMIP coefficients compared without solving or using ROLMIP rank.
for c=1:12
 yalmip('clear');v=[2 3];d=[mod(c,2),1];q=[1,mod(c,2)];
 E=grid(v,d);F=grid(v,q);G=grid(v,d+q);
 a=randn(2,2,size(E,1));a(:,:,1)=0;
 x=sdpvar(3*size(F,1),1);b=cell(1,size(F,1));
 for k=1:numel(b),z=x(3*k-2:3*k);b{k}=[z(1),z(2);z(2),z(3)];end
 P=build(E,a,v,d,'A');M=cell(1,numel(b));
 for k=1:numel(b),M{k}=[split(F(k,:),v),{b{k}}];end
 Q=rolmipvar(M,'Q',v,q);expected=repmat({zeros(2)},1,size(G,1));
 for i=1:size(E,1),for j=1:size(F,1)
  k=find(all(G==E(i,:)+F(j,:),2));expected{k}=expected{k}+a(:,:,i)*b{j};
 end,end
 for budget=1:size(budgets,1)
  rolmipopt('cachebytes',budgets(budget,1));rolmipopt('workbytes',budgets(budget,2));
  try
   R=struct(P*Q);
   for k=1:numel(R.data)
    delta=R.data(k).value-expected{k};
    if isa(delta,'sdpvar'),delta=full(getbase(delta));end
    near(delta,zeros(size(delta)),'symbolic affine coefficient difference');
   end
  catch err,fail(sprintf('symbolic case %d budget %d: %s',c,budget,err.message));end
 end
 report.cases=report.cases+1;
end
report.passed=isempty(report.failures);
fprintf('ROBUSTNESS: %d cases, %d checks, max relative error %.3g, %d failures\n',report.cases,report.checks,report.max_relative_error,numel(report.failures));
if ~isempty(outputFile),fid=fopen(outputFile,'w');fprintf(fid,'%s',jsonencode(report));fclose(fid);end
if ~report.passed,error('ROLMIP:RobustnessFailure','%d failed checks; see report.',numel(report.failures));end
 function check(ok,label)
  report.checks=report.checks+1;if ~ok,fail(label);end
 end
 function near(a,b,label)
  er=norm(a(:)-b(:))/max(1,norm(b(:)));report.max_relative_error=max(report.max_relative_error,er);
  check(isfinite(er)&&er<1e-10,label);
 end
 function fail(label)
  report.failures{end+1}=label;fprintf('[FAIL] %s\n',label);
 end
 function reject(fun,label)
  caught=false;try,fun();catch,caught=true;end;check(caught,label);
 end
end
function T=enumerate(v,d)
if v==1,T=d;return;end
T=[];for k=d:-1:0,R=enumerate(v-1,d-k);T=[T;k*ones(size(R,1),1),R];end %#ok<AGROW>
end
function E=grid(v,d)
E=zeros(1,0);for j=1:numel(v),T=enumerate(v(j),d(j));E=[repmat(E,size(T,1),1),kron(T,ones(size(E,1),1))];end
end
function cells=split(e,v)
cells=cell(1,numel(v));offset=0;for j=1:numel(v),cells{j}=e(offset+(1:v(j)));offset=offset+v(j);end
end
function P=build(E,a,v,d,label)
M=cell(1,size(E,1));for k=1:numel(M),M{k}=[split(E(k,:),v),{a(:,:,k)}];end
P=rolmipvar(M,label,v,d);
end
function out=convolve(E,a,F,b,G)
sample=a(:,:,1)*b(:,:,1);out=zeros(size(sample,1),size(sample,2),size(G,1));
for i=1:size(E,1),for j=1:size(F,1),k=find(all(G==E(i,:)+F(j,:),2));out(:,:,k)=out(:,:,k)+a(:,:,i)*b(:,:,j);end,end
end
function out=lift(E,a,v,delta,H)
F=grid(v,delta);w=ones(1,size(F,1));off=0;
for j=1:numel(v),w=w.*(factorial(delta(j))./prod(factorial(F(:,off+(1:v(j)))),2)).';off=off+v(j);end
b=reshape(w,1,1,[]);out=convolve(E,a,F,b,H);
end
function out=values_on_grid(P,G,v)
s=struct(P);out=zeros(size(s.data(1).value,1),size(s.data(1).value,2),size(G,1));
for i=1:numel(s.data),e=[];for j=1:numel(v),z=s.data(i).exponent{j};if all(z==0),z=zeros(1,v(j));end;e=[e,z];end;k=find(all(G==e,2));assert(isscalar(k));out(:,:,k)=s.data(i).value;end
end
function out=evaluate(E,a,alpha)
w=prod([alpha{:}].^E,2);out=zeros(size(a,1),size(a,2));for k=1:numel(w),out=out+w(k)*a(:,:,k);end
end
function restore(opts)
rolmipopt('codegen',opts.codegen);rolmipopt('cachebytes',opts.cachebytes);rolmipopt('workbytes',opts.workbytes);rolmipopt('clearcache');
end
