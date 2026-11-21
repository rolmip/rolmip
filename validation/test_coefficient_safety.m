function test_coefficient_safety
% Guard against brace indexing a scalar-term sdpvar and losing its variables.
oldMode = rolmipopt('codegen');
oldWarning = warning('query','ROLMIP:TrivialLMI');
cleanup = onCleanup(@() restore(oldMode,oldWarning)); %#ok<NASGU>
warning('on','ROLMIP:TrivialLMI');

for mode = {'off','on'}
    rolmipopt('codegen',mode{1});
    yalmip('clear');
    W = rolmipvar(2,2,'W','sym',2,0);
    Y = rolmipvar(2,2,'Y','sym',2,0);
    assert(isa(coeffs(W),'sdpvar'));
    [cw,ew] = coeffs(W,'cell');
    cy = coeffs(Y,"cell");
    assert(iscell(cw) && numel(cw) == 1 && isa(cw{1},'sdpvar'));
    wdata = struct(W);
    assert(isequal(ew,{wdata.data.exponent}));
    [alias,aliasExponents] = coefs(W,'cell');
    assert(isequal(getbase(alias{1}),getbase(cw{1})) && isequal(aliasExponents,ew));
    block = [cw{1} eye(2);eye(2) cy{1}] >= 1e-6*eye(4);
    assert(~islogical(block) && length(block) == 1);
    assert(isequal(sort(getvariables(block)), ...
        sort([getvariables(cw{1}) getvariables(cy{1})])));

    % The default depends on the monomial count, including one-vertex cases.
    for degree = 0:2
        P = rolmipvar(2,2,'P','sym',3,degree);
        [c,e] = coeffs(P,'cell');
        s = struct(P);
        assert(numel(c) == numel(s.data) && numel(e) == numel(s.data));
        assert(isequal(e,{s.data.exponent}));
        if degree > 0
            assert(isequal(coeffs(P),c));
        end
    end
    P = rolmipvar({eye(2)},'oneVertex',1,2);
    assert(isnumeric(coeffs(P)) && isequal(coeffs(P,'cell'),{eye(2)}));
    expectError(@() coeffs(P,'invalid'));
    expectError(@() coeffs(P,'cell','extra'));

    % Numeric coefficients warn through operators and every block builder.
    P = rolmipvar(2,'positive');
    assertWarning(@() P >= 0);
    assertWarning(@() 0 <= P);
    assertWarning(@() P <= 0);
    assertWarning(@() 0 >= P);
    assertWarning(@() construct_lmi(P,'>='));
    assertWarning(@() construct_lmi(P,'<='));
    legacy = struct(P);
    assertWarning(@() construct_lmi(legacy,'>='));
    assertWarning(@() rolmip_lmi(P,'>=','Constant'));

    % A constant right-hand side is normal when the other side is symbolic.
    assertQuiet(@() W >= eye(2));
    assertQuiet(@() eye(2) <= W);
    assertQuiet(@() W <= eye(2));
    assertQuiet(@() eye(2) >= W);
    assertQuiet(@() construct_lmi(W,'>='));

    % Mixed symbolic and constant monomials warn but keep the symbolic LMI.
    mixed = rolmipvar({cw{1},eye(2)},'mixed',2,1);
    lastwarn('');
    F = construct_lmi(mixed,'>=');
    [~,id] = lastwarn;
    assert(strcmp(id,'ROLMIP:TrivialLMI') && length(F) == 1);
    assert(isequal(getvariables(F),getvariables(cw{1})));
    warning('off','ROLMIP:TrivialLMI');
    output = evalc('P >= 0;');
    assert(isempty(strtrim(output)));
    warning('on','ROLMIP:TrivialLMI');
end
fprintf('COEFFICIENT_SAFETY_TEST_PASSED\n');
end

function assertWarning(operation)
lastwarn('');
operation();
[~,id] = lastwarn;
assert(strcmp(id,'ROLMIP:TrivialLMI'));
end

function assertQuiet(operation)
lastwarn('');
operation();
[~,id] = lastwarn;
assert(isempty(id));
end

function expectError(operation)
try
    operation();
catch
    return
end
error('Expected invalid coefficient format to raise an error.');
end

function restore(mode,state)
rolmipopt('codegen',mode);
warning(state);
end
