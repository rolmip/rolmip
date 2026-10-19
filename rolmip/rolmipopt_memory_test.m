function rolmipopt_memory_test
% Assert cache accounting, eviction, transposed reuse and chunk equivalence.
opts=rolmipopt;cleanup=onCleanup(@() restore_options(opts)); %#ok<NASGU>
rolmipopt('codegen','off');rolmipopt('clearcache');
rolmipopt('cachebytes',1024);
rolmipopt_exptable(3,3);rolmipopt_exptable(4,3);rolmipopt_exptable(5,2);
s=rolmipopt('cachestats');assert(s.bytes<=1024 && s.evictions>0);
rolmipopt('cachebytes',0);s=rolmipopt('cachestats');assert(s.bytes==0 && s.entries==0);
rolmipopt_exptable(3,3);rolmipopt_exptable(3,3);
s=rolmipopt('cachestats');assert(s.bytes==0);
rolmipopt('cachebytes',1024^2);rolmipopt('workbytes',1024^2);rolmipopt('clearcache');
A=rolmipopt_prodtable(3,2,3);s=rolmipopt('cachestats');
B=rolmipopt_prodtable(3,3,2);t=rolmipopt('cachestats');
assert(isequal(A,B.') && s.bytes==t.bytes && t.hits>s.hits);
[L,w]=rolmipopt_lifttable(3,2,3);assert(isequal(A,L) && sum(w)==27);
rolmipopt('clearcache');rolmipopt('workbytes',1024);rolmipopt('cachebytes',0);
assert(isequal(A,rolmipopt_prodtable(3,2,3)));
% Independent oracle: look up summed exponent rows, without using rank.
T1=rolmipopt_exptable(3,2);T2=rolmipopt_exptable(3,3);TR=rolmipopt_exptable(3,5);
for i=1:size(T1,1)
 for j=1:size(T2,1)
  k=find(all(TR==T1(i,:)+T2(j,:),2));assert(isscalar(k) && A(i,j)==k);
 end
end
rng(3417,'twister');P=rolmipvar(randn(2,70),'P',5,3);Q=rolmipvar(randn(2,70),'Q',5,3);
rolmipopt('workbytes',8*1024^2);reference=coefs(P*Q);
rolmipopt('workbytes',1024);actual=coefs(P*Q);assert(isequal(reference,actual));
% Sparse active support, multi-simplex and scalar zero preserve the grid.
P=rolmipvar({{[2 0],[1 0],eye(2)}},'P',[2 2],[2 1]);
Q=rolmipvar({{[0 1],[0 2],ones(2)}},'Q',[2 2],[1 2]);
rolmipopt('workbytes',8*1024^2);reference=coefs(P*Q);
rolmipopt('workbytes',1024);assert(isequal(reference,coefs(P*Q)));
a={[.3 .7],[.6 .4]};assert(norm(evalpar(P*Q,a)-evalpar(P,a)*evalpar(Q,a),'fro')<1e-12);
Z=rolmipvar(0,'zero');assert(all(cellfun(@(x) ~any(x(:)),coefs(Z*P))));
rolmipopt('clearcache');s=rolmipopt('cachestats');assert(s.bytes==0 && s.hits==0 && s.misses==0);
fprintf('ROLMIPOPT_MEMORY_TEST: cache budgets, eviction, symmetry, chunking and exact coefficient equivalence passed.\n');
end
function restore_options(opts)
rolmipopt('cachebytes',opts.cachebytes);rolmipopt('workbytes',opts.workbytes);
rolmipopt('codegen',opts.codegen);rolmipopt('clearcache');
end
