function rolmip_begin
%ROLMIP_BEGIN Start timing construction of a ROLMIP/YALMIP model.
%   ROLMIP_BEGIN starts (or restarts) a single construction timer.
%   [TIME,V,L] = ROLMIP_END(LMIs) stops it and reports elapsed wall time
%   in seconds, distinct decision variables used in LMIs, and SDP rows.
%
%   Include variable creation, polynomial operations and LMI construction
%   between the calls. Call the solver after ROLMIP_END. All work in the
%   interval is timed, including user code and pauses. Statistics are not.
%   This timer is independent of ordinary TIC/TOC calls. It does not clear
%   YALMIP variables or ROLMIP caches. Nested sessions are not supported:
%   another ROLMIP_BEGIN restarts the timer.
%
%   See also ROLMIP_END.
rolmip_timer_state('begin');
end
