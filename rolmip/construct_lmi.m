function LMIs = construct_lmi(varargin)
% LMIs = construct_lmi(Term,vecpoly,ineq)
%Function to construct the LMIs "Term 'ineq' 0"
%Inputs: Term    -> Struct (Term{i,j}) containing the i-th row and j-th 
%                   column of the LMI.
%        vertices -> Number of vertices of the polytopic domain of the
%                    system
%        vecpoly -> vector with the polynomials
%        vecpoly(1).label   -> string with the name of the variable 
%                              (eg. 'P')
%        vecpoly(1).vertices -> number of vertices
%        vecpoly(1).data(n) -> data correspondent to the n-th monomy
%        vecpoly(1).data(n).exponent -> values of the exponents of 
%                                       the monomy (eg. [0 2])
%        vecpoly(1).data(n).value    -> value of the monomy
%        ineq    -> Signal of the inequality. Can be '>','<','>=','<='.

if (nargin == 2)
    LMIs = construct_lmi_terms(varargin{1},varargin{2});
elseif (nargin == 3)
    LMIs = construct_lmi_terms(varargin{1},varargin{2},varargin{3});
elseif (nargin == 4) %(Term,vertices,vecpoly,'<')
    LMIs = construct_lmi_terms(varargin{1},varargin{2},varargin{4});
else
    error('construct_lmi is an obsolete function');
    LMIs = [];
end


return