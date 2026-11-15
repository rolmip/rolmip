function test_model_diagnostics
% Tests require YALMIP; SeDuMi adds an actual solved-certificate test.
old=rolmipopt('codegen');cleanup=onCleanup(@()rolmipopt('codegen',old)); %#ok<NASGU>
rolmipopt('codegen','off');yalmip('clear');
% Valid intermediate rectangular polynomials are not automatically LMIs.
P=rolmipvar(ones(2,3),'rect');r=rolmip_check(P);
assert(r.valid && ~r.lmi_ready && ~r.symmetric);
r=rolmip_check(P,'lmi',true);assert(~r.valid);
expect(@()rolmip_lmi(P,'>=','rect'),'ROLMIP:InvalidLMI');
P=rolmipvar(eye(2),'I');r=rolmip_check(P);assert(r.valid && r.lmi_ready);
s=struct(P);s.dims=[3 3];r=rolmip_check(s);assert(has(r,'StoredDimensions'));
s=struct(P);s.data(1).value(1)=NaN;r=rolmip_check(s);assert(has(r,'NonfiniteCoefficient'));
s=struct(P);s.data(1).value(1)=Inf;r=rolmip_check(s);assert(has(r,'NonfiniteCoefficient'));
s=struct(P);s.data(1).exponent={-1};r=rolmip_check(s);assert(has(r,'ExponentValues'));
s=struct(P);s.data(2)=s.data(1);r=rolmip_check(s);assert(has(r,'DuplicateMonomial'));
s=struct(P);s.vertices=-1;r=rolmip_check(s);assert(has(r,'Vertices'));
s=struct(P);s.data(1).exponent={1};r=rolmip_check(s);assert(has(r,'AbsentSimplexDegree'));
P=rolmipvar([eye(2),2*eye(2)],'A',2,1);s=struct(P);s.data(2).exponent={[2 0]};
r=rolmip_check(s);assert(has(r,'NotHomogeneous'));
r=rolmip_check(42);assert(~r.valid);
% A quadratic uncertain-parameter degree is fine; quadratic decisions are not.
x=sdpvar(1);P=rolmipvar({{[2 0],x*eye(2)}},'P',2,2);
r=rolmip_check(P,'lmi',true);assert(r.lmi_ready && isequal(r.degree,2));
P=rolmipvar(x^2*eye(2),'BMI');r=rolmip_check(P,'lmi',true);
assert(~r.lmi_ready && has(r,'NonAffineDecision'));
expect(@()rolmip_lmi(P,'>=','BMI'),'ROLMIP:InvalidLMI');
P=rolmipvar(abs(x)*eye(2),'extended');r=rolmip_check(P,'lmi',true);assert(~r.lmi_ready);
P=rolmipvar([x 1;0 x],'nonsym');expect(@()rolmip_lmi(P,'>=','bad'),'ROLMIP:InvalidLMI');
P=rolmipvar(1i*eye(2),'complex');r=rolmip_check(P,'lmi',true);assert(~r.lmi_ready&&has(r,'NotReal'));
fprintf('[ok] diagnostics: structure, degrees, symmetry, nonfinite data and decision affinity\n');
% Trace entries must match the existing operator and carry their YALMIP tags.
for mode={'off','on'}
 rolmipopt('codegen',mode{1});
 P=rolmipvar(2,2,'P','sym',2,1);
 for relation={'>=','<='}
  if strcmp(relation{1},'>='),legacy=P>=0;else,legacy=P<=0;end
  [F,t]=rolmip_lmi(P,relation{1},'Stability');
  assert(length(F)==length(legacy)&&numel(t.entries)==2);
  info=lmiinfo(F);assert(t.V==numel(getvariables(F))&&t.L==sum(info.sdp(:,1)));
  for k=1:length(F)
   delta=sdpvar(F(k))-sdpvar(legacy(k));assert(norm(full(getbase(delta)),'fro')==0);
   assert(strcmp(tag(F(k)),t.entries(k).tag));
   assert(isequal(t.entries(k).constraint_index,k));
  end
 end
end
rolmipopt('codegen','off');
P=rolmipvar(2,2,'multi','sym',[2 3],[1 2]);[F,t]=rolmip_lmi(P,'>=','Multi');
assert(numel(t.entries)==12 && isequal(t.degree,[1 2]));
for k=1:12,assert(numel(t.entries(k).exponents)==2 && t.entries(k).order==2);end
for k=1:12,assign(t.entries(k).coefficient,eye(2));end
r=rolmip_verify(t,'points',{{[.25 .75],[.2 .3 .5]}});assert(r.certificate_passed&&r.samples_passed);
% Reordering F does not change origin's retained expressions; indices stay local.
reverse=F(end:-1:1);assert(strcmp(tag(reverse(1)),t.entries(end).tag));

