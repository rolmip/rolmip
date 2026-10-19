function elapsed = rolmip_timer_state(action)
% Shared private timer. Explicit token avoids interfering with user TIC/TOC.
persistent token
switch action
    case 'begin'
        token=tic;
        elapsed=[];
    case 'end'
        if isempty(token)
            error('ROLMIP:TimerNotStarted','Call rolmip_begin before rolmip_end.');
        end
        elapsed=toc(token);
        token=[];
    otherwise
        error('ROLMIP:InvalidTimerAction','Unknown timer action.');
end
end
