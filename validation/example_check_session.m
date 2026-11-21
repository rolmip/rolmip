function report = example_check_session
%EXAMPLE_CHECK_SESSION Collect diagnostics before deciding whether to solve.
% Requires YALMIP and SeDuMi. Assumes this ROLMIP is on the path.
yalmip('clear');
rolmip_check_begin;
A=rolmipvar({[-2 .2;0 -1],[-1 0;.2 -3]},'A',2,1);
P=rolmipvar(2,2,'P','sym',2,1);
LMIs=[P>=1e-5*eye(2),A'*P+P*A<=-1e-5*eye(2)];
partial=rolmip_check_report;
assert(partial.active && partial.condition_count==2);
report=rolmip_check_end;
for k=1:numel(report.issues)
    item=report.issues(k);origin=report.conditions(item.condition_id);
    fprintf('%s: %s (%s:%d)\n',item.severity,item.message,origin.source.file,origin.source.line);
end
if report.has_errors
    fprintf('Model construction has diagnostic errors; solver not called.\n');
else
    solver=optimize(LMIs,[],sdpsettings('solver','sedumi','verbose',0));
    assert(solver.problem==0,solver.info);
    fprintf('%d conditions inspected; model solved.\n',report.condition_count);
end
end
