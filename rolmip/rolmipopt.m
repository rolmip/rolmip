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
% ROLMIPopt - versao otimizada do ROLMIP (Robust LMI Parser).

persistent opts
if isempty(opts)
    opts = struct('codegen', 'off');
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
    case 'clearcache'
        clear rolmipopt_pascal rolmipopt_exptable rolmipopt_prodtable ...
              rolmipopt_lifttable
    otherwise
        error('rolmipopt: opcao desconhecida ''%s''.', varargin{1});
end
end
