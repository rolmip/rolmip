function [varargout] = coeffs(X,format)
% This function returns the informations of the rolmipvar object poly.
%
% [c] = coeffs(poly) returns only the coefficients of the polynomial.
%
% [c,expon] = coeffs(poly) returns both the coefficients and the
% respective exponents of the polynomial. In this case, the i-th index
% corresponds to the coefficient and exponent of the same monomial.
%
% coeffs(poly,'cell') always returns a cell array of coefficients, including
% for a single monomial. [c,expon] = coeffs(poly,'cell') also returns one
% exponent entry per monomial, so c{i} and expon{i} refer to the same term.
% The default output is unchanged: a single coefficient is returned directly.
%
% See also COEFS, EXPONENTS

% Author: Alexandre Felipe
% 2015, Apr, 6
%
% Update: Cristiano Agulhari
% 2016, Feb, 4
% 
% Update: Cristiano Agulhari
% 2017, Apr, 17
%
% Update: Cristiano Agulhari
% 2026, Oct, 27

narginchk(1,2);
nargoutchk(0,2);
forceCell = nargin == 2;
if forceCell
    validatestring(format,{'cell'},mfilename,'format',2);
end

if isa(X,'rolmipvar')
    coefs = {X.data.value};
    if nargout == 2
        expon = {X.data.exponent};
    end
    if numel(X.data) == 1 && ~forceCell
        coefs = coefs{1};
        if nargout == 2
            expon = expon{1};
        end
    end
else
    coefs = X;
    expon = [];
    if forceCell
        coefs = {coefs};
        expon = {expon};
    end
end

varargout{1} = coefs;
if nargout == 2
    varargout{2} = expon;
end
end
