function varargout = rolmipopt_cache(action, key, value)
% Internal shared LRU cache for exponent/product tables and lifting weights.
% Byte accounting covers numeric payloads, not MATLAB struct overhead.
persistent entries bytes tick hits misses evictions
if isempty(bytes)
    entries = struct('key',{},'value',{},'bytes',{},'used',{});
    bytes = 0; tick = 0; hits = 0; misses = 0; evictions = 0;
end
switch action
    case 'get'
        i = find(strcmp({entries.key},key),1);
        tick = tick+1;
        if isempty(i)
            misses = misses+1; varargout = {[],false};
        else
            hits = hits+1; entries(i).used = tick;
            varargout = {entries(i).value,true};
        end
    case {'put','trim'}
        limit = rolmipopt('cachebytes');
        if strcmp(action,'put')
            info = whos('value'); n = info.bytes;
            i = find(strcmp({entries.key},key),1);
            if ~isempty(i),bytes=bytes-entries(i).bytes;entries(i)=[];end
            if n > limit, return; end
        else
            n = 0;
        end
        while bytes+n > limit && ~isempty(entries)
            [~,i] = min([entries.used]);
            bytes = bytes-entries(i).bytes; entries(i)=[]; evictions=evictions+1;
        end
        if strcmp(action,'put') && limit > 0
            tick=tick+1;
            entries(end+1)=struct('key',key,'value',value,'bytes',n,'used',tick);
            bytes=bytes+n;
        end
    case 'stats'
        varargout{1}=struct('bytes',bytes,'entries',numel(entries), ...
            'hits',hits,'misses',misses,'evictions',evictions, ...
            'limit',rolmipopt('cachebytes'));
    otherwise
        error('ROLMIP:CacheAction','Unknown internal cache action.');
end
end