% Constants use matrix PSD semantics, never elementwise numeric comparisons.
P=rolmipvar([1 -1;-1 1],'PSD');[F,t]=rolmip_lmi(P,'>=','Constant');
assert(isempty(F)&&strcmp(t.entries.kind,'constant_psd'));
r=rolmip_verify(t);assert(r.certificate_passed);
expect(@()rolmip_lmi(rolmipvar([1 2;2 1],'bad'),'>=','bad'),'ROLMIP:ConstantInfeasible');
[F,t]=rolmip_lmi(rolmipvar(-eye(2),'neg'),'<=','Negative');assert(isempty(F));
r=rolmip_verify(t);assert(r.certificate_passed);
expect(@()rolmip_lmi(rolmipvar(uint8(1),'Integer'),'<=' ,'Integer'),'ROLMIP:ConstantInfeasible');
x=sdpvar(1);[F,t]=rolmip_lmi(rolmipvar(x,'ScalarP'),'>=','Scalar');
assert(t.L==0 && strcmp(t.entries.kind,'elementwise'));
P=rolmipvar({{[1 0],x},{[0 1],0}},'mixed',2,1);[F,t]=rolmip_lmi(P,'>=','Mixed');
assert(length(F)==1 && isempty(t.entries(2).constraint_index));
expect(@()rolmip_lmi(P,'>','Strict'),'ROLMIP:TraceRelation');
fprintf('[ok] trace: operator equivalence, tags, multiple simplexes and constant/scalar blocks\n');
% Unassigned values and failed coefficients cannot be hidden by good samples.
yalmip('clear');x=sdpvar(1);P=rolmipvar({{[1 0],x*eye(2)},{[0 1],eye(2)}},'P',2,1);
[F,t]=rolmip_lmi(P,'>=','Certificate');r=rolmip_verify(t);
assert(strcmp(r.status,'not_evaluable') && ~r.certificate_passed);
assign(x,-1);r=rolmip_verify(t,'points',{{[.5 .5]}});
assert(strcmp(r.status,'certificate_failed')&&r.samples_passed&&r.worst.monomial==1);
r=rolmip_verify(t,'solver',struct('problem',0));assert(~r.certificate_passed);
assign(x,2);r=rolmip_verify(t,'points',{{[1 0]},{[0 1]},{[.5 .5]}});
assert(r.certificate_passed&&r.samples_passed&&~r.optimality_checked);
assert(abs(r.samples(3).result.min_eigenvalue-1.5)<1e-12);
r=rolmip_verify(t,'solver',struct('problem',4,'info','Numerical warning'));
assert(strcmp(r.status,'certificate_passed_solver_warning')&&r.solver.warning);
assign(x,-1e-9);r=rolmip_verify(t);assert(r.certificate_passed);
r=rolmip_verify(t,'abs_tol',0,'rel_tol',0);assert(~r.certificate_passed);
expect(@()rolmip_verify(t,'points',{{[-.1 1.1]}}),'ROLMIP:SamplePoint');
expect(@()rolmip_verify(t,'points',{{[.2 .2]}}),'ROLMIP:SamplePoint');
expect(@()rolmip_verify(t,'solver',struct('info','no code')),'ROLMIP:SolverDiagnostics');
% Check actual residuals and symmetry, not just solver status.
assign(x,2);bad=t;bad.entries(1).coefficient=[1 1;0 1];r=rolmip_verify(bad);
assert(~r.certificate_passed&&strcmp(r.coefficients(1).status,'not_symmetric'));
bad=t;bad.entries(1).coefficient=NaN(2);r=rolmip_verify(bad);assert(strcmp(r.status,'not_evaluable'));
r=rolmip_verify(t,'abs_tol',realmax,'rel_tol',realmax);assert(strcmp(r.status,'not_evaluable'));
% Explicit tests for constant single/absent simplexes and high scales.
[F,constant]=rolmip_lmi(rolmipvar(1e200*eye(2),'Large'),'>=','Large');
r=rolmip_verify(constant,'points',{{1}});assert(r.certificate_passed&&r.samples_passed);
if ~isempty(which('sedumi'))
 yalmip('clear');x=sdpvar(1);P=rolmipvar((x-2)*eye(2),'Bound');[F,t]=rolmip_lmi(P,'>=','Bound');
 d=optimize(F,x,sdpsettings('solver','sedumi','verbose',0));
 r=rolmip_verify(t,'solver',d,'abs_tol',1e-7);
 assert(d.problem==0&&r.certificate_passed&&abs(value(x)-2)<1e-5);
 fprintf('[ok] actual SDP solution verified with SeDuMi\n');
else,fprintf('[skip] SeDuMi solve; all assigned-value tests performed\n');end
fprintf('MODEL_DIAGNOSTICS_TEST_PASSED\n');
end
function yes=has(r,code),yes=any(strcmp({r.issues.code},code));end
function expect(fun,id)
try,fun();catch e,assert(strcmp(e.identifier,id),'Unexpected error: %s',e.message);return;end
error('Test:MissingError','Expected %s',id);
end
