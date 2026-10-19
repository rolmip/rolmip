function rolmipopt_regression_test
% Regression tests for codeReviewOpt34 (MATLAB, optional YALMIP/SeDuMi).
% Throws on failure. Run with only this ROLMIP implementation on the path.
oldmode = rolmipopt('codegen');
cleanup = onCleanup(@() rolmipopt('codegen',oldmode)); %#ok<NASGU>
rolmipopt('codegen','off');
P = rolmipvar([1 2 4],'A',3,1);
D = diff(P,repmat([-7e-9 7e-9],3,1));s = struct(D);c = cell2mat(coefs(D));
% This exact vertex-count check exercises the fallback geometry, without MPT.
if ~exist('Polyhedron','file'), assert(isequal(s.vertices,[3 6])); end
assert(abs(max(c)-21e-9)<1e-20 && abs(min(c)+21e-9)<1e-20);
P = rolmipvar([1 2],'B',2,1);
D = diff(P,[.1 .2;-.2 -.1]);c = cell2mat(coefs(D));
assert(abs(min(c)+.2)<1e-12 && abs(max(c)+.1)<1e-12);
fprintf('[ok] F01/F02: derivative extrema and asymmetric rates\n');

Z = rolmipvar(zeros(2,3),'Z');Q = rolmipvar(ones(4,2),'Q');
expect_error(@() Z*Q,'ROLMIP:ProductDimensions');
A = zeros(2);B = [NaN 0;0 1];
assert(isequaln(coefs(rolmipvar(A,'Z')*rolmipvar(B,'N')), A*B));
B = [Inf 0;0 1];
assert(isequaln(coefs(rolmipvar(A,'Z')*rolmipvar(B,'N')), A*B));
assert(isequal(coefs(rolmipvar(0,'z')*rolmipvar(ones(2,3),'M')),zeros(2,3)));
for e = {[2 -1], [.5 .5], [NaN NaN], [1 0 0], [1;0]}
    expect_error(@() rolmipvar({{e{1},7}},'bad',2,1),'');
end
expect_error(@() rolmipvar(1,'bad',-2,1),'');
expect_error(@() rolmipvar(1,'bad',2,.5),'');
% Preserve the scalar [0] convention for a degree-zero simplex.
P = rolmipvar({{0,[1 0],3},{0,[0 1],4}},'C',[3 2],[0 1]);
assert(abs(evalpar(P,{[.2 .3 .5],[.25 .75]})-3.75)<1e-12);
fprintf('[ok] F03/F04: dimensions, nonfinite values, exponent validation\n');

P = rolmipvar(ones(2,3),'M');
assert(isequal(size(P),[2 3]));assert(size(P,3)==1);
assert(isequal(size(P,[1 2 3]),[2 3 1]));
[a,b,c] = size(P);assert(isequal([a b c],[2 3 1]));
expect_error(@() size(P,0),'');expect_error(@() size(P,1.5),'');
assert(isequal(size([P;P]),[4 3]));assert(isequal(size([P P]),[2 6]));
assert(isequal(size(P'),[3 2]));assert(isequal(size(P.'),[3 2]));
assert(isequal(size(P*ones(3,4)),[2 4]));
assert(isequal(size(ones(4,2)*P),[4 3]));
fprintf('[ok] F06/H01: size and shape-changing operations\n');

P = rolmipvar([eye(2) 2*eye(2)],'A',2,1);R = P+P;
for T = {R, -R, R', R*2, 2*R, [R P], [R;P]}
    expect_error(@() rolmipopt_require_opcodes(T{1}),'ROLMIP:MissingOpcodes');
end
rolmipopt('codegen','on');
expect_error(@() R+P,'ROLMIP:MissingOpcodes');
export_checks;
fprintf('[ok] F05: export preflight, late enabling, generated file parser\n');

if exist('sdpvar','file')
    for mode = {'off','on'}
        rolmipopt('codegen',mode{1});
        P = rolmipvar(2,2,'P',2,1);
        ws = warning('on','ROLMIPopt:strict');
        lastwarn('');
        wc = onCleanup(@() warning(ws));
        F = construct_lmi_terms(P,'>');assert(length(F)==2);
        [~,warningid] = lastwarn;assert(strcmp(warningid,'ROLMIPopt:strict'));
        clear wc;
    end
    fprintf('[ok] H02: strict inequality handling in both modes\n');
else
    fprintf('[skip] YALMIP not available: strict inequalities and solve\n');
end
rolmipopt('clearcache');
assert(isequal(rolmipopt_index(rolmipopt_exptable(3,3)),(1:10)'));
fprintf('ROLMIPOPT_REGRESSION_TEST: all enabled tests passed.\n');
end

function expect_error(fun,id)
try
    fun();
catch e
    if ~isempty(id), assert(strcmp(e.identifier,id),e.message); end
    return
end
error('ROLMIP:TestFailure','Expected an error, but the call succeeded.');
end

function export_checks
oldpwd = pwd;oldmode = rolmipopt('codegen');folder = tempname;
mkdir(folder);cd(folder);
cleanup = onCleanup(@() finish_export(oldpwd,folder,oldmode)); %#ok<NASGU>
rolmipopt('codegen','off');
P = rolmipvar([eye(2) 2*eye(2)],'A',2,1);R = P+P;
f = lmifiles('open','rejected');
before = ftell(f);
rolmipopt('codegen','on');
expect_error(@() lmifiles('insert',f,{struct(R)},{struct(P)},'>='),'ROLMIP:MissingOpcodes');
assert(ftell(f)==before);fclose(f);
aux = rolmip('getauxfile');if ~isempty(aux),fclose(aux);end
rolmip('setauxfile',[]);
P = rolmipvar([eye(2) 2*eye(2)],'A',2,1);R = P+P;
f = lmifiles('open','rolmip_export_regression');
lmifiles('insert',f,{struct(R)},{struct(P)},'>=');
lmifiles('close',f);
rehash;assert(nargin('rolmip_export_regression')==1);
clear rolmip_export_regression;
if exist('sdpvar','file') && exist('sedumi','file')
    P = rolmipvar(1,1,'P',0,0);C = rolmipvar(2,'C');R = P-C;
    f = lmifiles('open','rolmip_export_solve');
    lmifiles('insert',f,{struct(R)},{struct(P),struct(C)},'>=');
    lmifiles('insert',f,'P{1}');
    lmifiles('insert',f,'sdpsettings','solver','sedumi','verbose',0);
    lmifiles('close',f);rehash;
    result = rolmip_export_solve(2);
    assert(result.feas==1 && abs(result.P{1}-2)<1e-5);
    clear rolmip_export_solve;
    fprintf('[ok] generated SDP solved: min P subject to P >= 2\n');
else
    fprintf('[skip] generated SDP solve requires YALMIP and SeDuMi\n');
end
end

function finish_export(oldpwd,folder,oldmode)
aux = rolmip('getauxfile');
if ~isempty(aux) && any(fopen('all')==aux),fclose(aux);end
rolmip('setauxfile',[]);rolmipopt('codegen',oldmode);
cd(oldpwd);rmdir(folder,'s');
end
