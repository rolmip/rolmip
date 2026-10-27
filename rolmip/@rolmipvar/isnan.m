function out = isnan(X)
%ISNAN (overloaded)
%ROLMIPopt: delega ao builtin quando o argumento nao e rolmipvar.
if ~isa(X, 'rolmipvar')
    out = builtin('isnan', X);
    return
end


out = isnan(X.data(1).value);

return