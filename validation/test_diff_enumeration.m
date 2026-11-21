function test_diff_enumeration
%TEST_DIFF_ENUMERATION Exercise rate geometry through the public DIFF API.
% Run without MPT to exercise the internal enumeration.

withMPT = exist('Polyhedron','class') == 8;
oldMode = rolmipopt('codegen');
cleanup = onCleanup(@() rolmipopt('codegen',oldMode)); %#ok<NASGU>
for mode = {'off','on'}
    rolmipopt('codegen',mode{1});

    % The box [-1,1]^4 has six zero-sum corners and no interior edge cuts.
    V = rateVertices(repmat([-1 1],4,1));
    expected = -ones(4,6);
    positive = nchoosek(1:4,2);
    for j = 1:6
        expected(positive(j,:),j) = 1;
    end
    assert(size(V,2) == size(expected,2));
    for j = 1:size(expected,2)
        assert(min(max(abs(V-expected(:,j)),[],1)) < 1e-12);
    end

    V = rateVertices([0 0; -2 3; 1 1]);
    assert(isequal(size(V),[3 1]) && max(abs(V-[0;-1;1])) < 1e-12);
    assert(isequal(rateVertices([-1 1]),0));
    assert(isequal(rateVertices(zeros(3,2)),zeros(3,1)));
    V = rateVertices([0.1 0.1;0.2 0.2;-0.3 -0.3]);
    assert(max(abs(V-[0.1;0.2;-0.3])) <= 1e-15);
end

if ~withMPT
    % A thin slice with 39 vertices, despite 2^39 candidates per pass
    % before eliminating fixed coordinates.
    rolmipopt('codegen','off');
    n = 40;
    bounds = [zeros(n-1,1),ones(n-1,1);-0.25,-0.25];
    V = rateVertices(bounds);
    expected = [0.25*eye(n-1); -0.25*ones(1,n-1)];
    assert(isequal(sortrows(V.'),sortrows(expected.')));
    V = rateVertices([bounds;1e90 1e90; -1e90 -1e90]);
    expected = [expected;1e90*ones(1,n-1);-1e90*ones(1,n-1)];
    assert(isequal(sortrows(V.'),sortrows(expected.')));

    % These two distinct endpoints should survive any geometry tolerance.
    V = rateVertices([-1 1; -1e-15 1e-15]);
    assert(isequal(sortrows(V.'),[-1e-15 1e-15;1e-15 -1e-15]));
    assertError(@() rateVertices([1 2;1 2]),'ROLMIP:DiffInfeasibleRates');
    assertError(@() rateVertices([1 0;-1 2]),'ROLMIP:DiffRateBounds');
end
fprintf('DIFF_ENUMERATION_TEST_PASSED (MPT=%d)\n',withMPT);
end

function V = rateVertices(bounds)
n = size(bounds,1);
P = rolmipvar(eye(n),'rates',n,1);
derivative = struct(diff(P,bounds));
V = [derivative.data(1:n:end).value];
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
