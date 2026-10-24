function [varargout] = blkdiag(varargin)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
isrol = false;
for iarg = 1:nargin
    if isa(varargin{iarg}, 'rolmipvar')
        isrol = true;
        break
    end
end
if ~isrol
    % blkdiag nao e builtin: fallback manual (evita recursao de despacho)
    nr = 0; nc = 0; issp = false;
    for iarg = 1:nargin
        nr = nr + builtin('size', varargin{iarg}, 1);
        nc = nc + builtin('size', varargin{iarg}, 2);
        issp = issp || issparse(varargin{iarg});
    end
    if issp
        B = sparse(nr, nc);
    else
        B = zeros(nr, nc);
    end
    r0 = 0; c0 = 0;
    for iarg = 1:nargin
        r = builtin('size', varargin{iarg}, 1);
        c = builtin('size', varargin{iarg}, 2);
        B(r0+1:r0+r, c0+1:c0+c) = varargin{iarg};
        r0 = r0 + r; c0 = c0 + c;
    end
    varargout{1} = B;
    return
end

%BLKDIAG (overloaded)

resul = [];
%Get the dimensions
for cont=1:nargin
    now = varargin{cont};
    if(isa(now,'rolmipvar'))
        now = now.data(1).value;
    end
    
    [rows(cont), cols(cont)] = size(now);
end

%Concatenate the matrices
for cont = 1:nargin
    aux = [];
    if (cont > 1)
        aux = zeros(rows(cont),sum(cols(1:cont-1)));
    end
    aux = [aux varargin{cont}];
    if (cont < length(cols))
        aux = [aux zeros(rows(cont),sum(cols(cont+1:end)))];
    end
    resul = [resul; aux];
end
varargout{1} = resul;
    
    
return