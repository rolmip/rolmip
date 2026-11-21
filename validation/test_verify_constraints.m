function test_verify_constraints
% Direct YALMIP checks must match check(F), preserve values and report gaps.
yalmip('clear');
X=sdpvar(2);x=sdpvar(2,1);z=sdpvar(1);
F=[tag(X>=eye(2),'PSD'),tag(x<=[3;4],'Upper bounds'),tag(z==5,'Equality')];
r=rolmip_verify(F);assert(~r.constraints_passed&&strcmp(r.status,'not_evaluable'));
assert(numel(r.unevaluable_indices)==3);
assign(X,[2 .2;.2 3]);assign(x,[1;2]);assign(z,5);
before=[value(X(:));value(x);value(z)];
r=rolmip_verify(F,'solver',struct('problem',0,'info','Solved'));
assert(r.constraints_passed&&r.all_evaluable&&numel(r.constraints)==3);
assert(strcmp(r.constraints(1).kind,'sdp')&&r.constraints(1).order==2);
assert(strcmp(r.constraints(2).kind,'elementwise'));
assert(strcmp(r.constraints(3).kind,'equality'));
assert(strcmp(r.constraints(1).tag,'PSD'));
assert(norm([r.constraints.residual].'-check(F))<1e-12);
assert(isequal(before,[value(X(:));value(x);value(z)]));
assign(X,[0 0;0 2]);assign(x,[4;2]);assign(z,5.1);
r=rolmip_verify(F,'solver',struct('problem',0));
assert(strcmp(r.status,'constraints_failed')&&isequal(r.violated_indices,1:3));
assert(norm([r.constraints.residual].'-check(F))<1e-12);
assert(abs(r.constraints(2).residual+1)<1e-12);
assert(abs(r.constraints(3).residual+.1)<1e-12);
assign(X,eye(2));assign(x,[1;2]);assign(z,5+1e-9);
r=rolmip_verify(F);assert(r.constraints_passed);
r=rolmip_verify(F,'abs_tol',0,'rel_tol',0);assert(isequal(r.violated_indices,3));
r=rolmip_verify(F,'solver',struct('problem',4,'info','Warning'));
assert(strcmp(r.status,'constraints_passed_solver_warning')&&r.solver.warning);
% Single constraint, nonsymmetric matrix interpreted elementwise, empty sets.
G=(x>=0);r=rolmip_verify(G);assert(r.constraints_passed&&r.constraint_count==1);
Y=sdpvar(2,2,'full');G=Y>=0;assign(Y,[1 2;0 1]);r=rolmip_verify(G);
assert(r.constraints_passed&&strcmp(r.constraints.kind,'elementwise'));
r=rolmip_verify([]);assert(strcmp(r.status,'empty_set')&&~r.constraints_passed);
r=rolmip_verify(zeros(0,2));assert(strcmp(r.status,'empty_set')&&r.constraint_count==0);
r=rolmip_verify(F([]));assert(strcmp(r.status,'empty_set'));
expect(@()rolmip_verify(false),'ROLMIP:VerifyInput');
expect(@()rolmip_verify(1),'ROLMIP:VerifyInput');
expect(@()rolmip_verify(F,'points',{{[.5 .5]}}),'ROLMIP:PointsNeedOrigin');
expect(@()rolmip_verify(F,'solver',struct('info','missing')),'ROLMIP:SolverDiagnostics');
% Unsupported constraints and complex equalities must prevent full approval.
t=sdpvar(1);a=sdpvar(2,1);G=[F,cone(a,t)];assign(t,2);assign(a,[0;0]);
r=rolmip_verify(G);assert(strcmp(r.status,'unsupported_constraints')&&~r.constraints_passed);
assert(isequal(r.unsupported_indices,4)&&numel(r.constraints)==4);
w=sdpvar(1);assign(w,NaN);r=rolmip_verify([F,w>=0]);
assert(strcmp(r.status,'not_evaluable')&&isequal(r.unevaluable_indices,4));
assign(w,Inf);r=rolmip_verify(w>=0);assert(~r.constraints_passed&&~r.all_evaluable);
H=sdpvar(2,2,'hermitian','complex');G=H>=0;assign(H,[1 1i;-1i 1]);
r=rolmip_verify(G);assert(strcmp(r.status,'unsupported_constraints')&&~r.constraints_passed);
% ROLMIP-generated coefficient constraints need no provenance.
P=rolmipvar(2,2,'P','sym',2,1);[G,origin]=rolmip_lmi(P,'>=','P');
for k=1:numel(origin.entries),assign(origin.entries(k).coefficient,eye(2));end
r=rolmip_verify(G);specific=rolmip_verify(origin);
assert(r.constraints_passed&&specific.certificate_passed);
assert(norm([r.constraints.min_eigenvalue]-[specific.coefficients.min_eigenvalue])<1e-12);
if ~isempty(which('sedumi'))
 yalmip('clear');X=sdpvar(2);z=sdpvar(1);
 G=[X>=eye(2),z>=0,z==1];d=optimize(G,trace(X),sdpsettings('solver','sedumi','verbose',0));
 r=rolmip_verify(G,'solver',d,'abs_tol',1e-7);
 assert(d.problem==0&&r.constraints_passed);
 fprintf('[ok] direct whole-model verification after SeDuMi solve\n');
end
fprintf('VERIFY_CONSTRAINTS_TEST_PASSED\n');
end
function expect(fun,id)
try,fun();catch e,assert(strcmp(e.identifier,id),'Unexpected error: %s',e.message);return;end
error('Test:MissingError','Expected %s',id);
end
