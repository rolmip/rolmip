function test_rolmip_volume
%TEST_ROLMIP_VOLUME Test the center cut and common-lift projection.
% Run with YALMIP and SeDuMi on the MATLAB path.

P1 = [2 0 -1; 0 1 0; -1 0 1];
P2 = [2 0  1; 0 1 0;  1 0 1];
assert(abs(rolmip_volume(P1) - 4*pi/3) < 1e-12);
assert(abs(rolmip_volume(P1,'subspace',3) - 2*sqrt(2)) < 1e-12);
assert(abs(rolmip_volume(P1,'subspace',3,'reduction','cut') - 2) < 1e-12);

% The two ellipsoids separately project to the unit disk on (x2,x1).
% Their intersection projects to x2^2+2*x1^2<=1, since the two
% minimizing lifts are opposite. A shared lift of zero attains the bound.
P = rolmipvar({P1,P2},'P',2,1);
[v,info] = rolmip_volume(P,'subspace',[2 1],'Solver','sedumi','NumDirections',64);
assert(abs(v - pi/sqrt(2)) < 1e-7);
assert(isequal(info.boundaryX,info.boundaryZ([2 1],:)));
for vertex = {P1,P2}
    q = sum((chol(vertex{1})*info.boundaryZ).^2,1);
    assert(max(q) <= 1+1e-12);
end

[v,info] = rolmip_volume({P1,P2},'subspace',[2 1],'reduction','cut','NumDirections',64);
assert(abs(v - pi/sqrt(2)) < 1e-12);
assert(info.nOptimizationProblems == 0 && all(info.boundaryZ(3,:) == 0));

% A second pair has a nonzero shared optimal lift.
[v,info] = rolmip_volume({P1,2*P1},'subspace',[1 2],'Solver','sedumi','NumDirections',16);
assert(abs(v - pi/2) < 1e-7);
assert(max(abs(info.boundaryZ(3,:)-info.boundaryX(1,:))) < 1e-4);

% With t = alpha(2), P(t) = (1 + 4*t*(1-t))*I.
P = rolmipvar({eye(2),6*eye(2),eye(2)},'Q',2,2);
[v,info] = rolmip_volume(P);
assert(abs(v - pi/2) < 1e-9 && info.nOptimizationProblems == 0);
assert(max(abs(sum(info.boundaryX.^2,1) - 1/2)) < 1e-10);

% Degree six with a maximum at t=1/3, using explicit monomial indices.
% P(t) = (1 + 20*t^2*(1-t)^4)*D.
D = diag([4 9 1]);
terms = cell(1,7);
for k = 0:6
    coefficient = nchoosek(6,k) + 20*(k == 2);
    terms{7-k} = {[6-k k],coefficient*D};
end
P = rolmipvar(terms,'Q6',2,6);
qMax = 1 + 20*(1/3)^2*(2/3)^4;
[v,info] = rolmip_volume(P,'subspace',[3 1],'reduction','cut');
assert(abs(v - pi/(2*qMax)) < 1e-9);
assert(info.radialMaxRelativeGap <= 1e-10 && all(info.boundaryZ(2,:) == 0));
assert(isequal(info.boundaryX,info.boundaryZ([3 1],:)));
assertError(@() rolmip_volume(P,'subspace',[3 1]),'ROLMIP:VolumePolynomialProjection');

% A negative middle coefficient can still give P(t) > 0 everywhere.
P = rolmipvar({3/8,-1/4,3/8},'Q',2,2);
assert(abs(rolmip_volume(P) - 2/sqrt(3/8)) < 1e-9);
P = rolmipvar({1,-3,1},'Q',2,2);
assertError(@() rolmip_volume(P),'ROLMIP:VolumePositiveDefinite');
fprintf('ROLMIP_VOLUME_TEST_PASSED\n');
end

function assertError(call,identifier)
try
    call();
catch exception
    assert(strcmp(exception.identifier,identifier),exception.message);
    return
end
error('Expected error %s.',identifier);
end
