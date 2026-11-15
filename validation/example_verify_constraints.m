function result = example_verify_constraints
%EXAMPLE_VERIFY_CONSTRAINTS Verify all LMIs without polynomial provenance.
% Requires YALMIP and SeDuMi. Add this checkout's rolmip and validation folders.
yalmip('clear');
A=rolmipvar({[-2 .2;0 -1],[-1 0;.2 -3]},'A',2,1);
P=rolmipvar(2,2,'P','sym',2,1);
z=sdpvar(1);
% Includes coefficient LMIs and direct YALMIP inequalities/equalities.
LMIs=[P>=1e-5*eye(2),A'*P+P*A<=-1e-5*eye(2),z>=0,z==1];
solution=optimize(LMIs,[],sdpsettings('solver','sedumi','verbose',0));
result=rolmip_verify(LMIs,'solver',solution);
assert(solution.problem==0 && result.constraints_passed);
fprintf('%s: %d constraint blocks inspected.\n',result.status,result.constraint_count);
if ~isempty(result.worst)
 fprintf('Worst evaluated relative residual: constraint %d (%s), %.6g\n', ...
  result.worst.index,result.worst.kind,result.worst.relative_residual);
end
end
