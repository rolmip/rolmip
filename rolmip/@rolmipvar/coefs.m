function [varargout] = coefs(X)
% This function returns the informations of the rolmipvar object poly.
%
% [c] = coefs(poly) returns only the coefficients of the polynomial.
%
% [c,expon] = coefs(poly) returns both the coefficients and the
% respective exponents of the polynomial. In this case, the i-th index
% corresponds to the coefficient and exponent of the same monomial.
%
% See also EXPONENTS

% Update: Cristiano Agulhari
% 2026, Oct, 27

if (isa(X,'rolmipvar'))
    if (length(X.data) == 1)
        coefs = X.data(1).value;
        expon = X.data(1).exponent;
    else
        for i = 1:length(X.data)
            coefs{i} = X.data(i).value;
            if (nargout == 2)
                expon{i} = X.data(i).exponent;
            end
        end
    end
else
    coefs = X;
    expon = [];
end

varargout{1} = coefs;
if (nargout == 2)
    varargout{2} = expon;
end


return
