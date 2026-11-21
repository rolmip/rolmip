function Z = uplus(X)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(X, 'rolmipvar')
    Z = builtin('uplus', X);
    return
end

%UPLUS (overloaded)
%
% Author: Cristiano Agulhari
% 2016, Nov, 4
Z = X;

