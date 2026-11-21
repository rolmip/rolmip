function out = full(X)
%FULL (overloaded)
%ROLMIPopt: delega ao builtin quando o argumento nao e rolmipvar.
if ~isa(X, 'rolmipvar')
    out = builtin('full', X);
    return
end


out = X;
for cont=1:length(X.data)
    out.data(cont).value = full(X.data(cont).value);
end

return