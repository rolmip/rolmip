function report = rolmip_check_end
%ROLMIP_CHECK_END Stop collection and return the accumulated diagnostics.
% R.has_errors and R.has_warnings summarize grouped R.issues.
% R.conditions describes construction attempts, including discarded LMIs.
% This is not a scan of the final constraint set and does not block a solver.
% An interrupted program can still retrieve the collected report.
% See also ROLMIP_CHECK_BEGIN, ROLMIP_CHECK_REPORT.
narginchk(0,0);
report=rolmip_check_session('end');
end
