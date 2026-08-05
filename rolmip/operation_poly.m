function [resul] = operation_poly(poly1,poly2,op)
%[resul] = operation_poly(poly1,poly2,op)
%Algorithm to perform a operation (+, -, *) between two polynomials.
%The present algorithm considers only homogenous polynomials.
%poly1.label   -> string with the name of the variable (eg. 'P')
%poly1.data(n) -> data correspondent to the n-th monomy
%poly1.data(n).exponent -> values of the exponents of the monomy (eg. [0 2])
%poly1.data(n).value    -> value of the monomy
%poly1.data(n).opcode -> cell array with the description of the operations performed
%op -> description of the operation ('+', '-', '*')

vertices = max([length(poly1.data(1).exponent) length(poly2.data(1).exponent)]);
if (op == '*')
    if (length(poly1.data) == 1) %If poly1 is a constant
        degree = sum(poly2.data(1).exponent);
    elseif (length(poly2.data) == 1) %If poly2 is a constant
        degree = sum(poly1.data(1).exponent);
    else %Both are polynomials
        degree = sum(poly1.data(1).exponent)+sum(poly2.data(1).exponent);
    end
elseif ((op == '+') || (op == '-'))
    degree = sum(poly1.data(1).exponent);
end

aux = poly1.opcode{1};
if (aux(1)=='-')
    subtr = true;
    linkop = [];
else
    subtr = false;
    linkop = '+';
end

[tabexponents] = generate_homogenous_exponents(vertices,degree);
if (degree>1)
    base = (degree*ones(1,vertices)).^(vertices-1:-1:0);
else
    base = (2*ones(1,vertices)).^(vertices-1:-1:0);
end
for cont=1:size(tabexponents,1)
    indhash(cont) = sum(base.*tabexponents(cont,:));
    resul.data(cont).value = 0;
    resul.opcode{cont} = [];
end
%Label '1' or '-1' and op '*' -> special case, does not appear
value1 = [];
if ((strcmp(poly1.label,'1') || strcmp(poly1.label,'-1')) && (strcmp(op,'*')))
    if (strcmp(poly1.label,'1'))
        resul.label = poly2.label;
    else %-1
        resul.label = strcat('-',poly2.label);
        for cont=1:length(poly2.opcode)
            poly2.opcode{cont} = strcat('-',strcat('(',strcat(poly2.opcode{cont},')')));
        end
    end
    value1 = 1;
elseif ((strcmp(poly2.label,'1') || strcmp(poly2.label,'-1')) && (strcmp(op,'*')))
    if (strcmp(poly2.label,'1'))
        resul.label = poly1.label;
    else
        resul.label = strcat('-',poly1.label);
        for cont=1:length(poly1.opcode)
            poly1.opcode{cont} = strcat('-',strcat('(',strcat(poly1.opcode{cont},')')));
        end
    end
    value1 = 2;
else
    resul.label = strcat(poly1.label,op);
    resul.label = strcat(resul.label,poly2.label);
