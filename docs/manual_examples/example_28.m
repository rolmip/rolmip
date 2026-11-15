rolmip_begin;
rolmip_check_begin;
A = rolmipvar({[-2 0.2;0 -1],[-1 0;0.2 -3]},'A',2,1);
P = rolmipvar(2,2,'P','sym',2,1);
margin = 1e-5*eye(2);
[F,origin] = rolmip_lmi(A'*P + P*A + margin,'<=','Lyapunov');
LMIs = [P >= margin, F];
diagnosis = rolmip_check_end;
[time,V,L] = rolmip_end(LMIs);
if ~diagnosis.has_errors
    options = sdpsettings('verbose',0);
    solution = optimize(LMIs,[],options);
    verification = rolmip_verify(LMIs,'solver',solution);
    midpoint = {{[0.5 0.5]}};
    lyapunov = rolmip_verify(origin,'solver',solution,'points',midpoint);
end
