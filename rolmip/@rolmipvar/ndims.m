function n=ndims(X)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(X, 'rolmipvar')
    n = builtin('ndims', X);
    return
end

%NDIM (overloaded)

n = length(X.data);