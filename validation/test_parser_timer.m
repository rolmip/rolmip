function test_parser_timer
% Run with this checkout's rolmip folder and YALMIP already on the path.
assert(~isempty(which('sdpvar')), 'YALMIP must be on the MATLAB path.');
yalmip('clear');
try,rolmip_end([]);error('test:ExpectedError','Expected missing timer error');catch e,assert(strcmp(e.identifier,'ROLMIP:TimerNotStarted'));end
Q=sdpvar(2);unused=sdpvar(9,1); %#ok<NASGU>
rolmip_begin;P=rolmipvar(2,2,'P','sym',2,1);z=sdpvar(1);objOnly=sdpvar(1); %#ok<NASGU>
F=[P>=0,Q>=0,z>=0,z==Q(1,1)];
% Explicit timer remains valid even if unrelated code invokes TIC/TOC.
tic;pause(.01);toc;
[t,V,L]=rolmip_end(F);info=lmiinfo(F);
assert(t>=.01 && isfinite(t));assert(V==10);assert(L==6);
assert(V==numel(getvariables(F)) && L==sum(info.sdp(:,1)));
try,rolmip_end(F);error('test:ExpectedError','Expected consumed timer error');catch e,assert(strcmp(e.identifier,'ROLMIP:TimerNotStarted'));end
rolmip_begin;rolmip_begin;[t,V,L]=rolmip_end([]);assert(t>=0 && V==0 && L==0);
rolmip_begin;t=rolmip_end(F);assert(t>=0);
fprintf('Parser timer tests passed: variable sharing, SDP rows, excluded scalar/equality rows, empty sets, restart, consumed timer, external TIC.\n');
end
