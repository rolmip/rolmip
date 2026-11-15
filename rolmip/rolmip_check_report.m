function report = rolmip_check_report
%ROLMIP_CHECK_REPORT Read diagnostics without stopping or resetting collection.
% Works during a session or after END, until the next BEGIN resets it.
% Does not clear issues, change YALMIP assignments, or construct constraints.
narginchk(0,0);
report=rolmip_check_session('report');
end
