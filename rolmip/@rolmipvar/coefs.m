function [varargout] = coefs(X,varargin)
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

% COEFS accepts the same optional 'cell' format as COEFFS.
[varargout{1:nargout}] = coeffs(X,varargin{:});
end
