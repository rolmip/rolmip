function out = test_check_session
% Integration tests: diagnostic sessions must not change constructed models.
old=rolmipopt('codegen');cleanup=onCleanup(@()finish(old)); %#ok<NASGU>
clear rolmip_check_session
yalmip('clear');rolmipopt('codegen','off');
expect(@()rolmip_check_report,'ROLMIP:CheckNotStarted');
expect(@()rolmip_check_end,'ROLMIP:CheckNotStarted');
P=rolmipvar(2,2,'P','sym',2,1);
baseline=[P>=0,P<=eye(2)];
rolmip_check_begin;
R=rolmip_check(P);assert(R.lmi_ready); % explicit diagnostic is not a new LMI
r=rolmip_check_report;assert(r.active&&r.condition_count==0);
observed=[P>=0,P<=eye(2)];
for k=1:length(baseline)
    D=sdpvar(baseline(k))-sdpvar(observed(k));assert(norm(full(getbase(D)),'fro')==0);
end
r=rolmip_check_report;assert(r.active&&~r.has_errors&&r.condition_count==2);
assert(strcmp(r.conditions(1).source.file,[mfilename('fullpath') '.m']));
assert(r.conditions(1).source.line>0);
x=sdpvar(1);unused=x>=0; %#ok<NASGU> % Direct YALMIP not observed
r=rolmip_check_end;assert(~r.active&&r.condition_count==2&&r.elapsed_seconds>=0);
unused=P>=0;r2=rolmip_check_report;assert(isequal(r,r2)); %#ok<NASGU>
expect(@()rolmip_check_end,'ROLMIP:CheckNotStarted');
% Multiple bad coefficients form one grouped issue, not one message each.
rolmip_check_begin;
N=rolmipvar({[x 1;0 x],[x 2;0 x],[x 3;0 x]},'N',3,1);
unused=N>=0; %#ok<NASGU> % Existing operator remains elementwise
Q=rolmipvar(x^2*eye(2),'Q');unused=Q>=0; %#ok<NASGU>
r=rolmip_check_report;assert(r.has_errors&&r.condition_count==2);assert_metadata(r);
e=r.issues(strcmp({r.issues.code},'NotSymmetric'));
assert(numel(e)==1&&size(e.locations,1)==3);
assert(any(strcmp({r.issues.code},'NonAffineDecision')));
% Legacy operator exceptions still propagate and the partial report survives.
expect_any(@()bad_dimensions);
r=rolmip_check_report;
assert(r.conditions(end).construction_failed&&any(strcmp({r.issues.code},'ConstructionFailure')));
rolmip_check_end;
% Strict wrapper produces one condition plus a conversion warning.
rolmip_check_begin;lastwarn('');unused=P>0; %#ok<NASGU>
r=rolmip_check_end;assert(r.condition_count==1&&r.has_warnings&&~r.has_errors);
assert(strcmp(r.conditions.relation,'>')&&strcmp(r.issues.code,'StrictInequality'));
% Both block-building paths, compatibility dispatch, no duplicate records.
for mode={'off','on'}
    rolmipopt('codegen',mode{1});P=rolmipvar(2,2,'P','sym',2,1);
    baseline=construct_lmi_terms(P,'>=');
    rolmip_check_begin;
    observed=construct_lmi_terms(P,'>=');
    for k=1:length(baseline)
        D=sdpvar(baseline(k))-sdpvar(observed(k));assert(norm(full(getbase(D)),'fro')==0);
    end %#ok<NASGU>
    r=rolmip_check_report;assert(r.condition_count==1&&~r.has_errors);
    unused=construct_lmi_terms({struct(P)},'>='); %#ok<NASGU>
    r=rolmip_check_report;assert(r.condition_count==2&&~r.has_errors);
    unused=construct_lmi_terms(P,'Term'); %#ok<NASGU>
    r=rolmip_check_report;assert(r.condition_count==2);
    [unused,origin]=rolmip_lmi(P,'>=','Named condition'); %#ok<ASGLU>
    r=rolmip_check_end;assert(r.condition_count==3&&~r.has_errors);
    assert(strcmp(r.conditions(end).name,'Named condition'));
    assert_metadata(r);
    rolmip_check_begin;
    expect_any(@()construct_lmi_terms({struct(P),struct(P)},'>='));
    r=rolmip_check_end;assert(r.condition_count==1&&r.has_errors&&r.conditions.construction_failed);
end
% Compatibility preflight exceptions are recorded once, before the backend.
rolmipopt('codegen','off');missing=N+N;rolmipopt('codegen','on');
rolmip_check_begin;
expect(@()construct_lmi_terms(missing,'>='),'ROLMIP:MissingOpcodes');
r=rolmip_check_end;assert(r.condition_count==1&&r.conditions.construction_failed);
% The stricter opt-in builder records findings before throwing its own error.
rolmip_check_begin;
expect(@()rolmip_lmi(N,'>=','Invalid'),'ROLMIP:InvalidLMI');
r=rolmip_check_end;assert(r.has_errors&&r.condition_count==1&&r.conditions.construction_failed);
% Reset is explicit and does not affect the independent parser timer.
rolmip_begin;rolmip_check_begin;unused=P>=0; %#ok<NASGU>
lastwarn('');rolmip_check_begin;[~,id]=lastwarn;assert(strcmp(id,'ROLMIP:CheckRestarted'));
r=rolmip_check_end;assert(r.condition_count==0&&~r.has_errors);
[t,~,~]=rolmip_end([]);assert(t>=0);
assert_metadata(r);
fprintf('CHECK_SESSION_TEST_PASSED: grouping, caller location, partial/final reports, failures, strict wrappers, block paths, reset and model equivalence\n');
end
function bad_dimensions
P=rolmipvar(ones(2,3),'Bad');Q=rolmipvar(ones(4,4),'Other');F=P>=Q; %#ok<NASGU>
end
function assert_metadata(r)
if isstruct(r)
    for f=fieldnames(r).',for k=1:numel(r),assert_metadata(r(k).(f{1}));end,end
elseif iscell(r),for k=1:numel(r),assert_metadata(r{k});end
else,assert(~isa(r,'sdpvar')&&~isa(r,'rolmipvar'));end
end
function expect(fun,id)
try,fun();catch e,assert(strcmp(e.identifier,id),'Unexpected error: %s',e.message);return;end
error('Test:MissingError','Expected %s',id);
end
function expect_any(fun)
try,fun();catch,return;end;error('Test:MissingError','Expected original dimension error.');
end
function finish(old)
if rolmip_check_session('active'),rolmip_check_end;end
rolmipopt('codegen',old);
end
