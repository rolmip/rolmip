function rolmipopt_require_opcodes(value)
% Internal preflight: reject expressions whose export history was discarded.
% The current global mode cannot reconstruct opcodes of existing objects.
if iscell(value)
    for k = 1:numel(value), rolmipopt_require_opcodes(value{k}); end
    return
end
if isa(value,'rolmipvar'), value = struct(value); end
if ~isstruct(value) || ~isfield(value,'data'), return; end
if ~isfield(value,'opcode') || ~iscell(value.opcode) || ...
        numel(value.opcode) ~= numel(value.data) || ...
        any(cellfun(@(s) ~ischar(s) || isempty(strtrim(s)), value.opcode))
    error('ROLMIP:MissingOpcodes', ...
        'Export history is unavailable. Enable rolmipopt(''codegen'',''on'') before rebuilding the expression.');
end
end
