function [gamma,report] = Algorithm_1_Section_6(degP,d)
% H-infinity bound for the mass-spring example in Section 7.2.
if nargin < 1, degP = 1; end
if nargin < 2, d = [0 0 0]; end

A = {{[0 0 0],[0 0 1 0;0 0 0 1;0 0 0 0;0 0 0 0]}, ...
     {[1 0 0],[0 0 0 0;0 0 0 0;-2 1 0 0;0 0 0 0]}, ...
     {[1 0 1],[0 0 0 0;0 0 0 0;0 0 -1 0;0 0 0 0]}, ...
     {[0 1 0],[0 0 0 0;0 0 0 0;0 0 0 0;1 -1 0 0]}, ...
     {[0 1 1],[0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 -1]}};
Ai = rolmipvar(A,'A',[2/3 2;0.8 4/3;1 3]);
B = {{[1],[0;0;1;0]}};
Bi = rolmipvar(B,'B',[2/3 2]);
Ci = rolmipvar([0 1 0 0],'C');
Di = rolmipvar(0,'D');
Pi = rolmipvar(4,4,'P','sym',[2 2 2],degP*[1 1 1]);
mu = sdpvar(1,1);
T11 = Ai'*Pi + Pi*Ai + Ci'*Ci;
T21 = Bi'*Pi + Di'*Ci;
T22 = Di'*Di - mu;
T = [T11 T21'; T21 T22];
T = polya(T,d);
LMIs = [Pi >= 0, T <= 0];
settings = sdpsettings('solver','sedumi','verbose',0);
solution = optimize(LMIs,mu,settings);
report = rolmip_verify(LMIs,'solver',solution);
muValue = value(mu);
if solution.problem ~= 0 || ~report.constraints_passed || ...
        ~isfinite(muValue) || muValue < 0
    error('The solver did not return a verified H-infinity bound.');
end
gamma = sqrt(muValue);
end
