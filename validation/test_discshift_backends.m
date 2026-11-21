function results = test_discshift_backends
%TEST_DISCSHIFT_BACKENDS Test trajectories and the polynomials they induce.
% Run in fresh MATLAB sessions with MPT, with cddmex alone, and with neither.
% The returned records can be paired by complete trajectories across sessions.
hasMPT = exist('Polyhedron','class') == 8;
hasCDD = exist(['cddmex.' mexext],'file') == 3;
if hasMPT
    backend = 'mpt';
elseif hasCDD
    backend = 'cdd';
else
    backend = 'matlab';
end

cases = {
    2, 1, [],                      4
    2, 1, [-0.4 0.4;-0.6 0.6],    6
    2, 1, [-0.25 0.4;-0.15 0.5],  6
    2, 1, [0 0.4;-0.6 0],          4
    2, 1, zeros(2),                2
    2, 1, [0.3 0.3;-0.3 -0.3],     2
    2, 1, [1 1;-1 -1],             1
    2, 1, [-Inf Inf;-Inf Inf],     4
};
stream = RandStream('mt19937ar','Seed',731);
for k = 1:24
    r = 0.05+0.9*rand(stream,2,2);
    cases(end+1,:) = {2,1,[-r(:,1),r(:,2)],6};
end
if hasMPT || hasCDD
    cases = [cases; {
        2, 2, [-0.4 0.4;-0.6 0.6], 14
        2, 3, zeros(2),             2
        3, 2, [],                  27
        3, 2, zeros(3,2),           3
        3, 1, [-0.2 0.4;-0.5 0.3;-0.3 0.1], []
        4, 1, [-0.4 0.2;-0.1 0.35;-0.4 0.2;-0.2 0.4], []
    }];
end

results = repmat(struct('n',0,'steps',0,'vertices',[],'values',[],'interior',[]), ...
    1,size(cases,1));
for k = 1:size(cases,1)
    [n,eta,bounds,expectedCount] = cases{k,:};
    % A degree-one vector polynomial gives the actual trajectory columns.
    coordinatePoly = rolmipvar(eye(n),'alpha',n,1);
    if isempty(bounds)
        coordinates = discshift(coordinatePoly,eta);
        bounds = repmat([-1 1],n,1);
    else
        coordinates = discshift(coordinatePoly,eta,bounds);
    end
    steps = eta+1;
    assert(numel(coordinates) == steps);
    firstCoordinate = struct(coordinates{1});
    count = numel(firstCoordinate.data);
    if ~isempty(expectedCount)
        assert(count == expectedCount);
    end
    trajectory = zeros(n*steps,count);
    for t = 1:steps
        coordinate = struct(coordinates{t});
        A = [coordinate.data.value];
        assert(size(A,2) == count);
        assert(all(abs(sum(A,1)-1) < 1e-10) && min(A(:)) >= -1e-10);
        rows = (t-1)*n+(1:n);
        trajectory(rows,:) = A;
        if t > 1
            delta = A-trajectory(rows-n,:);
            assert(all(all(delta >= bounds(:,1)-1e-10)));
            assert(all(all(delta <= bounds(:,2)+1e-10)));
        end
    end
    if k == 2
        % Check the joint (k,k+1) vertices, including the two boundary slopes.
        expected = [0 0;0 .4;.4 0;.6 1;1 .6;1 1];
        observed = trajectory([1,3],:).';
        for j = 1:size(expected,1)
            assert(min(max(abs(observed-expected(j,:)),[],2)) < 1e-10);
        end
    end

    % Check a matrix-valued polynomial at each trajectory and at a common
    % interior convex combination. Keep larger output simplexes linear.
    degree = 1 + (n == 2 && eta == 1);
    exponents = generate_homogeneous_exponents(n,degree);
    matrices = arrayfun(@(j) [j j^2;-j 1-j],1:size(exponents,1),'UniformOutput',false);
    P = rolmipvar(matrices,'P',n,degree);
    Q = discshift(P,eta,bounds);
    values = zeros(4*steps,count);
    interior = zeros(4*steps,1);
    for t = 1:steps
        rows = (t-1)*n+(1:n);
        outputRows = (t-1)*4+(1:4);
        for j = 1:count+1
            if j <= count
                beta = zeros(1,count);
                beta(j) = 1;
            else
                beta = ones(1,count)/count;
            end
            alpha = beta*trajectory(rows,:).';
            got = evalpar(Q{t},{1,beta});
            expected = evalpar(P,{alpha});
            assert(norm(got-expected,'fro') < 1e-10*max(1,norm(expected,'fro')));
            if j <= count
                values(outputRows,j) = got(:);
            else
                interior(outputRows) = got(:);
            end
        end
    end
    results(k) = struct('n',n,'steps',steps,'vertices',trajectory, ...
        'values',values,'interior',interior);
end

% Explicit target positions preserve the simplex that is being held fixed.
terms = {{[1 0],[1 0],1}, {[0 1],[1 0],2}, ...
         {[1 0],[0 1],3}, {[0 1],[0 1],4}};
P = rolmipvar(terms,'P',[2 2],[1 1]);
Q = discshift(P,1,2,4);
assert(abs(evalpar(Q{1},{[1 0],1,1,[0.25 0.25 0.25 0.25]})-2) < 1e-12);
assert(abs(evalpar(Q{2},{[0 1],1,1,[0.25 0.25 0.25 0.25]})-3) < 1e-12);

P = rolmipvar(eye(2),'alpha',2,1);
assertError(@() discshift(P,1,[0.2 0.4;0.1 0.2]),'ROLMIP:DiscshiftInfeasible');
if hasMPT || hasCDD
    % One step is feasible, but two positive steps of at least 0.6 are not.
    assertError(@() discshift(P,2,[0.6 0.8;-0.8 -0.6]),'ROLMIP:DiscshiftInfeasible');
else
    assertError(@() discshift(P,2),'ROLMIP:DiscshiftBackend');
end
fprintf('DISCSHIFT_BACKENDS_TEST_PASSED backend=%s cases=%d\n',backend,numel(results));
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
