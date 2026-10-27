function Z = minus(X, Y)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(X, 'rolmipvar') && ~isa(Y, 'rolmipvar')
    Z = builtin('minus', X, Y);
    return
end

%MINUS (overloaded)
%
% Author: Alexandre Felipe
% 2014, Dec, 8
h = homogenize(X, Y);
Zf = operation_poly(h{1}, h{2}, '-');
Z = rolmipvar(Zf);

