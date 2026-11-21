function results = example_model_diagnostics
%EXAMPLE_MODEL_DIAGNOSTICS Frozen-parameter stability on a two-vertex simplex.
% Requires YALMIP and SeDuMi. Run in a fresh session with this ROLMIP on path.
% This example makes no assertion about arbitrarily fast parameter variation.
yalmip('clear');
A=rolmipvar({[-2 .2;0 -1],[-1 0;.2 -3]},'A',2,1);
P=rolmipvar(2,2,'P','sym',2,1);
epsilon=1e-5;
positive=P-epsilon*eye(2);
decay=-(A'*P+P*A)-epsilon*eye(2);
results.diagnostic=rolmip_check(decay,'lmi',true);
assert(results.diagnostic.lmi_ready);
[Fp,positiveOrigin]=rolmip_lmi(positive,'>=','P positivity');
[Fd,decayOrigin]=rolmip_lmi(decay,'>=','Frozen Lyapunov');
solver=optimize([Fp,Fd],[],sdpsettings('solver','sedumi','verbose',0));
points={{[1 0]},{[0 1]},{[.5 .5]}};
results.positive=rolmip_verify(positiveOrigin,'solver',solver,'points',points);
results.decay=rolmip_verify(decayOrigin,'solver',solver,'points',points);
results.solver=solver;
assert(solver.problem==0 && results.positive.certificate_passed && results.decay.certificate_passed);
fprintf('Positivity: %s; Lyapunov: %s\n',results.positive.status,results.decay.status);
fprintf('Worst Lyapunov coefficient: %s, lambda_min = %.6g\n', ...
    results.decay.worst.tag,results.decay.worst.min_eigenvalue);
end
