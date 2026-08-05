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

% Term = varargin{1};
% if (~iscell(Term))
%     %In this case, Term is a polynomial and not a matrix with polynomials
%     Termaux = Term;
%     clear Term;
%     Term{1} = Termaux;
%     clear Termaux;
% end
% 
% if (nargin == 4)
%     vertices = varargin{2};
%     vecpoly = varargin{3};
%     ineq = varargin{4};
% elseif (nargin == 3)
%     vertices = 0;
%     conti = 1;
%     contj = 1;
%     while (vertices == 0)
%         vertices = Term{conti,contj}.vertices;
%         contj = contj + 1;
%         if (contj > size(Term,2))
%             conti = conti + 1;
%             contj = 1;
%         end
%     end
%     vecpoly = varargin{2};
%     ineq = varargin{3};
% end
% 
% %If Term is triangular inferior perform its transpose, since the
% %following implementation consider triangular superior matrices
% if ((length(Term) > 1) && (~isempty(Term{2,1})))
%     %Triangular inferior
%     for contj = 1:size(Term,2)
%         for conti = contj:size(Term,1)
%             Termaux{contj,conti} = parser_poly(strcat(Term{conti,contj}.label,''''),vecpoly,vertices);
%         end
%     end
%     Term = Termaux;
%     clear Termaux;
% end
% 
% 
% %First step: determine the highest degree from all the terms
% for conti=1:size(Term,1)
%     for contj = conti:size(Term,2)
%         deg(conti,contj) = sum(Term{conti,contj}.data(1).exponent);
%     end
% end
% maxdeg = max(max(deg));
% 
% %one = sum_{i=1}^{vertices} alpha_i = 1
% one = poly_struct(ones(1,vertices),'1',vertices,1);
% 
% %Second step: Make the polynomials homogeneous to the highest degree
% for conti=1:size(Term,1)
%     for contj = conti:size(Term,2)
%         contdeg = deg(conti,contj);
%         while (contdeg < maxdeg)
%             Term{conti,contj} = operation_poly(Term{conti,contj},one,'*');
%             contdeg = contdeg + 1;
%         end
%     end
% end
% 
% 
% %Third step: construct the LMIs
% LMIs = set([]);
% 
% for contdata=1:length(Term{1,1}.data)
%     T = [];
%     for conti=1:size(Term,1)
%         Taux = [];
%         for contj = 1:size(Term,2)
%             if (contj < conti)
%                 Taux = [Taux (Term{contj,conti}.data(contdata).value)'];
%             else
%                 Taux = [Taux Term{conti,contj}.data(contdata).value];
%             end
%         end
%         T = [T; Taux];
%     end
%     
%     if (strcmp(ineq,'>'))
%         LMIs = LMIs + set(T>0);
%     elseif (strcmp(ineq,'<'))
%         LMIs = LMIs + set(T<0);
%     elseif (strcmp(ineq,'>='))
%         LMIs = LMIs + set(T>=0);
%     elseif (strcmp(ineq,'<='))
%         LMIs = LMIs + set(T<=0);
%     end
% end
% 
return