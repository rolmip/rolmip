function Z = mpower(X, n)
%ROLMIPopt: delega ao builtin quando o(s) argumento(s) nao sao rolmipvar
%(robustez de despacho, necessaria no Octave).
if ~isa(X, 'rolmipvar')
    Z = builtin('mpower', X, n);
    return
end

%MPOWER (overloaded)
%
% Author: Alexandre Felipe
% 2014, Dec, 9

if( floor(n) ~= n )
  error('Unable to raise rolmipvar to non-integer power');
elseif (n < 0)
  error('Exponent must be a positive integer.');
elseif (n == 0)
    Z = eye(size(X.data(1).value));
else
  Z = X;
  for i = 2:n
    Z = mtimes(X, Z);
  end
end
end

