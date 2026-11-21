function varargout = rolmipopt(varargin)
% ROLMIPOPT  Opcoes e gerenciamento de cache do ROLMIPopt.
%
%   rolmipopt('codegen','off')  (padrao) desativa a construcao das strings
%       simbolicas 'opcode' nos lacos internos das operacoes polinomiais.
%       Nesse modo as operacoes sao muito mais rapidas, mas o gerador de
%       arquivos LMIFILES nao pode ser usado.
%   rolmipopt('codegen','on')   restaura o comportamento original do ROLMIP
%       (opcodes completos), delegando os nucleos aos caminhos de
%       compatibilidade *_codegen. Use apenas se precisar do LMIFILES.
%   estado = rolmipopt('codegen') retorna o estado atual ('on'/'off').
%
%   rolmipopt('clearcache') limpa as tabelas memoizadas (expoentes,
%       indices, produtos e homogeneizacao). Normalmente desnecessario.
%
%   rolmipopt('cachebytes', n) sets the shared table cache payload budget
%       (default 64 MiB; zero disables storage). Shrinking evicts entries.
%   rolmipopt('workbytes', n) sets the temporary chunk size target
%       (default 8 MiB, minimum 1024 bytes), not a process memory limit.
%   rolmipopt('cachestats') returns bytes, entries, hits, misses, evictions
%       and limit. Accounting excludes MATLAB overhead and Pascal tables.
%   rolmipopt('cachebytes') / rolmipopt('workbytes') return current values.
%
% ROLMIPopt - versao otimizada do ROLMIP (Robust LMI Parser).

persistent opts
if isempty(opts)
    opts = struct('codegen', 'off', 'cachebytes', 64*1024^2, 'workbytes', 8*1024^2);
end

if nargin == 0
    varargout{1} = opts;
    return
end

switch lower(varargin{1})
    case 'codegen'
        if nargin >= 2
            if ~any(strcmpi(varargin{2}, {'on','off'}))
                error('rolmipopt: codegen deve ser ''on'' ou ''off''.');
            end
            opts.codegen = lower(varargin{2});
        else
            varargout{1} = opts.codegen;
        end
    case {'cachebytes','workbytes'}
        name = lower(varargin{1});
        if nargin == 1
            varargout{1} = opts.(name);
        else
            validateattributes(varargin{2}, {'numeric'}, {'scalar','real','finite','integer','nonnegative'});
            if strcmp(name,'workbytes') && varargin{2} < 1024
                error('ROLMIP:MemoryBudget','workbytes must be at least 1024 bytes.');
            end
            opts.(name) = double(varargin{2});
            if strcmp(name,'cachebytes'),rolmipopt_cache('trim');end
        end
    case 'cachestats'
        varargout{1} = rolmipopt_cache('stats');
    case 'clearcache'
        clear rolmipopt_cache rolmipopt_index rolmipopt_pascal rolmipopt_exptable rolmipopt_prodtable ...
              rolmipopt_lifttable
    otherwise
        error('rolmipopt: opcao desconhecida ''%s''.', varargin{1});
end
end