end
if (op == '*')
    %If one of the factors is a constant
    if (length(poly1.data) == 1) %Poly1 is a constant
        for cont2=1:length(poly2.data)
            exponent = poly2.data(cont2).exponent;
            
            hash = sum(base.*exponent);
            indresul = find(indhash==hash);
            
            resul.data(indresul).exponent = exponent;
            resul.data(indresul).value = resul.data(indresul).value + (poly1.data(1).value*poly2.data(cont2).value);
            if (value1 == 1)
                if (~isempty(resul.opcode{indresul}))
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop); %%%%%%%%%%%
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},poly2.opcode{cont2});%%%%%%%%%5
                else
                    resul.opcode{indresul} = poly2.opcode{cont2};%%%%%%%%%
                end
            elseif (value1 == 2)
                if (~isempty(resul.opcode{indresul}))
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop);%%%%%%%5
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},poly1.opcode{1});%%%%%%%%%
                else
                    resul.opcode{indresul} = poly1.opcode{1};%%%%%%%%
                end
            else
                if (subtr)
                    linkop = [];
                else
                    linkop = '+';
                end
                if (isempty(resul.opcode{indresul}))
                    linkop = [];
                end
                
                %Analysis if is necessary to use parenthesis
                openpar1 = [];
                closepar1 = [];
                contop1 = 1;
                finish = false;
                while ((contop1 <= length(poly1.opcode{1})) && (~finish))
                    if ((poly1.opcode{1}(contop1) == '+') || (poly1.opcode{1}(contop1) == '-'))
                        finish = true;
                        openpar1 = '(';
                        closepar1 = ')';
                    end
                    contop1 = contop1 + 1;
                end
                
                openpar2 = [];
                closepar2 = [];
                contop2 = 2;
                finish = false;
                while ((contop2 <= length(poly2.opcode{cont2})) && (~finish))
                    if ((poly2.opcode{cont2}(contop2) == '+') || (poly2.opcode{cont2}(contop2) == '-'))
                        finish = true;
                        openpar2 = '(';
                        closepar2 = ')';
                    end
                    contop2 = contop2 + 1;
                end
                
                resul.opcode{indresul} = strcat(resul.opcode{indresul},strcat(linkop,strcat(openpar1,strcat(poly1.opcode{1},strcat(closepar1,strcat('*',strcat(openpar2,strcat(poly2.opcode{cont2},closepar2))))))));
            end
        end
    elseif (length(poly2.data) == 1) %Poly2 is a constant
        for cont1=1:length(poly1.data)
            exponent = poly1.data(cont1).exponent;
            
            hash = sum(base.*exponent);
            indresul = find(indhash==hash);
            
            resul.data(indresul).exponent = exponent;
            resul.data(indresul).value = resul.data(indresul).value + (poly1.data(cont1).value*poly2.data(1).value);
            if (value1 == 1)
                if (~isempty(resul.opcode{indresul}))
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop);%%%%%%%%
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},poly2.opcode{1});%%%%%%%%%
                else
                    resul.opcode{indresul} = poly2.opcode{1};%%%%%%%%%%%
                end
            elseif (value1 == 2)
                if (~isempty(resul.opcode{indresul}))
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop);%%%%%%%%%%
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},poly1.opcode{cont1});%%%%%%%%%
                else
                    resul.opcode{indresul} = poly1.opcode{cont1};%%%%%%%%%%
                end
            else
                if (subtr)
                    linkop = [];
                else
                    linkop = '+';
                end
                if (isempty(resul.opcode{indresul}))
                    linkop = [];
                end
                
                %Analysis if is necessary to use parenthesis
                openpar1 = [];
                closepar1 = [];
                contop1 = 1;
                finish = false;
                while ((contop1 <= length(poly1.opcode{cont1})) && (~finish))
                    if ((poly1.opcode{cont1}(contop1) == '+') || (poly1.opcode{cont1}(contop1) == '-'))
                        finish = true;
                        openpar1 = '(';
                        closepar1 = ')';
                    end
                    contop1 = contop1 + 1;
                end
                
                openpar2 = [];
                closepar2 = [];
                contop2 = 2;
                finish = false;
                while ((contop2 <= length(poly2.opcode{1})) && (~finish))
                    if ((poly2.opcode{1}(contop2) == '+') || (poly2.opcode{1}(contop2) == '-'))
                        finish = true;
                        openpar2 = '(';
                        closepar2 = ')';
                    end
                    contop2 = contop2 + 1;
                end

                resul.opcode{indresul} = strcat(resul.opcode{indresul},strcat(linkop,strcat(openpar1,strcat(poly1.opcode{cont1},strcat(closepar1,strcat('*',strcat(openpar2,strcat(poly2.opcode{1},closepar2))))))));
            end
        end
    else %Both are polynomials
        for cont1=1:length(poly1.data)
            for cont2=1:length(poly2.data)
                exponent = poly1.data(cont1).exponent + poly2.data(cont2).exponent;
                
                hash = sum(base.*exponent);
                indresul = find(indhash==hash);
                
                if (indresul == 3)
                    indresul;
                end

                resul.data(indresul).exponent = exponent;
                resul.data(indresul).value = resul.data(indresul).value + (poly1.data(cont1).value*poly2.data(cont2).value);
                if (value1 == 1)
                    if (~isempty(resul.opcode{indresul}))
                        resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop);%%%%%%%%%
                        resul.opcode{indresul} = strcat(resul.opcode{indresul},poly2.opcode{cont2});%%%%%%%%%
                    else
                        resul.opcode{indresul} = poly2.opcode{cont2};%%%%%%%%
                    end
                elseif (value1 == 2)
                    if (~isempty(resul.opcode{indresul}))
                        resul.opcode{indresul} = strcat(resul.opcode{indresul},linkop);%%%%%%%
                        resul.opcode{indresul} = strcat(resul.opcode{indresul},poly1.opcode{cont1});%%%%%%%%%%
                    else
                        resul.opcode{indresul} = poly1.opcode{cont1};%%%%%%%%%%
                    end
                else
                    if (subtr)
                        linkop = '+';
                    else
                        linkop = '+';
                    end
                    if (isempty(resul.opcode{indresul}))
                        linkop = [];
                    end

                    %Analysis if is necessary to use parenthesis
                    openpar1 = [];
                    closepar1 = [];
                    contop1 = 1;
                    finish = false;
                    while ((contop1 <= length(poly1.opcode{cont1})) && (~finish))
                        if ((poly1.opcode{cont1}(contop1) == '+') || (poly1.opcode{cont1}(contop1) == '-'))
                            finish = true;
                            openpar1 = '(';
                            closepar1 = ')';
                        end
                        contop1 = contop1 + 1;
                    end
                    
                    openpar2 = [];
                    closepar2 = [];
                    contop2 = 2;
                    finish = false;
                    while ((contop2 <= length(poly2.opcode{cont2})) && (~finish))
                        if ((poly2.opcode{cont2}(contop2) == '+') || (poly2.opcode{cont2}(contop2) == '-'))
                            finish = true;
                            openpar2 = '(';
                            closepar2 = ')';
                        end
                        contop2 = contop2 + 1;
                    end
                    
                    resul.opcode{indresul} = strcat(resul.opcode{indresul},strcat(linkop,strcat(openpar1,strcat(poly1.opcode{cont1},strcat(closepar1,strcat('*',strcat(openpar2,strcat(poly2.opcode{cont2},closepar2))))))));
                    %resul.opcode{indresul} = strcat(resul.opcode{indresul},strcat(linkop,strcat(poly1.opcode{cont1},strcat('*',poly2.opcode{cont2}))));
                end
            end
        end
    end
end
if ((op == '+') || (op == '-'))
    for cont=1:length(poly1.data)
        hash = sum(base.*poly1.data(cont).exponent);
        indresul = find(indhash==hash);
        resul.data(indresul).exponent = poly1.data(indresul).exponent;
        resul.data(indresul).value = resul.data(indresul).value + poly1.data(indresul).value;

        hash = sum(base.*poly2.data(cont).exponent);
        indresul = find(indhash==hash);
        if (op == '+')
            resul.data(indresul).value = resul.data(indresul).value + poly2.data(indresul).value;
            resul.opcode{indresul} = strcat(strcat(poly1.opcode{cont},'+'),poly2.opcode{cont});
        else
            resul.data(indresul).value = resul.data(indresul).value - poly2.data(indresul).value;
            resul.opcode{indresul} = strcat(strcat(poly1.opcode{cont},'-'),strcat('(',strcat(poly2.opcode{cont},')')));
        end
    end
end

resul.vertices = max(poly1.vertices,poly2.vertices);

return
