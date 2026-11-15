function rolmip_check_begin
%ROLMIP_CHECK_BEGIN Start collecting diagnostics of ROLMIP inequalities.
% A new BEGIN resets the report (warns if a session is already active).
% Operators >=, <=, >, <, LMI block builders and ROLMIP_LMI are observed.
% Direct YALMIP constraints and expressions which fail before reaching these
% entry points are not observed. No model or solver behavior is changed.
% See also ROLMIP_CHECK_END, ROLMIP_CHECK_REPORT, ROLMIP_CHECK.
narginchk(0,0);
rolmip_check_session('begin');
end
