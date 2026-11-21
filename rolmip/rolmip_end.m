function [elapsed,V,L] = rolmip_end(LMIs)
%ROLMIP_END Stop construction timing and inspect the final constraints.
%   [TIME,V,L] = ROLMIP_END(LMIs) returns:
%     TIME  elapsed wall time in seconds since the last ROLMIP_BEGIN;
%     V     NUMEL(GETVARIABLES(LMIs)), distinct scalar decision variables;
%     L     SUM(INFO.SDP(:,1)), where INFO = LMIINFO(LMIs).
%   L includes only semidefinite blocks classified as SDP by YALMIP;
%   elementwise inequalities and equalities are not included. V includes
%   variables created before BEGIN when used in LMIs, and excludes unused
%   variables and variables appearing only in an objective.
%
%   The timer stops before statistics are collected. An empty constraint
%   set gives V=L=0. Statistics are computed only if their outputs are
%   requested. END consumes the timer, including when inspection fails;
%   a new BEGIN is required before another END. No objective is accepted.
%
%   See also ROLMIP_BEGIN, LMIINFO, GETVARIABLES.
narginchk(1,1);
elapsed=rolmip_timer_state('end');
if nargout>1
    if isempty(LMIs),V=0;else,V=numel(getvariables(LMIs));end
end
if nargout>2
    if isempty(LMIs),L=0;else,info=lmiinfo(LMIs);L=sum(info.sdp(:,1));end
end
end
