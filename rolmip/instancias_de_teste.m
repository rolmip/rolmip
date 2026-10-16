function instancias_de_teste
global A1 A2 A3 A4 A5 A6;
global B1 B2 B3 B4 B5 B6;
global C1 C2 C3 C4 C5 C6;
A1 = [1 2; 1 3];
A2 = [2 0; 1 2];
A3 = [1 5; 3 1];
A4 = [2 3; 3 2];
A5 = [2 2; 1 4];
A6 = [4 6; 0 3];
B1 = [2 3; 1 4];
B2 = [1 1; 1 2];
B3 = [5 1; 2 3];
B4 = [1 3; 2 1];
B5 = [5 4; 1 1];
B6 = [2 7; 7 3];
C1 = [2 1; 2 1];
C2 = [1 3; 4 1];
C3 = [2 3; 3 1];
C4 = [1 2; 2 3];
C5 = [6 4; 2 4];
C6 = [5 1; 6 9];

%poly_struct\( *([^,]*) *, *'([A-Za-z0-9]*)', *(.*)\);
%A e B sao variaveis de 2 vertices de grau 1 no simplex 1.
 
disp('Teste 1');
clear Ai Bi Ci A B conf Ai Bi;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[1 0],B1};
B{2} = {[0 1],B2};
Bi = rolmipvar(B,'B',2,1);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
end

disp('Teste 1a');
clear conf;
a1 = 0.4; a2 = 0.6; b1 = 0.2; b2 = 0.8;
conf(1) = norm(evalpar(Ai,{[a1 a2]}) - (a1*A1 + a2*A2));
conf(2) = norm(evalpar(Bi,{[b1 b2]}) - (b1*B1 + b2*B2));
a1 = 0.55; a2 = 0.45; b1 = 0.32; b2 = 0.68;
conf(3) = norm(evalpar(Ai,{[a1 a2]}) - (a1*A1 + a2*A2));
conf(4) = norm(evalpar(Bi,{[b1 b2]}) - (b1*B1 + b2*B2));

if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 2');
clear Ai Bi Ci A B conf Ai Bi;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
B{2} = B2;
Bi = rolmipvar(B,'B',2,1);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 3');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Bi = rolmipvar([B1 B2],'B',2,1);
resul = vertices(Ai*Bi);
	
conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end
%poly_struct\( *([^,]*) *, *'([A-Za-z0-9]*)', *(.*)\);

%A eh uma variavel de 2 vertices no simplex 1, e B nao depende de
%parametros


disp('Teste 4');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 4a');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
Ai = rolmipvar(A,'A',2,1);
Ai([0 1]) = A2;
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 5');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B',0,0);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 6');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Bi = rolmipvar(B1,'B',0,0);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 7');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 8');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B',0,0);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 9');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Bi = rolmipvar(B1,'B',0,0);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 10');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 11');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B',0,0);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 12');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Bi = rolmipvar(B1,'B');
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



%A eh uma variavel de dois vertices e grau 1 no simplex 1, e B eh uma
%variavel de 2 vertices e grau 2 no simplex 1.

disp('Teste 13');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 13a');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
Bi([1 1]) = B2;
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 14');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{3} = {[2 0],B1};
B{1} = {[1 1],B2};
B{2} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 14a');
clear conf;
a1 = 0.4; a2 = 0.6; b1 = 0.2; b2 = 0.8;
conf(1) = norm(evalpar(Ai,{[a1 a2]}) - (a1*A1 + a2*A2));
conf(2) = norm(evalpar(Bi,{[b1 b2]}) - (b1^2*B1 + b1*b2*B2 + b2^2*B3));
a1 = 0.35; a2 = 0.65; b1 = 0.61; b2 = 0.39;
conf(3) = norm(evalpar(Ai,{[a1 a2]}) - (a1*A1 + a2*A2));
conf(4) = norm(evalpar(Bi,{[b1 b2]}) - (b1^2*B1 + b1*b2*B2 + b2^2*B3));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 15');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 15a');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[1 1],B2};
B{2} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
Bi([2 0]) = B1;
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
end



disp('Teste 16');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
conf(3) = norm(resul{3} - (A1*B3 + A2*B2));
conf(4) = norm(resul{4} - A2*B3);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%A eh uma variavel de 2 vertices, grau 1 no simplex 1, e I eh a identidade

%Identidade de 2 vertices e grau 1 no simplex 1

disp('Teste 17');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 18');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 19');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 20');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 21');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 22');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 23');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 24');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 25');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - (A1 + A2));
conf(3) = norm(resul{3} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%Identidade eh uma matriz independente de parametros

disp('Teste 26');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar(eye(2),'I');
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 27');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 28');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
poly_struct(eye(2),'I');
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 28');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 29');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
poly_struct(eye(2),'I');
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 30');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end

%A eh uma variavel de 2 vertices, grau 1 no simplex 1, e c eh um escalar

disp('Teste 31');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
c = 10;
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
ci = rolmipvar(c,  'c', 'scalar');
resul = vertices(Ai*ci);

conf(1) = norm(resul{1} - c*A1);
conf(2) = norm(resul{2} - c*A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 32');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
c = 10;
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
ci = rolmipvar(c,  'c', 'scalar');
resul = vertices(Ai*ci);

conf(1) = norm(resul{1} - c*A1);
conf(2) = norm(resul{2} - c*A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end

disp('Teste 33');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
c = 10;
Ai = rolmipvar([A1 A2],'A',2,1);
ci = rolmipvar(c,  'c', 'scalar');
resul = vertices(Ai*ci);

conf(1) = norm(resul{1} - c*A1);
conf(2) = norm(resul{2} - c*A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



%A eh uma variavel de 2 vertices e grau 1 no simplex 1;
%B eh uma variavel de 2 vertices e grau 1 no simplex 2
 
disp('Teste 34');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 34a');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {[0 0],[1 0],B1};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
Bi([0 0],[0 1]) = B2;
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 35');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {0,[1 0],B1};
B{2} = {0,[0 1],B2};
Bi = rolmipvar(B,'B',[0 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 36');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {0,[1 0],B1};
B{2} = {0,[0 1],B2};
Bi = rolmipvar(B,'B',[0 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 37');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 38');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 39');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 40');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{2} - A2*B1);
conf(3) = norm(resul{3} - A1*B2);
conf(4) = norm(resul{4} - A2*B2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



%A eh uma variavel de 2 vertices e grau 1 no simplex 1;
%B eh uma variavel de 2 vertices e grau 1 no simplex 1 e 2 vertices e grau
%1 no vertice 2.
 
disp('Teste 41');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{4} - A1*B2);
conf(3) = norm(resul{2} - (A1*B3 + A2*B1));
conf(4) = norm(resul{5} - (A1*B4 + A2*B2));
conf(5) = norm(resul{3} - A2*B3);
conf(6) = norm(resul{6} - A2*B4);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 41a');
clear conf;
a1 = 0.9; a2 = 0.1; b1 = 0.4; b2 = 0.6;
conf(1) = norm(evalpar(Bi,{[a1 a2],[b1 b2]}) - (a1*b1*B1 + a1*b2*B2 + a2*b1*B3 + a2*b2*B4));
a1 = 0.15; a2 = 0.85; b1 = 0.33; b2 = 0.67;
conf(2) = norm(evalpar(Bi,{[a1 a2],[b1 b2]}) - (a1*b1*B1 + a1*b2*B2 + a2*b1*B3 + a2*b2*B4));
if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 42');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{4} - A1*B2);
conf(3) = norm(resul{2} - (A1*B3 + A2*B1));
conf(4) = norm(resul{5} - (A1*B4 + A2*B2));
conf(5) = norm(resul{3} - A2*B3);
conf(6) = norm(resul{6} - A2*B4);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 42a');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {[1 0],[1 0],B1};
B{2} = {[0 1],[1 0],B3};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
Bi([1 0],[0 1]) = B2;
Bi([0 1],[0 1]) = B4;
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{4} - A1*B2);
conf(3) = norm(resul{2} - (A1*B3 + A2*B1));
conf(4) = norm(resul{5} - (A1*B4 + A2*B2));
conf(5) = norm(resul{3} - A2*B3);
conf(6) = norm(resul{6} - A2*B4);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 43');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{4} - A1*B2);
conf(3) = norm(resul{2} - (A1*B3 + A2*B1));
conf(4) = norm(resul{5} - (A1*B4 + A2*B2));
conf(5) = norm(resul{3} - A2*B3);
conf(6) = norm(resul{6} - A2*B4);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 44');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai*Bi);

conf(1) = norm(resul{1} - A1*B1);
conf(2) = norm(resul{4} - A1*B2);
conf(3) = norm(resul{2} - (A1*B3 + A2*B1));
conf(4) = norm(resul{5} - (A1*B4 + A2*B2));
conf(5) = norm(resul{3} - A2*B3);
conf(6) = norm(resul{6} - A2*B4);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%A eh uma variavel de 2 vertices, grau 1, simplex 1. 
%I eh a identidade, de 2 vertices no simplex 2.

disp('Teste 45');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
I{1} = {[0 0],[1 0],eye(2)};
I{2} = {[0 0],[0 1],eye(2)};
Ii = rolmipvar(I,  'I', [2 2],[0 1]);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);
conf(3) = norm(resul{3} - A1);
conf(4) = norm(resul{4} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 46');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
I{1} = {0,[1 0],eye(2)};
I{2} = {0,[0 1],eye(2)};
Ii = rolmipvar(I,  'I', [0 2],[0 1]);
resul = vertices(Ai*Ii);

conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);
conf(3) = norm(resul{3} - A1);
conf(4) = norm(resul{4} - A2);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%A e B sao variaveis de 2 vertices de grau 1 no simplex 1.
 
disp('Teste 47');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[1 0],B1};
B{2} = {[0 1],B2};
Bi = rolmipvar(B,'B',2,1);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 48');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
B{2} = B2;
Bi = rolmipvar(B,'B',2,1);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 49');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Bi = rolmipvar([B1 B2],'B',2,1);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%A eh uma variavel de 2 vertices no simplex 1, e B nao depende de
%parametros


disp('Teste 50');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 51');
clear Ai Bi Ci A B conf Ai Bi;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B');
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 52');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Bi = rolmipvar(B1,'B',0,0);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 53');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 54');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B',0,0);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 55');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Bi = rolmipvar(B1,'B');
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 56');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[0 0],B1};
Bi = rolmipvar(B,'B',2,0); %COMO DEFINIU B{1} USANDO 2 VERTICES, NAO FAZ SENTIDO USAR 0 VERTICES AQUI!!!
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 57');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = B1;
Bi = rolmipvar(B,'B',0,0);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 58');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Bi = rolmipvar(B1,'B',0,0);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A2+B1));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



%A eh uma variavel de 2 vertices e grau 1 no simplex 1, e B eh uma
%variavel de 2 vertices e grau 2 no simplex 1.

disp('Teste 59');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A1 + A2 + B2));
conf(3) = norm(resul{3} - (A2 + B3));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 60');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{3} = {[2 0],B1};
B{1} = {[1 1],B2};
B{2} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A1 + A2 + B2));
conf(3) = norm(resul{3} - (A2 + B3));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 61');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A1 + A2 + B2));
conf(3) = norm(resul{3} - (A2 + B3));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 62');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1+B1));
conf(2) = norm(resul{2} - (A1 + A2 + B2));
conf(3) = norm(resul{3} - (A2 + B3));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%A eh uma variavel de 2 vertices, grau 1 no simplex 1, e I eh a identidade

%Identidade de 2 vertices e grau 1 no simplex 1

disp('Teste 63');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 64');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 65');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 66');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 67');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 68');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 69');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
I{1} = {[1 0],eye(2)};
I{2} = {[0 1],eye(2)};
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 70');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
I{1} = eye(2);
I{2} = eye(2);
Ii = rolmipvar(I,  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 71');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Ii = rolmipvar([eye(2) eye(2)],  'I', 2,1);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%Identidade eh uma matriz independente de parametros

disp('Teste 72');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
poly_struct(eye(2),'I');
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 73');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 74');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
poly_struct(eye(2),'I');
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 75');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 76');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
poly_struct(eye(2),'I');
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end




disp('Teste 77');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
Ii = rolmipvar(eye(2),  'I', 0,0);
resul = vertices(Ai+Ii);

conf(1) = norm(resul{1} - (A1 + eye(2)));
conf(2) = norm(resul{2} - (A2 + eye(2)));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%A eh uma variavel de 2 vertices e grau 1 no simplex 1;
%B eh uma variavel de 2 vertices e grau 1 no simplex 2
 
disp('Teste 78');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 79');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {0,[1 0],B1};
B{2} = {0,[0 1],B2};
Bi = rolmipvar(B,'B',[0 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 80');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {0,[1 0],B1};
B{2} = {0,[0 1],B2};
Bi = rolmipvar(B,'B',[0 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 81');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



disp('Teste 82');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 83');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 84');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
Bi = rolmipvar(B,'B',[2 2],[0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



%A eh uma variavel de 2 vertices e grau 1 no simplex 1;
%B eh uma variavel de 2 vertices e grau 1 no simplex 1 e 2 vertices e grau
%1 no vertice 2.
 
disp('Teste 85');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],[0 0],A1};
A{2} = {[0 1],[0 0],A2};
Ai = rolmipvar(A,'A',[2 2],[1 0]);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B3));
conf(4) = norm(resul{4} - (A2 + B4));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 86');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1 0],0,A1};
A{2} = {[0 1],0,A2};
Ai = rolmipvar(A,'A',[2 0],[1 0]);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B3));
conf(4) = norm(resul{4} - (A2 + B4));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 87');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B3));
conf(4) = norm(resul{4} - (A2 + B4));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 88');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
Ai = rolmipvar([A1 A2],'A',2,1);
B{1} = {[1 0],[1 0],B1};
B{2} = {[1 0],[0 1],B2};
B{3} = {[0 1],[1 0],B3};
B{4} = {[0 1],[0 1],B4};
Bi = rolmipvar(B,'B',[2 2],[1 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B3));
conf(4) = norm(resul{4} - (A2 + B4));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


% Testes de montagem de LMIs 

% M11 eh uma variavel de 2 vertices, grau 1 no simplex 1.
% M12 eh uma variavel de 2 vertices, grau 1 no simplex 1.
% M22 eh uma variavel de 2 vertices, grau 1 no simplex 1.

disp('Teste 89');
clear Ai Bi Ci M M11i M12i M22i conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {[1 0],B1};
M12{2} = {[0 1],B2};
M12i = rolmipvar(M12,  'M12', 2,1);
M22{1} = {[1 0],A1};
M22{2} = {[0 1],A2};
M22i = rolmipvar(M22,  'M22', 2,1);

resul = vertices([M11i M12i; M12i' M22i]);

conf(1) = norm(resul{1} - [A1 B1; B1' A1]);
conf(2) = norm(resul{2} - [A2 B2; B2' A2]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 90');
clear Ai Bi Ci M M11 M12 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = B1;
M12{2} = B2;
M12i = rolmipvar(M12,  'M12', 2,1);
M22i = rolmipvar([A1 A2],  'M22', 2,1);

resul = vertices([M11i M12i; M12i' M22i]);

conf(1) = norm(resul{1} - [A1 B1; B1' A1]);
conf(2) = norm(resul{2} - [A2 B2; B2' A2]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


% M11 eh uma variavel de 2 vertices, grau 1 no simplex 1.
% M12 eh uma variavel independente de parametros.
% M21 eh uma variavel independente de parametros.
% M22 eh uma variavel de 2 vertices, grau 2 no simplex 1.

disp('Teste 91');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {0,B1};
M12i = rolmipvar(M12,  'M12', 0,0);
M21i = rolmipvar(B2,  'M21', 0,0);
M22{1} = {[2 0],A1};
M22{2} = {[0 2],A3};
M22{3} = {[1 1],A2};
M22i = rolmipvar(M22,  'M22', 2,2);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B2 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B2 A2]);
conf(3) = norm(resul{3} - [A2 B1; B2 A3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 92');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {[0 0],B1};
M12i = rolmipvar(M12,  'M12', 2,0);
M21i = rolmipvar(B2,  'M21', 0,0);
M22{1} = {[2 0],A1};
M22{2} = {[0 2],A3};
M22{3} = {[1 1],A2};
M22i = rolmipvar(M22,  'M22', 2,2);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B2 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B2 A2]);
conf(3) = norm(resul{3} - [A2 B1; B2 A3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end



% M11 eh uma variavel de 2 vertices, grau 1 no simplex 1.
% M12 eh uma variavel de 2 vertices, grau 1 no simplex 2.
% M21 eh uma variavel independente de parametros.
% M22 eh uma variavel de 2 vertices, grau 2 no simplex 1 e 2 vertices, grau 1 no simplex 2.

disp('Teste 93');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {0,[1 0],B1};
M12{2} = {0,[0 1],B2};
M12i = rolmipvar(M12,  'M12', [0 2],[0 1]);
M21i = rolmipvar(B3,  'M21', 0,0);
M22{1} = {[2 0],[1 0],A1};
M22{2} = {[0 2],[1 0],A3};
M22{3} = {[1 1],[1 0],A2};
M22{4} = {[2 0],[0 1],B1};
M22{5} = {[0 2],[0 1],B3};
M22{6} = {[1 1],[0 1],B2};
M22i = rolmipvar(M22,  'M22', [2 2],[2 1]);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B3 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B3 A2]);
conf(3) = norm(resul{3} - [A2 B1; B3 A3]);
conf(4) = norm(resul{4} - [A1 B2; B3 B1]);
conf(5) = norm(resul{5} - [A1+A2 2*B2; 2*B3 B2]);
conf(6) = norm(resul{6} - [A2 B2; B3 B3]);

if (sum(conf) ~= 0)
    error('Nao passou');
end




disp('Teste 93a');
clear conf;
a1 = 0.3; a2 = 0.7; b1 = 0.2; b2 = 0.8;
conf(1) = norm(evalpar(M22i,{[a1 a2],[b1 b2]}) - (a1^2*b1*A1 + a2^2*b1*A3 + a1*a2*b1*A2 + a1^2*b2*B1 + a2^2*b2*B3 + a1*a2*b2*B2));
a1 = 0.65; a2 = 0.35; b1 = 0.19; b2 = 0.81;
conf(2) = norm(evalpar(M22i,{[a1 a2],[b1 b2]}) - (a1^2*b1*A1 + a2^2*b1*A3 + a1*a2*b1*A2 + a1^2*b2*B1 + a2^2*b2*B3 + a1*a2*b2*B2));
a1 = 0.1; a2 = 0.9; b1 = 0.25; b2 = 0.75;
conf(3) = norm(evalpar(M22i,{[a1 a2],[b1 b2]}) - (a1^2*b1*A1 + a2^2*b1*A3 + a1*a2*b1*A2 + a1^2*b2*B1 + a2^2*b2*B3 + a1*a2*b2*B2));
if (sum(roundn(conf,-10)) ~= 0)
    error('Nao passou');
end



disp('Teste 94');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],[0 0],A1};
M11{2} = {[0 1],[0 0],A2};
M11i = rolmipvar(M11,  'M11', [2 0],[1 0]);
M12{1} = {0,[1 0],B1};
M12{2} = {0,[0 1],B2};
M12i = rolmipvar(M12,  'M12', [0 2],[0 1]);
M21i = rolmipvar(B3,  'M21', 0,0);
M22{1} = {[2 0],[1 0],A1};
M22{2} = {[0 2],[1 0],A3};
M22{3} = {[1 1],[1 0],A2};
M22{4} = {[2 0],[0 1],B1};
M22{5} = {[0 2],[0 1],B3};
M22{6} = {[1 1],[0 1],B2};
M22i = rolmipvar(M22,  'M22', [2 2],[2 1]);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B3 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B3 A2]);
conf(3) = norm(resul{3} - [A2 B1; B3 A3]);
conf(4) = norm(resul{4} - [A1 B2; B3 B1]);
conf(5) = norm(resul{5} - [A1+A2 2*B2; 2*B3 B2]);
conf(6) = norm(resul{6} - [A2 B2; B3 B3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 95');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = A1;
M11{2} = A2;
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {0,[1 0],B1};
M12{2} = {0,[0 1],B2};
M12i = rolmipvar(M12,  'M12', [0 2],[0 1]);
M21i = rolmipvar(B3,  'M21', 0,0);
M22{1} = {[2 0],[1 0],A1};
M22{2} = {[0 2],[1 0],A3};
M22{3} = {[1 1],[1 0],A2};
M22{4} = {[2 0],[0 1],B1};
M22{5} = {[0 2],[0 1],B3};
M22{6} = {[1 1],[0 1],B2};
M22i = rolmipvar(M22,  'M22', [2 2],[2 1]);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B3 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B3 A2]);
conf(3) = norm(resul{3} - [A2 B1; B3 A3]);
conf(4) = norm(resul{4} - [A1 B2; B3 B1]);
conf(5) = norm(resul{5} - [A1+A2 2*B2; 2*B3 B2]);
conf(6) = norm(resul{6} - [A2 B2; B3 B3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 96');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {[0 0],[1 0],B1};
M12{2} = {[0 0],[0 1],B2};
M12i = rolmipvar(M12,  'M12', [0 2],[0 1]);
M21i = rolmipvar(B3,  'M21', 0,0);
M22{1} = {[2 0],[1 0],A1};
M22{2} = {[0 2],[1 0],A3};
M22{3} = {[1 1],[1 0],A2};
M22{4} = {[2 0],[0 1],B1};
M22{5} = {[0 2],[0 1],B3};
M22{6} = {[1 1],[0 1],B2};
M22i = rolmipvar(M22,  'M22', [2 2],[2 1]);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B3 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B3 A2]);
conf(3) = norm(resul{3} - [A2 B1; B3 A3]);
conf(4) = norm(resul{4} - [A1 B2; B3 B1]);
conf(5) = norm(resul{5} - [A1+A2 2*B2; 2*B3 B2]);
conf(6) = norm(resul{6} - [A2 B2; B3 B3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 97');
clear Ai Bi Ci M M11 M12 M21 M22 conf;
rolmip('clearvar');
M11{1} = {[1 0],A1};
M11{2} = {[0 1],A2};
M11i = rolmipvar(M11,  'M11', 2,1);
M12{1} = {0,[1 0],B1};
M12{2} = {0,[0 1],B2};
M12i = rolmipvar(M12,  'M12', [0 2],[0 1]);
M21{1} = {0,0,B3};
M21i = rolmipvar(M21,  'M21', [0 0],[0 0]);
M22{1} = {[2 0],[1 0],A1};
M22{2} = {[0 2],[1 0],A3};
M22{3} = {[1 1],[1 0],A2};
M22{4} = {[2 0],[0 1],B1};
M22{5} = {[0 2],[0 1],B3};
M22{6} = {[1 1],[0 1],B2};
M22i = rolmipvar(M22,  'M22', [2 2],[2 1]);

resul = vertices([M11i M12i; M21i M22i]);

conf(1) = norm(resul{1} - [A1 B1; B3 A1]);
conf(2) = norm(resul{2} - [A1+A2 2*B1; 2*B3 A2]);
conf(3) = norm(resul{3} - [A2 B1; B3 A3]);
conf(4) = norm(resul{4} - [A1 B2; B3 B1]);
conf(5) = norm(resul{5} - [A1+A2 2*B2; 2*B3 B2]);
conf(6) = norm(resul{6} - [A2 B2; B3 B3]);

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


%Testes com os numeros de vertices
disp('Teste 98');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1],0,[1 0],A1};
A{2} = {[1],0,[0 1],A2};
Ai = rolmipvar(A,'A',[1 0 2],[1 0 1]);
B{1} = {[1],[1 0],0,B1};
B{2} = {[1],[0 1],0,B2};
Bi = rolmipvar(B,'B',[1 2 0],[1 1 0]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A2 + B1));
conf(3) = norm(resul{2} - (A1 + B2));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 99');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1],0,[1 0],A1};
A{2} = {[1],0,[0 1],A2};
Ai = rolmipvar(A,'A',[1 0 2],[1 0 1]);
B{1} = {[1],[1 0],B1};
B{2} = {[1],[0 1],B2};
Bi = rolmipvar(B,'B',[1 2],[1 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A2 + B1));
conf(3) = norm(resul{2} - (A1 + B2));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end

disp('Teste 100');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1],[1 0],0,A1};
A{2} = {[1],[0 1],0,A2};
Ai = rolmipvar(A,'A',[1 2 0],[1 1 0]);
B{1} = {[1],0,[1 0],B1};
B{2} = {[1],0,[0 1],B2};
Bi = rolmipvar(B,'B',[1 0 2],[1 0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end


disp('Teste 101');
clear Ai Bi Ci A B conf;
rolmip('clearvar');
A{1} = {[1],[1 0],A1};
A{2} = {[1],[0 1],A2};
Ai = rolmipvar(A,'A',[1 2],[1 1]);
B{1} = {[1],0,[1 0],B1};
B{2} = {[1],0,[0 1],B2};
Bi = rolmipvar(B,'B',[1 0 2],[1 0 1]);
resul = vertices(Ai+Bi);

conf(1) = norm(resul{1} - (A1 + B1));
conf(2) = norm(resul{3} - (A1 + B2));
conf(3) = norm(resul{2} - (A2 + B1));
conf(4) = norm(resul{4} - (A2 + B2));

if (sum(conf) ~= 0)
    error('Nao passou');
    
end

%%% Testando a interpretação das operações matemáticas
%poly_struct\( *([^,]*) *, *'([A-Za-z0-9]*)', *(.*)\);

%A+B
clear operacao;
operacao{1} = 'Ai+Bi';
operacao{2} = 'Bi+Ai';
disp('Teste 102');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1 + B1));
    conf(2) = norm(resul{2} - (A2 + B2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1));
        conf(2) = norm(resul{2} - (A2 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1));
        conf(2) = norm(resul{3} - (A2 + B1));
        conf(3) = norm(resul{2} - (A3 + B1));
        conf(4) = norm(resul{4} - (A4 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1));
        conf(2) = norm(resul{3} - (A2 + B2));
        conf(3) = norm(resul{2} - (A3 + B1));
        conf(4) = norm(resul{4} - (A4 + B2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1));
        conf(2) = norm(resul{3} - (A2 + B2));
        conf(3) = norm(resul{5} - (A3 + B3));
        conf(4) = norm(resul{2} - (A4 + B1));
        conf(5) = norm(resul{4} - (A5 + B2));
        conf(6) = norm(resul{6} - (A6 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1));
        conf(2) = norm(resul{2} - (A1 + A3 + B2));
        conf(3) = norm(resul{3} - (A3 + B3));
        conf(4) = norm(resul{4} - (A2 + B1));
        conf(5) = norm(resul{5} - (A2 + A4 + B2));
        conf(6) = norm(resul{6} - (A4 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1 + B1));
    conf(2) = norm(resul{2} - (A1 + A3 + B2));
    conf(3) = norm(resul{3} - (A3 + B3));
    conf(4) = norm(resul{4} - (A2 + B4));
    conf(5) = norm(resul{5} - (A2 + A4 + B5));
    conf(6) = norm(resul{6} - (A4 + B6));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end

%A+B+C
clear Ai Bi Ci operacao;
operacao{1} = 'Ai+Bi+Ci';
operacao{2} = 'Ai+Ci+Bi';
operacao{3} = 'Bi+Ai+Ci';
operacao{4} = 'Bi+Ci+Ai';
operacao{5} = 'Ci+Ai+Bi';
operacao{6} = 'Ci+Bi+Ai';
disp('Teste 103');
for indop=1:6
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1 + B1 + C1));
    conf(2) = norm(resul{2} - (A2 + B2 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{2} - (A1 + A2 + 2*B1 + C2));
        conf(3) = norm(resul{3} - (A2 + B1 + C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{2} - (A2 + B1 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{3} - (A1 + B1 + C2));
        conf(3) = norm(resul{2} - (A2 + B1 + C1));
        conf(4) = norm(resul{4} - (A2 + B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{3} - (A2 + B1 + C1));
        conf(3) = norm(resul{2} - (A3 + B1 + C2));
        conf(4) = norm(resul{4} - (A4 + B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{3} - (A2 + B2 + C1));
        conf(3) = norm(resul{2} - (A3 + B1 + C2));
        conf(4) = norm(resul{4} - (A4 + B2 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{3} - (A2 + B2 + C1));
        conf(3) = norm(resul{5} - (A3 + B3 + C1));
        conf(4) = norm(resul{2} - (A4 + B1 + C1));
        conf(5) = norm(resul{4} - (A5 + B2 + C1));
        conf(6) = norm(resul{6} - (A6 + B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{3} - (A2 + B2 + C1));
        conf(3) = norm(resul{5} - (A3 + B3 + C1));
        conf(4) = norm(resul{2} - (A4 + B1 + C2));
        conf(5) = norm(resul{4} - (A5 + B2 + C2));
        conf(6) = norm(resul{6} - (A6 + B3 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1 + B1 + C1));
        conf(2) = norm(resul{2} - (A1 + A3 + B2 + 2*C1));
        conf(3) = norm(resul{3} - (A3 + B3 + C1));
        conf(4) = norm(resul{4} - (A2 + B1 + C1));
        conf(5) = norm(resul{5} - (A2 + A4 + B2 + 2*C1));
        conf(6) = norm(resul{6} - (A4 + B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1 + B1 + C1));
    conf(2) = norm(resul{2} - (A1 + A3 + B2 + C1 + C2));
    conf(3) = norm(resul{3} - (A3 + B3 + C2));
    conf(4) = norm(resul{4} - (A2 + B4 + C1));
    conf(5) = norm(resul{5} - (A2 + A4 + B5 + C1 + C2));
    conf(6) = norm(resul{6} - (A4 + B6 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end


%A*B
clear Ai Bi Ci operacao;
operacao{1} = 'Ai*Bi';
disp('Teste 104');
for indop=1:1
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1));
    conf(2) = norm(resul{2} - (A1*B2 + A2*B1));
    conf(3) = norm(resul{3} - (A2*B2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1));
        conf(2) = norm(resul{2} - (A2*B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1));
        conf(2) = norm(resul{3} - (A2*B1));
        conf(3) = norm(resul{2} - (A3*B1));
        conf(4) = norm(resul{4} - (A4*B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1));
        conf(2) = norm(resul{2} - (A3*B1));
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1));
        conf(4) = norm(resul{4} - (A3*B2 + A4*B1));
        conf(5) = norm(resul{5} - (A2*B2));
        conf(6) = norm(resul{6} - (A4*B2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1));
        conf(2) = norm(resul{2} - (A4*B1));
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1));
        conf(4) = norm(resul{4} - (A4*B2 + A5*B1));
        conf(5) = norm(resul{5} - (A1*B3 + A3*B1));
        conf(6) = norm(resul{6} - (A4*B3 + A6*B1));
        conf(7) = norm(resul{7} - (A2*B2));
        conf(8) = norm(resul{8} - (A5*B2));
        conf(9) = norm(resul{9} - (A2*B3 + A3*B2));
        conf(10) = norm(resul{10} - (A5*B3 + A6*B2));
        conf(11) = norm(resul{11} - (A3*B3));
        conf(12) = norm(resul{12} - (A6*B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1));
        conf(2) = norm(resul{2} - (A3*B1 + A1*B2));
        conf(3) = norm(resul{3} - (A1*B3 + A3*B2));
        conf(4) = norm(resul{4} - (A3*B3));
        conf(5) = norm(resul{5} - (A2*B1));
        conf(6) = norm(resul{6} - (A4*B1 + A2*B2));
        conf(7) = norm(resul{7} - (A4*B2 + A2*B3));
        conf(8) = norm(resul{8} - (A4*B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1));
    conf(2) = norm(resul{2} - (A1*B2 + A3*B1));
    conf(3) = norm(resul{3} - (A1*B3 + A3*B2));
    conf(4) = norm(resul{4} - (A3*B3));
    conf(5) = norm(resul{5} - (A1*B4 + A2*B1));
    conf(6) = norm(resul{6} - (A1*B5 + A2*B2 + A3*B4 + A4*B1));
    conf(7) = norm(resul{7} - (A1*B6 + A2*B3 + A3*B5 + A4*B2));
    conf(8) = norm(resul{8} - (A3*B6 + A4*B3));
    conf(9) = norm(resul{9} - (A2*B4));
    conf(10) = norm(resul{10} - (A2*B5 + A4*B4));
    conf(11) = norm(resul{11} - (A2*B6 + A4*B5));
    conf(12) = norm(resul{12} - (A4*B6));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%A*B*C
clear Ai Bi Ci operacao;
operacao{1} = 'Ai*Bi*Ci';
operacao{2} = '(Ai*Bi)*Ci';
operacao{3} = 'Ai*(Bi*Ci)';
operacao{4} = '(Ai*Bi*Ci)';
disp('Teste 105');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1*C1));
    conf(2) = norm(resul{2} - (A1*B1*C2 + A1*B2*C1 + A2*B1*C1));
    conf(3) = norm(resul{3} - (A1*B2*C2 + A2*B1*C2 + A2*B2*C1));
    conf(4) = norm(resul{4} - (A2*B2*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A1*B1*C2 + A2*B1*C1));
        conf(3) = norm(resul{3} - (A1*B1*C3 + A2*B1*C2));
        conf(4) = norm(resul{4} - (A2*B1*C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A2*B1*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{3} - (A1*B1*C2));
        conf(3) = norm(resul{2} - (A2*B1*C1));
        conf(4) = norm(resul{4} - (A2*B1*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A1*B1*C2 + A3*B1*C1));
        conf(3) = norm(resul{3} - (A3*B1*C2));
        conf(4) = norm(resul{4} - (A2*B1*C1));
        conf(5) = norm(resul{5} - (A2*B1*C2 + A4*B1*C1));
        conf(6) = norm(resul{6} - (A4*B1*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A1*B1*C2 + A3*B1*C1));
        conf(3) = norm(resul{3} - (A3*B1*C2));
        conf(4) = norm(resul{4} - (A2*B1*C1 + A1*B2*C1));
        conf(5) = norm(resul{5} - (A2*B1*C2 + A4*B1*C1 + A1*B2*C2 + A3*B2*C1));
        conf(6) = norm(resul{6} - (A4*B1*C2 + A3*B2*C2));
        conf(7) = norm(resul{7} - (A2*B2*C1));
        conf(8) = norm(resul{8} - (A2*B2*C2 + A4*B2*C1));
        conf(9) = norm(resul{9} - (A4*B2*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A4*B1*C1));
        conf(3) = norm(resul{3} - (A1*B2*C1 + A2*B1*C1));
        conf(4) = norm(resul{4} - (A4*B2*C1 + A5*B1*C1));
        conf(5) = norm(resul{5} - (A1*B3*C1 + A3*B1*C1));
        conf(6) = norm(resul{6} - (A4*B3*C1 + A6*B1*C1));
        conf(7) = norm(resul{7} - (A2*B2*C1));
        conf(8) = norm(resul{8} - (A5*B2*C1));
        conf(9) = norm(resul{9} - (A2*B3*C1 + A3*B2*C1));
        conf(10) = norm(resul{10} - (A5*B3*C1 + A6*B2*C1));
        conf(11) = norm(resul{11} - (A3*B3*C1));
        conf(12) = norm(resul{12} - (A6*B3*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A1*B1*C2 + A4*B1*C1));
        conf(3) = norm(resul{3} - (A4*B1*C2));
        conf(4) = norm(resul{4} - (A1*B2*C1 + A2*B1*C1));
        conf(5) = norm(resul{5} - (A1*B2*C2 + A2*B1*C2 + A4*B2*C1 + A5*B1*C1));
        conf(6) = norm(resul{6} - (A4*B2*C2 + A5*B1*C2));
        conf(7) = norm(resul{7} - (A1*B3*C1 + A3*B1*C1));
        conf(8) = norm(resul{8} - (A1*B3*C2 + A3*B1*C2 + A4*B3*C1 + A6*B1*C1));
        conf(9) = norm(resul{9} - (A4*B3*C2 + A6*B1*C2));
        conf(10) = norm(resul{10} - (A2*B2*C1));
        conf(11) = norm(resul{11} - (A2*B2*C2 +  A5*B2*C1));
        conf(12) = norm(resul{12} - (A5*B2*C2));
        conf(13) = norm(resul{13} - (A2*B3*C1 + A3*B2*C1));
        conf(14) = norm(resul{14} - (A2*B3*C2 + A3*B2*C2 + A5*B3*C1 + A6*B2*C1));
        conf(15) = norm(resul{15} - (A5*B3*C2 + A6*B2*C2));
        conf(16) = norm(resul{16} - (A3*B3*C1));
        conf(17) = norm(resul{17} - (A3*B3*C2 + A6*B3*C1));
        conf(18) = norm(resul{18} - (A6*B3*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1));
        conf(2) = norm(resul{2} - (A1*B2*C1 + A3*B1*C1));
        conf(3) = norm(resul{3} - (A1*B3*C1 + A3*B2*C1));
        conf(4) = norm(resul{4} - (A3*B3*C1));
        conf(5) = norm(resul{5} - (A2*B1*C1));
        conf(6) = norm(resul{6} - (A2*B2*C1 + A4*B1*C1));
        conf(7) = norm(resul{7} - (A2*B3*C1 + A4*B2*C1));
        conf(8) = norm(resul{8} - (A4*B3*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1*C1));
    conf(2) = norm(resul{2} - (A1*B1*C2 + A1*B2*C1 + A3*B1*C1));
    conf(3) = norm(resul{3} - (A1*B2*C2 + A1*B3*C1 + A3*B1*C2 + A3*B2*C1));
    conf(4) = norm(resul{4} - (A1*B3*C2 + A3*B2*C2 + A3*B3*C1));
    conf(5) = norm(resul{5} - (A3*B3*C2));
    conf(6) = norm(resul{6} - (A1*B4*C1 + A2*B1*C1));
    conf(7) = norm(resul{7} - (A1*B4*C2 + A1*B5*C1 + A2*B1*C2 + A2*B2*C1 + A3*B4*C1 + A4*B1*C1));
    conf(8) = norm(resul{8} - (A1*B5*C2 + A1*B6*C1 + A2*B2*C2 + A2*B3*C1 + A3*B4*C2 + A3*B5*C1 + A4*B1*C2 + A4*B2*C1));
    conf(9) = norm(resul{9} - (A1*B6*C2 + A2*B3*C2 + A3*B5*C2 + A3*B6*C1 + A4*B2*C2 + A4*B3*C1));
    conf(10) = norm(resul{10} - (A3*B6*C2 + A4*B3*C2));
    conf(11) = norm(resul{11} - (A2*B4*C1));
    conf(12) = norm(resul{12} - (A2*B4*C2 + A2*B5*C1 + A4*B4*C1));
    conf(13) = norm(resul{13} - (A2*B5*C2 + A2*B6*C1 + A4*B4*C2 + A4*B5*C1));
    conf(14) = norm(resul{14} - (A2*B6*C2 + A4*B5*C2 + A4*B6*C1));
    conf(15) = norm(resul{15} - (A4*B6*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%(A+B)*C
clear Ai Bi Ci operacao;
operacao{1} = '(Ai+Bi)*Ci';
operacao{2} = '(Bi+Ai)*Ci';
operacao{3} = 'Ai*Ci+Bi*Ci';
operacao{4} = 'Bi*Ci+Ai*Ci';
disp('Teste 106');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - ((A1+B1)*C1));
    conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A2+B2)*C1));
    conf(3) = norm(resul{3} - ((A2+B2)*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A2+B1)*C1));
        conf(3) = norm(resul{3} - ((A1+B1)*C3 + (A2+B1)*C2));
        conf(4) = norm(resul{4} - ((A2+B1)*C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A2+B1)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{3} - ((A1+B1)*C2));
        conf(3) = norm(resul{2} - ((A2+B1)*C1));
        conf(4) = norm(resul{4} - ((A2+B1)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A3+B1)*C1));
        conf(3) = norm(resul{3} - ((A3+B1)*C2));
        conf(4) = norm(resul{4} - ((A2+B1)*C1));
        conf(5) = norm(resul{5} - ((A2+B1)*C2 + (A4+B1)*C1));
        conf(6) = norm(resul{6} - ((A4+B1)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A3+B1)*C1));
        conf(3) = norm(resul{3} - ((A3+B1)*C2));
        conf(4) = norm(resul{4} - ((A2+B2)*C1));
        conf(5) = norm(resul{5} - ((A2+B2)*C2 + (A4+B2)*C1));
        conf(6) = norm(resul{6} - ((A4+B2)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{3} - ((A2+B2)*C1));
        conf(3) = norm(resul{5} - ((A3+B3)*C1));
        conf(4) = norm(resul{2} - ((A4+B1)*C1));
        conf(5) = norm(resul{4} - ((A5+B2)*C1));
        conf(6) = norm(resul{6} - ((A6+B3)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A4+B1)*C1));
        conf(3) = norm(resul{3} - ((A4+B1)*C2));
        conf(4) = norm(resul{4} - ((A2+B2)*C1));
        conf(5) = norm(resul{5} - ((A2+B2)*C2 + (A5+B2)*C1));
        conf(6) = norm(resul{6} - ((A5+B2)*C2));
        conf(7) = norm(resul{7} - ((A3+B3)*C1));
        conf(8) = norm(resul{8} - ((A3+B3)*C2 + (A6+B3)*C1));
        conf(9) = norm(resul{9} - ((A6+B3)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - ((A1+B1)*C1));
        conf(2) = norm(resul{2} - ((A1+A3+B2)*C1));
        conf(3) = norm(resul{3} - ((A3+B3)*C1));
        conf(4) = norm(resul{4} - ((A2+B1)*C1));
        conf(5) = norm(resul{5} - ((A2+A4+B2)*C1));
        conf(6) = norm(resul{6} - ((A4+B3)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - ((A1+B1)*C1));
    conf(2) = norm(resul{2} - ((A1+B1)*C2 + (A1+A3+B2)*C1));
    conf(3) = norm(resul{3} - ((A1+A3+B2)*C2 + (A3+B3)*C1));
    conf(4) = norm(resul{4} - ((A3+B3)*C2));
    conf(5) = norm(resul{5} - ((A2+B4)*C1));
    conf(6) = norm(resul{6} - ((A2+B4)*C2 + (A2+A4+B5)*C1));
    conf(7) = norm(resul{7} - ((A2+A4+B5)*C2 + (A4+B6)*C1));
    conf(8) = norm(resul{8} - ((A4+B6)*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%A*B+C
clear Ai Bi Ci operacao;
operacao{1} = 'Ai*Bi+Ci';
operacao{2} = 'Ci+Ai*Bi';
disp('Teste 107');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1 + C1));
    conf(2) = norm(resul{2} - (A1*B2 + A2*B1 + C1 + C2));
    conf(3) = norm(resul{3} - (A2*B2 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{2} - (A2*B1 + A1*B1 + C2));
        conf(3) = norm(resul{3} - (A2*B1 + C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1+C1));
        conf(2) = norm(resul{2} - (A2*B1+C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{3} - (A1*B1 + C2));
        conf(3) = norm(resul{2} - (A2*B1 + C1));
        conf(4) = norm(resul{4} - (A2*B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{3} - (A2*B1 + C1));
        conf(3) = norm(resul{2} - (A3*B1 + C2));
        conf(4) = norm(resul{4} - (A4*B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{2} - (A3*B1 + C2));
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (A3*B2 + A4*B1 + 2*C2));
        conf(5) = norm(resul{5} - (A2*B2 + C1));
        conf(6) = norm(resul{6} - (A4*B2 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{2} - (A4*B1 + C1));
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (A4*B2 + A5*B1 + 2*C1));
        conf(5) = norm(resul{5} - (A1*B3 + A3*B1 + 2*C1));
        conf(6) = norm(resul{6} - (A4*B3 + A6*B1 + 2*C1));
        conf(7) = norm(resul{7} - (A2*B2 + C1));
        conf(8) = norm(resul{8} - (A5*B2 + C1));
        conf(9) = norm(resul{9} - (A2*B3 + A3*B2 + 2*C1));
        conf(10) = norm(resul{10} - (A5*B3 + A6*B2 + 2*C1));
        conf(11) = norm(resul{11} - (A3*B3 + C1));
        conf(12) = norm(resul{12} - (A6*B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{2} - (A4*B1 + C2));
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (A4*B2 + A5*B1 + 2*C2));
        conf(5) = norm(resul{5} - (A1*B3 + A3*B1 + 2*C1));
        conf(6) = norm(resul{6} - (A4*B3 + A6*B1 + 2*C2));
        conf(7) = norm(resul{7} - (A2*B2 + C1));
        conf(8) = norm(resul{8} - (A5*B2 + C2));
        conf(9) = norm(resul{9} - (A2*B3 + A3*B2 + 2*C1));
        conf(10) = norm(resul{10} - (A5*B3 + A6*B2 + 2*C2));
        conf(11) = norm(resul{11} - (A3*B3 + C1));
        conf(12) = norm(resul{12} - (A6*B3 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1 + C1));
        conf(2) = norm(resul{2} - (A3*B1 + A1*B2 + 3*C1));
        conf(3) = norm(resul{3} - (A1*B3 + A3*B2 + 3*C1));
        conf(4) = norm(resul{4} - (A3*B3 + C1));
        conf(5) = norm(resul{5} - (A2*B1 + C1));
        conf(6) = norm(resul{6} - (A4*B1 + A2*B2 + 3*C1));
        conf(7) = norm(resul{7} - (A4*B2 + A2*B3 + 3*C1));
        conf(8) = norm(resul{8} - (A4*B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1 + C1));
    conf(2) = norm(resul{2} - (A1*B2 + A3*B1 + 2*C1 + C2));
    conf(3) = norm(resul{3} - (A1*B3 + A3*B2 + C1 + 2*C2));
    conf(4) = norm(resul{4} - (A3*B3 + C2));
    conf(5) = norm(resul{5} - (A1*B4 + A2*B1 + 2*C1));
    conf(6) = norm(resul{6} - (A1*B5 + A2*B2 + A3*B4 + A4*B1 + 4*C1 + 2*C2));
    conf(7) = norm(resul{7} - (A1*B6 + A2*B3 + A3*B5 + A4*B2 + 2*C1 + 4*C2));
    conf(8) = norm(resul{8} - (A3*B6 + A4*B3 + 2*C2));
    conf(9) = norm(resul{9} - (A2*B4 + C1));
    conf(10) = norm(resul{10} - (A2*B5 + A4*B4 + 2*C1 + C2));
    conf(11) = norm(resul{11} - (A2*B6 + A4*B5 + C1 + 2*C2));
    conf(12) = norm(resul{12} - (A4*B6 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-A+B
clear Ai Bi Ci operacao;
operacao{1} = '-Ai+Bi';
operacao{2} = 'Bi-Ai';
disp('Teste 108');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1 + B1));
    conf(2) = norm(resul{2} - (-A2 + B2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 + B1));
        conf(2) = norm(resul{2} - (-A2 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 + B1));
        conf(2) = norm(resul{3} - (-A2 + B1));
        conf(3) = norm(resul{2} - (-A3 + B1));
        conf(4) = norm(resul{4} - (-A4 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 + B1));
        conf(2) = norm(resul{3} - (-A2 + B2));
        conf(3) = norm(resul{2} - (-A3 + B1));
        conf(4) = norm(resul{4} - (-A4 + B2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 + B1));
        conf(2) = norm(resul{3} - (-A2 + B2));
        conf(3) = norm(resul{5} - (-A3 + B3));
        conf(4) = norm(resul{2} - (-A4 + B1));
        conf(5) = norm(resul{4} - (-A5 + B2));
        conf(6) = norm(resul{6} - (-A6 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 + B1));
        conf(2) = norm(resul{2} - (-A1 - A3 + B2));
        conf(3) = norm(resul{3} - (-A3 + B3));
        conf(4) = norm(resul{4} - (-A2 + B1));
        conf(5) = norm(resul{5} - (-A2 - A4 + B2));
        conf(6) = norm(resul{6} - (-A4 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1 + B1));
    conf(2) = norm(resul{2} - (-A1 - A3 + B2));
    conf(3) = norm(resul{3} - (-A3 + B3));
    conf(4) = norm(resul{4} - (-A2 + B4));
    conf(5) = norm(resul{5} - (-A2 - A4 + B5));
    conf(6) = norm(resul{6} - (-A4 + B6));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-(A+B)
clear Ai Bi Ci operacao;
operacao{1} = '-(Ai+Bi)';
operacao{2} = '-(Bi+Ai)';
operacao{3} = '-Ai-Bi';
operacao{4} = '-Bi-Ai';
disp('Teste 109');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1 + B1));
    conf(2) = norm(resul{2} + (A2 + B2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1));
        conf(2) = norm(resul{2} + (A2 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1));
        conf(2) = norm(resul{3} + (A2 + B1));
        conf(3) = norm(resul{2} + (A3 + B1));
        conf(4) = norm(resul{4} + (A4 + B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1));
        conf(2) = norm(resul{3} + (A2 + B2));
        conf(3) = norm(resul{2} + (A3 + B1));
        conf(4) = norm(resul{4} + (A4 + B2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1));
        conf(2) = norm(resul{3} + (A2 + B2));
        conf(3) = norm(resul{5} + (A3 + B3));
        conf(4) = norm(resul{2} + (A4 + B1));
        conf(5) = norm(resul{4} + (A5 + B2));
        conf(6) = norm(resul{6} + (A6 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1));
        conf(2) = norm(resul{2} + (A1 + A3 + B2));
        conf(3) = norm(resul{3} + (A3 + B3));
        conf(4) = norm(resul{4} + (A2 + B1));
        conf(5) = norm(resul{5} + (A2 + A4 + B2));
        conf(6) = norm(resul{6} + (A4 + B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1 + B1));
    conf(2) = norm(resul{2} + (A1 + A3 + B2));
    conf(3) = norm(resul{3} + (A3 + B3));
    conf(4) = norm(resul{4} + (A2 + B4));
    conf(5) = norm(resul{5} + (A2 + A4 + B5));
    conf(6) = norm(resul{6} + (A4 + B6));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-(A+B)+C
clear Ai Bi Ci operacao;
operacao{1} = '-(Ai+Bi)+Ci';
operacao{2} = 'Ci-(Ai+Bi)';
operacao{3} = '-Ai-Bi+Ci';
operacao{4} = 'Ci-Ai-Bi';
operacao{5} = '-Bi-Ai+Ci';
operacao{6} = '-Bi+Ci-Ai';
operacao{7} = 'Ci-Ai-Bi';
operacao{8} = 'Ci-Bi-Ai';
disp('Teste 110');
for indop=1:8
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1 - B1 + C1));
    conf(2) = norm(resul{2} - (-A2 - B2 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{2} - (-A1 - A2 - 2*B1 + C2));
        conf(3) = norm(resul{3} - (-A2 - B1 + C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{2} - (-A2 - B1 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{3} - (-A1 - B1 + C2));
        conf(3) = norm(resul{2} - (-A2 - B1 + C1));
        conf(4) = norm(resul{4} - (-A2 - B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{3} - (-A2 - B1 + C1));
        conf(3) = norm(resul{2} - (-A3 - B1 + C2));
        conf(4) = norm(resul{4} - (-A4 - B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{3} - (-A2 - B2 + C1));
        conf(3) = norm(resul{2} - (-A3 - B1 + C2));
        conf(4) = norm(resul{4} - (-A4 - B2 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{3} - (-A2 - B2 + C1));
        conf(3) = norm(resul{5} - (-A3 - B3 + C1));
        conf(4) = norm(resul{2} - (-A4 - B1 + C1));
        conf(5) = norm(resul{4} - (-A5 - B2 + C1));
        conf(6) = norm(resul{6} - (-A6 - B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{3} - (-A2 - B2 + C1));
        conf(3) = norm(resul{5} - (-A3 - B3 + C1));
        conf(4) = norm(resul{2} - (-A4 - B1 + C2));
        conf(5) = norm(resul{4} - (-A5 - B2 + C2));
        conf(6) = norm(resul{6} - (-A6 - B3 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1 - B1 + C1));
        conf(2) = norm(resul{2} - (-A1 - A3 - B2 + 2*C1));
        conf(3) = norm(resul{3} - (-A3 - B3 + C1));
        conf(4) = norm(resul{4} - (-A2 - B1 + C1));
        conf(5) = norm(resul{5} - (-A2 - A4 - B2 + 2*C1));
        conf(6) = norm(resul{6} - (-A4 - B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1 - B1 + C1));
    conf(2) = norm(resul{2} - (-A1 - A3 - B2 + C1 + C2));
    conf(3) = norm(resul{3} - (-A3 - B3 + C2));
    conf(4) = norm(resul{4} - (-A2 - B4 + C1));
    conf(5) = norm(resul{5} - (-A2 - A4 - B5 + C1 + C2));
    conf(6) = norm(resul{6} - (-A4 - B6 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-(A+B)*C
clear Ai Bi Ci operacao;
operacao{1} = '-(Ai+Bi)*Ci';
operacao{2} = '-(Bi+Ai)*Ci';
operacao{3} = '-Ai*Ci-Bi*Ci';
operacao{4} = '-Bi*Ci-Ai*Ci';
disp('Teste 111');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + ((A1+B1)*C1));
    conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A2+B2)*C1));
    conf(3) = norm(resul{3} + ((A2+B2)*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A2+B1)*C1));
        conf(3) = norm(resul{3} + ((A1+B1)*C3 + (A2+B1)*C2));
        conf(4) = norm(resul{4} + ((A2+B1)*C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A2+B1)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{3} + ((A1+B1)*C2));
        conf(3) = norm(resul{2} + ((A2+B1)*C1));
        conf(4) = norm(resul{4} + ((A2+B1)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A3+B1)*C1));
        conf(3) = norm(resul{3} + ((A3+B1)*C2));
        conf(4) = norm(resul{4} + ((A2+B1)*C1));
        conf(5) = norm(resul{5} + ((A2+B1)*C2 + (A4+B1)*C1));
        conf(6) = norm(resul{6} + ((A4+B1)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A3+B1)*C1));
        conf(3) = norm(resul{3} + ((A3+B1)*C2));
        conf(4) = norm(resul{4} + ((A2+B2)*C1));
        conf(5) = norm(resul{5} + ((A2+B2)*C2 + (A4+B2)*C1));
        conf(6) = norm(resul{6} + ((A4+B2)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{3} + ((A2+B2)*C1));
        conf(3) = norm(resul{5} + ((A3+B3)*C1));
        conf(4) = norm(resul{2} + ((A4+B1)*C1));
        conf(5) = norm(resul{4} + ((A5+B2)*C1));
        conf(6) = norm(resul{6} + ((A6+B3)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A4+B1)*C1));
        conf(3) = norm(resul{3} + ((A4+B1)*C2));
        conf(4) = norm(resul{4} + ((A2+B2)*C1));
        conf(5) = norm(resul{5} + ((A2+B2)*C2 + (A5+B2)*C1));
        conf(6) = norm(resul{6} + ((A5+B2)*C2));
        conf(7) = norm(resul{7} + ((A3+B3)*C1));
        conf(8) = norm(resul{8} + ((A3+B3)*C2 + (A6+B3)*C1));
        conf(9) = norm(resul{9} + ((A6+B3)*C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + ((A1+B1)*C1));
        conf(2) = norm(resul{2} + ((A1+A3+B2)*C1));
        conf(3) = norm(resul{3} + ((A3+B3)*C1));
        conf(4) = norm(resul{4} + ((A2+B1)*C1));
        conf(5) = norm(resul{5} + ((A2+A4+B2)*C1));
        conf(6) = norm(resul{6} + ((A4+B3)*C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + ((A1+B1)*C1));
    conf(2) = norm(resul{2} + ((A1+B1)*C2 + (A1+A3+B2)*C1));
    conf(3) = norm(resul{3} + ((A1+A3+B2)*C2 + (A3+B3)*C1));
    conf(4) = norm(resul{4} + ((A3+B3)*C2));
    conf(5) = norm(resul{5} + ((A2+B4)*C1));
    conf(6) = norm(resul{6} + ((A2+B4)*C2 + (A2+A4+B5)*C1));
    conf(7) = norm(resul{7} + ((A2+A4+B5)*C2 + (A4+B6)*C1));
    conf(8) = norm(resul{8} + ((A4+B6)*C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-A*B,  -(A*B)
clear Ai Bi Ci operacao;
operacao{1} = '-Ai*Bi';
operacao{2} = '-(Ai*Bi)';
disp('Teste 112');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1*B1));
    conf(2) = norm(resul{2} + (A1*B2 + A2*B1));
    conf(3) = norm(resul{3} + (A2*B2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1));
        conf(2) = norm(resul{2} + (A2*B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1));
        conf(2) = norm(resul{3} + (A2*B1));
        conf(3) = norm(resul{2} + (A3*B1));
        conf(4) = norm(resul{4} + (A4*B1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1));
        conf(2) = norm(resul{2} + (A3*B1));
        conf(3) = norm(resul{3} + (A1*B2 + A2*B1));
        conf(4) = norm(resul{4} + (A3*B2 + A4*B1));
        conf(5) = norm(resul{5} + (A2*B2));
        conf(6) = norm(resul{6} + (A4*B2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1));
        conf(2) = norm(resul{2} + (A4*B1));
        conf(3) = norm(resul{3} + (A1*B2 + A2*B1));
        conf(4) = norm(resul{4} + (A4*B2 + A5*B1));
        conf(5) = norm(resul{5} + (A1*B3 + A3*B1));
        conf(6) = norm(resul{6} + (A4*B3 + A6*B1));
        conf(7) = norm(resul{7} + (A2*B2));
        conf(8) = norm(resul{8} + (A5*B2));
        conf(9) = norm(resul{9} + (A2*B3 + A3*B2));
        conf(10) = norm(resul{10} + (A5*B3 + A6*B2));
        conf(11) = norm(resul{11} + (A3*B3));
        conf(12) = norm(resul{12} + (A6*B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1));
        conf(2) = norm(resul{2} + (A3*B1 + A1*B2));
        conf(3) = norm(resul{3} + (A1*B3 + A3*B2));
        conf(4) = norm(resul{4} + (A3*B3));
        conf(5) = norm(resul{5} + (A2*B1));
        conf(6) = norm(resul{6} + (A4*B1 + A2*B2));
        conf(7) = norm(resul{7} + (A4*B2 + A2*B3));
        conf(8) = norm(resul{8} + (A4*B3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1*B1));
    conf(2) = norm(resul{2} + (A1*B2 + A3*B1));
    conf(3) = norm(resul{3} + (A1*B3 + A3*B2));
    conf(4) = norm(resul{4} + (A3*B3));
    conf(5) = norm(resul{5} + (A1*B4 + A2*B1));
    conf(6) = norm(resul{6} + (A1*B5 + A2*B2 + A3*B4 + A4*B1));
    conf(7) = norm(resul{7} + (A1*B6 + A2*B3 + A3*B5 + A4*B2));
    conf(8) = norm(resul{8} + (A3*B6 + A4*B3));
    conf(9) = norm(resul{9} + (A2*B4));
    conf(10) = norm(resul{10} + (A2*B5 + A4*B4));
    conf(11) = norm(resul{11} + (A2*B6 + A4*B5));
    conf(12) = norm(resul{12} + (A4*B6));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%-A*B+C
clear Ai Bi Ci operacao;
operacao{1} = '-Ai*Bi+Ci';
operacao{2} = 'Ci-Ai*Bi';
disp('Teste 113');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1*B1 + C1));
    conf(2) = norm(resul{2} - (-A1*B2 - A2*B1 + C1 + C2));
    conf(3) = norm(resul{3} - (-A2*B2 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{2} - (-A2*B1 - A1*B1 + C2));
        conf(3) = norm(resul{3} - (-A2*B1 + C3));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1+C1));
        conf(2) = norm(resul{2} - (-A2*B1+C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{3} - (-A1*B1 + C2));
        conf(3) = norm(resul{2} - (-A2*B1 + C1));
        conf(4) = norm(resul{4} - (-A2*B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{3} - (-A2*B1 + C1));
        conf(3) = norm(resul{2} - (-A3*B1 + C2));
        conf(4) = norm(resul{4} - (-A4*B1 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{2} - (-A3*B1 + C2));
        conf(3) = norm(resul{3} - (-A1*B2 - A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (-A3*B2 - A4*B1 + 2*C2));
        conf(5) = norm(resul{5} - (-A2*B2 + C1));
        conf(6) = norm(resul{6} - (-A4*B2 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{2} - (-A4*B1 + C1));
        conf(3) = norm(resul{3} - (-A1*B2 - A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (-A4*B2 - A5*B1 + 2*C1));
        conf(5) = norm(resul{5} - (-A1*B3 - A3*B1 + 2*C1));
        conf(6) = norm(resul{6} - (-A4*B3 - A6*B1 + 2*C1));
        conf(7) = norm(resul{7} - (-A2*B2 + C1));
        conf(8) = norm(resul{8} - (-A5*B2 + C1));
        conf(9) = norm(resul{9} - (-A2*B3 - A3*B2 + 2*C1));
        conf(10) = norm(resul{10} - (-A5*B3 - A6*B2 + 2*C1));
        conf(11) = norm(resul{11} - (-A3*B3 + C1));
        conf(12) = norm(resul{12} - (-A6*B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{2} - (-A4*B1 + C2));
        conf(3) = norm(resul{3} - (-A1*B2 - A2*B1 + 2*C1));
        conf(4) = norm(resul{4} - (-A4*B2 - A5*B1 + 2*C2));
        conf(5) = norm(resul{5} - (-A1*B3 - A3*B1 + 2*C1));
        conf(6) = norm(resul{6} - (-A4*B3 - A6*B1 + 2*C2));
        conf(7) = norm(resul{7} - (-A2*B2 + C1));
        conf(8) = norm(resul{8} - (-A5*B2 + C2));
        conf(9) = norm(resul{9} - (-A2*B3 - A3*B2 + 2*C1));
        conf(10) = norm(resul{10} - (-A5*B3 - A6*B2 + 2*C2));
        conf(11) = norm(resul{11} - (-A3*B3 + C1));
        conf(12) = norm(resul{12} - (-A6*B3 + C2));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (-A1*B1 + C1));
        conf(2) = norm(resul{2} - (-A3*B1 - A1*B2 + 3*C1));
        conf(3) = norm(resul{3} - (-A1*B3 - A3*B2 + 3*C1));
        conf(4) = norm(resul{4} - (-A3*B3 + C1));
        conf(5) = norm(resul{5} - (-A2*B1 + C1));
        conf(6) = norm(resul{6} - (-A4*B1 - A2*B2 + 3*C1));
        conf(7) = norm(resul{7} - (-A4*B2 - A2*B3 + 3*C1));
        conf(8) = norm(resul{8} - (-A4*B3 + C1));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (-A1*B1 + C1));
    conf(2) = norm(resul{2} - (-A1*B2 - A3*B1 + 2*C1 + C2));
    conf(3) = norm(resul{3} - (-A1*B3 - A3*B2 + C1 + 2*C2));
    conf(4) = norm(resul{4} - (-A3*B3 + C2));
    conf(5) = norm(resul{5} - (-A1*B4 - A2*B1 + 2*C1));
    conf(6) = norm(resul{6} - (-A1*B5 - A2*B2 - A3*B4 - A4*B1 + 4*C1 + 2*C2));
    conf(7) = norm(resul{7} - (-A1*B6 - A2*B3 - A3*B5 - A4*B2 + 2*C1 + 4*C2));
    conf(8) = norm(resul{8} - (-A3*B6 - A4*B3 + 2*C2));
    conf(9) = norm(resul{9} - (-A2*B4 + C1));
    conf(10) = norm(resul{10} - (-A2*B5 - A4*B4 + 2*C1 + C2));
    conf(11) = norm(resul{11} - (-A2*B6 - A4*B5 + C1 + 2*C2));
    conf(12) = norm(resul{12} - (-A4*B6 + C2));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%(A+B)'
clear Ai Bi Ci operacao;
operacao{1} = '(Ai+Bi)''';
operacao{2} = 'Bi''+Ai''';
operacao{3} = 'Ai''+Bi''';
disp('Teste 114');
for indop=1:3
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1' + B1'));
    conf(2) = norm(resul{2} - (A2' + B2'));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1' + B1'));
        conf(2) = norm(resul{2} - (A2' + B1'));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1' + B1'));
        conf(2) = norm(resul{3} - (A2' + B1'));
        conf(3) = norm(resul{2} - (A3' + B1'));
        conf(4) = norm(resul{4} - (A4' + B1'));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1' + B1'));
        conf(2) = norm(resul{3} - (A2' + B2'));
        conf(3) = norm(resul{2} - (A3' + B1'));
        conf(4) = norm(resul{4} - (A4' + B2'));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1' + B1'));
        conf(2) = norm(resul{3} - (A2' + B2'));
        conf(3) = norm(resul{5} - (A3' + B3'));
        conf(4) = norm(resul{2} - (A4' + B1'));
        conf(5) = norm(resul{4} - (A5' + B2'));
        conf(6) = norm(resul{6} - (A6' + B3'));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1' + B1'));
        conf(2) = norm(resul{2} - (A1' + A3' + B2'));
        conf(3) = norm(resul{3} - (A3' + B3'));
        conf(4) = norm(resul{4} - (A2' + B1'));
        conf(5) = norm(resul{5} - (A2' + A4' + B2'));
        conf(6) = norm(resul{6} - (A4' + B3'));
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1' + B1'));
    conf(2) = norm(resul{2} - (A1' + A3' + B2'));
    conf(3) = norm(resul{3} - (A3' + B3'));
    conf(4) = norm(resul{4} - (A2' + B4'));
    conf(5) = norm(resul{5} - (A2' + A4' + B5'));
    conf(6) = norm(resul{6} - (A4' + B6'));
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%(A*B)'
clear Ai Bi Ci operacao;
operacao{1} = '(Ai*Bi)''';
operacao{2} = 'Bi''*Ai''';
disp('Teste 115');
for indop=1:2
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1)');
    conf(2) = norm(resul{2} - (A1*B2 + A2*B1)');
    conf(3) = norm(resul{3} - (A2*B2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1)');
        conf(2) = norm(resul{2} - (A2*B1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1)');
        conf(2) = norm(resul{3} - (A2*B1)');
        conf(3) = norm(resul{2} - (A3*B1)');
        conf(4) = norm(resul{4} - (A4*B1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1)');
        conf(2) = norm(resul{2} - (A3*B1)');
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1)');
        conf(4) = norm(resul{4} - (A3*B2 + A4*B1)');
        conf(5) = norm(resul{5} - (A2*B2)');
        conf(6) = norm(resul{6} - (A4*B2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1)');
        conf(2) = norm(resul{2} - (A4*B1)');
        conf(3) = norm(resul{3} - (A1*B2 + A2*B1)');
        conf(4) = norm(resul{4} - (A4*B2 + A5*B1)');
        conf(5) = norm(resul{5} - (A1*B3 + A3*B1)');
        conf(6) = norm(resul{6} - (A4*B3 + A6*B1)');
        conf(7) = norm(resul{7} - (A2*B2)');
        conf(8) = norm(resul{8} - (A5*B2)');
        conf(9) = norm(resul{9} - (A2*B3 + A3*B2)');
        conf(10) = norm(resul{10} - (A5*B3 + A6*B2)');
        conf(11) = norm(resul{11} - (A3*B3)');
        conf(12) = norm(resul{12} - (A6*B3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1)');
        conf(2) = norm(resul{2} - (A3*B1 + A1*B2)');
        conf(3) = norm(resul{3} - (A1*B3 + A3*B2)');
        conf(4) = norm(resul{4} - (A3*B3)');
        conf(5) = norm(resul{5} - (A2*B1)');
        conf(6) = norm(resul{6} - (A4*B1 + A2*B2)');
        conf(7) = norm(resul{7} - (A4*B2 + A2*B3)');
        conf(8) = norm(resul{8} - (A4*B3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1)');
    conf(2) = norm(resul{2} - (A1*B2 + A3*B1)');
    conf(3) = norm(resul{3} - (A1*B3 + A3*B2)');
    conf(4) = norm(resul{4} - (A3*B3)');
    conf(5) = norm(resul{5} - (A1*B4 + A2*B1)');
    conf(6) = norm(resul{6} - (A1*B5 + A2*B2 + A3*B4 + A4*B1)');
    conf(7) = norm(resul{7} - (A1*B6 + A2*B3 + A3*B5 + A4*B2)');
    conf(8) = norm(resul{8} - (A3*B6 + A4*B3)');
    conf(9) = norm(resul{9} - (A2*B4)');
    conf(10) = norm(resul{10} - (A2*B5 + A4*B4)');
    conf(11) = norm(resul{11} - (A2*B6 + A4*B5)');
    conf(12) = norm(resul{12} - (A4*B6)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%(A*B*C)'   116
clear Ai Bi Ci operacao;
operacao{1} = '(Ai*Bi*Ci)''';
operacao{2} = 'Ci''*(Ai*Bi)''';
operacao{3} = '(Bi*Ci)''*Ai''';
operacao{4} = 'Ci''*Bi''*Ai''';
disp('Teste 116');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1*C1)');
    conf(2) = norm(resul{2} - (A1*B1*C2 + A1*B2*C1 + A2*B1*C1)');
    conf(3) = norm(resul{3} - (A1*B2*C2 + A2*B1*C2 + A2*B2*C1)');
    conf(4) = norm(resul{4} - (A2*B2*C2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A1*B1*C2 + A2*B1*C1)');
        conf(3) = norm(resul{3} - (A1*B1*C3 + A2*B1*C2)');
        conf(4) = norm(resul{4} - (A2*B1*C3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A2*B1*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{3} - (A1*B1*C2)');
        conf(3) = norm(resul{2} - (A2*B1*C1)');
        conf(4) = norm(resul{4} - (A2*B1*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A1*B1*C2 + A3*B1*C1)');
        conf(3) = norm(resul{3} - (A3*B1*C2)');
        conf(4) = norm(resul{4} - (A2*B1*C1)');
        conf(5) = norm(resul{5} - (A2*B1*C2 + A4*B1*C1)');
        conf(6) = norm(resul{6} - (A4*B1*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A1*B1*C2 + A3*B1*C1)');
        conf(3) = norm(resul{3} - (A3*B1*C2)');
        conf(4) = norm(resul{4} - (A2*B1*C1 + A1*B2*C1)');
        conf(5) = norm(resul{5} - (A2*B1*C2 + A4*B1*C1 + A1*B2*C2 + A3*B2*C1)');
        conf(6) = norm(resul{6} - (A4*B1*C2 + A3*B2*C2)');
        conf(7) = norm(resul{7} - (A2*B2*C1)');
        conf(8) = norm(resul{8} - (A2*B2*C2 + A4*B2*C1)');
        conf(9) = norm(resul{9} - (A4*B2*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A4*B1*C1)');
        conf(3) = norm(resul{3} - (A1*B2*C1 + A2*B1*C1)');
        conf(4) = norm(resul{4} - (A4*B2*C1 + A5*B1*C1)');
        conf(5) = norm(resul{5} - (A1*B3*C1 + A3*B1*C1)');
        conf(6) = norm(resul{6} - (A4*B3*C1 + A6*B1*C1)');
        conf(7) = norm(resul{7} - (A2*B2*C1)');
        conf(8) = norm(resul{8} - (A5*B2*C1)');
        conf(9) = norm(resul{9} - (A2*B3*C1 + A3*B2*C1)');
        conf(10) = norm(resul{10} - (A5*B3*C1 + A6*B2*C1)');
        conf(11) = norm(resul{11} - (A3*B3*C1)');
        conf(12) = norm(resul{12} - (A6*B3*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A1*B1*C2 + A4*B1*C1)');
        conf(3) = norm(resul{3} - (A4*B1*C2)');
        conf(4) = norm(resul{4} - (A1*B2*C1 + A2*B1*C1)');
        conf(5) = norm(resul{5} - (A1*B2*C2 + A2*B1*C2 + A4*B2*C1 + A5*B1*C1)');
        conf(6) = norm(resul{6} - (A4*B2*C2 + A5*B1*C2)');
        conf(7) = norm(resul{7} - (A1*B3*C1 + A3*B1*C1)');
        conf(8) = norm(resul{8} - (A1*B3*C2 + A3*B1*C2 + A4*B3*C1 + A6*B1*C1)');
        conf(9) = norm(resul{9} - (A4*B3*C2 + A6*B1*C2)');
        conf(10) = norm(resul{10} - (A2*B2*C1)');
        conf(11) = norm(resul{11} - (A2*B2*C2 +  A5*B2*C1)');
        conf(12) = norm(resul{12} - (A5*B2*C2)');
        conf(13) = norm(resul{13} - (A2*B3*C1 + A3*B2*C1)');
        conf(14) = norm(resul{14} - (A2*B3*C2 + A3*B2*C2 + A5*B3*C1 + A6*B2*C1)');
        conf(15) = norm(resul{15} - (A5*B3*C2 + A6*B2*C2)');
        conf(16) = norm(resul{16} - (A3*B3*C1)');
        conf(17) = norm(resul{17} - (A3*B3*C2 + A6*B3*C1)');
        conf(18) = norm(resul{18} - (A6*B3*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} - (A1*B1*C1)');
        conf(2) = norm(resul{2} - (A1*B2*C1 + A3*B1*C1)');
        conf(3) = norm(resul{3} - (A1*B3*C1 + A3*B2*C1)');
        conf(4) = norm(resul{4} - (A3*B3*C1)');
        conf(5) = norm(resul{5} - (A2*B1*C1)');
        conf(6) = norm(resul{6} - (A2*B2*C1 + A4*B1*C1)');
        conf(7) = norm(resul{7} - (A2*B3*C1 + A4*B2*C1)');
        conf(8) = norm(resul{8} - (A4*B3*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} - (A1*B1*C1)');
    conf(2) = norm(resul{2} - (A1*B1*C2 + A1*B2*C1 + A3*B1*C1)');
    conf(3) = norm(resul{3} - (A1*B2*C2 + A1*B3*C1 + A3*B1*C2 + A3*B2*C1)');
    conf(4) = norm(resul{4} - (A1*B3*C2 + A3*B2*C2 + A3*B3*C1)');
    conf(5) = norm(resul{5} - (A3*B3*C2)');
    conf(6) = norm(resul{6} - (A1*B4*C1 + A2*B1*C1)');
    conf(7) = norm(resul{7} - (A1*B4*C2 + A1*B5*C1 + A2*B1*C2 + A2*B2*C1 + A3*B4*C1 + A4*B1*C1)');
    conf(8) = norm(resul{8} - (A1*B5*C2 + A1*B6*C1 + A2*B2*C2 + A2*B3*C1 + A3*B4*C2 + A3*B5*C1 + A4*B1*C2 + A4*B2*C1)');
    conf(9) = norm(resul{9} - (A1*B6*C2 + A2*B3*C2 + A3*B5*C2 + A3*B6*C1 + A4*B2*C2 + A4*B3*C1)');
    conf(10) = norm(resul{10} - (A3*B6*C2 + A4*B3*C2)');
    conf(11) = norm(resul{11} - (A2*B4*C1)');
    conf(12) = norm(resul{12} - (A2*B4*C2 + A2*B5*C1 + A4*B4*C1)');
    conf(13) = norm(resul{13} - (A2*B5*C2 + A2*B6*C1 + A4*B4*C2 + A4*B5*C1)');
    conf(14) = norm(resul{14} - (A2*B6*C2 + A4*B5*C2 + A4*B6*C1)');
    conf(15) = norm(resul{15} - (A4*B6*C2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end




%-(A+B)'    
clear Ai Bi Ci operacao;
operacao{1} = '-(Ai+Bi)''';
operacao{2} = '-(Bi+Ai)''';
operacao{3} = '-Ai''-Bi''';
operacao{4} = '-Bi''-Ai''';
disp('Teste 117');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1 + B1)');
    conf(2) = norm(resul{2} + (A2 + B2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1)');
        conf(2) = norm(resul{2} + (A2 + B1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1)');
        conf(2) = norm(resul{3} + (A2 + B1)');
        conf(3) = norm(resul{2} + (A3 + B1)');
        conf(4) = norm(resul{4} + (A4 + B1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1)');
        conf(2) = norm(resul{3} + (A2 + B2)');
        conf(3) = norm(resul{2} + (A3 + B1)');
        conf(4) = norm(resul{4} + (A4 + B2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1)');
        conf(2) = norm(resul{3} + (A2 + B2)');
        conf(3) = norm(resul{5} + (A3 + B3)');
        conf(4) = norm(resul{2} + (A4 + B1)');
        conf(5) = norm(resul{4} + (A5 + B2)');
        conf(6) = norm(resul{6} + (A6 + B3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1 + B1)');
        conf(2) = norm(resul{2} + (A1 + A3 + B2)');
        conf(3) = norm(resul{3} + (A3 + B3)');
        conf(4) = norm(resul{4} + (A2 + B1)');
        conf(5) = norm(resul{5} + (A2 + A4 + B2)');
        conf(6) = norm(resul{6} + (A4 + B3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1 + B1)');
    conf(2) = norm(resul{2} + (A1 + A3 + B2)');
    conf(3) = norm(resul{3} + (A3 + B3)');
    conf(4) = norm(resul{4} + (A2 + B4)');
    conf(5) = norm(resul{5} + (A2 + A4 + B5)');
    conf(6) = norm(resul{6} + (A4 + B6)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end





%-(A*B*C)'   
clear Ai Bi Ci operacao;
operacao{1} = '-(Ai*Bi*Ci)''';
operacao{2} = '-Ci''*(Ai*Bi)''';
operacao{3} = '-(Bi*Ci)''*Ai''';
operacao{4} = '-Ci''*Bi''*Ai''';
disp('Teste 118');
for indop=1:4
    indop
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(1);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1*B1*C1)');
    conf(2) = norm(resul{2} + (A1*B1*C2 + A1*B2*C1 + A2*B1*C1)');
    conf(3) = norm(resul{3} + (A1*B2*C2 + A2*B1*C2 + A2*B2*C1)');
    conf(4) = norm(resul{4} + (A2*B2*C2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
    
    for cont=2:7
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A1*B1*C2 + A2*B1*C1)');
        conf(3) = norm(resul{3} + (A1*B1*C3 + A2*B1*C2)');
        conf(4) = norm(resul{4} + (A2*B1*C3)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=8:10
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A2*B1*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=11:21
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{3} + (A1*B1*C2)');
        conf(3) = norm(resul{2} + (A2*B1*C1)');
        conf(4) = norm(resul{4} + (A2*B1*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=22:33
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A1*B1*C2 + A3*B1*C1)');
        conf(3) = norm(resul{3} + (A3*B1*C2)');
        conf(4) = norm(resul{4} + (A2*B1*C1)');
        conf(5) = norm(resul{5} + (A2*B1*C2 + A4*B1*C1)');
        conf(6) = norm(resul{6} + (A4*B1*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    for cont=34:39
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A1*B1*C2 + A3*B1*C1)');
        conf(3) = norm(resul{3} + (A3*B1*C2)');
        conf(4) = norm(resul{4} + (A2*B1*C1 + A1*B2*C1)');
        conf(5) = norm(resul{5} + (A2*B1*C2 + A4*B1*C1 + A1*B2*C2 + A3*B2*C1)');
        conf(6) = norm(resul{6} + (A4*B1*C2 + A3*B2*C2)');
        conf(7) = norm(resul{7} + (A2*B2*C1)');
        conf(8) = norm(resul{8} + (A2*B2*C2 + A4*B2*C1)');
        conf(9) = norm(resul{9} + (A4*B2*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=40:45
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A4*B1*C1)');
        conf(3) = norm(resul{3} + (A1*B2*C1 + A2*B1*C1)');
        conf(4) = norm(resul{4} + (A4*B2*C1 + A5*B1*C1)');
        conf(5) = norm(resul{5} + (A1*B3*C1 + A3*B1*C1)');
        conf(6) = norm(resul{6} + (A4*B3*C1 + A6*B1*C1)');
        conf(7) = norm(resul{7} + (A2*B2*C1)');
        conf(8) = norm(resul{8} + (A5*B2*C1)');
        conf(9) = norm(resul{9} + (A2*B3*C1 + A3*B2*C1)');
        conf(10) = norm(resul{10} + (A5*B3*C1 + A6*B2*C1)');
        conf(11) = norm(resul{11} + (A3*B3*C1)');
        conf(12) = norm(resul{12} + (A6*B3*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=46:55
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A1*B1*C2 + A4*B1*C1)');
        conf(3) = norm(resul{3} + (A4*B1*C2)');
        conf(4) = norm(resul{4} + (A1*B2*C1 + A2*B1*C1)');
        conf(5) = norm(resul{5} + (A1*B2*C2 + A2*B1*C2 + A4*B2*C1 + A5*B1*C1)');
        conf(6) = norm(resul{6} + (A4*B2*C2 + A5*B1*C2)');
        conf(7) = norm(resul{7} + (A1*B3*C1 + A3*B1*C1)');
        conf(8) = norm(resul{8} + (A1*B3*C2 + A3*B1*C2 + A4*B3*C1 + A6*B1*C1)');
        conf(9) = norm(resul{9} + (A4*B3*C2 + A6*B1*C2)');
        conf(10) = norm(resul{10} + (A2*B2*C1)');
        conf(11) = norm(resul{11} + (A2*B2*C2 +  A5*B2*C1)');
        conf(12) = norm(resul{12} + (A5*B2*C2)');
        conf(13) = norm(resul{13} + (A2*B3*C1 + A3*B2*C1)');
        conf(14) = norm(resul{14} + (A2*B3*C2 + A3*B2*C2 + A5*B3*C1 + A6*B2*C1)');
        conf(15) = norm(resul{15} + (A5*B3*C2 + A6*B2*C2)');
        conf(16) = norm(resul{16} + (A3*B3*C1)');
        conf(17) = norm(resul{17} + (A3*B3*C2 + A6*B3*C1)');
        conf(18) = norm(resul{18} + (A6*B3*C2)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    
    for cont=56:58
        clear Ai Bi Ci conf resul;
        [Ai, Bi, Ci] = define(cont);
        resul = vertices(eval(operacao{indop}));
        conf(1) = norm(resul{1} + (A1*B1*C1)');
        conf(2) = norm(resul{2} + (A1*B2*C1 + A3*B1*C1)');
        conf(3) = norm(resul{3} + (A1*B3*C1 + A3*B2*C1)');
        conf(4) = norm(resul{4} + (A3*B3*C1)');
        conf(5) = norm(resul{5} + (A2*B1*C1)');
        conf(6) = norm(resul{6} + (A2*B2*C1 + A4*B1*C1)');
        conf(7) = norm(resul{7} + (A2*B3*C1 + A4*B2*C1)');
        conf(8) = norm(resul{8} + (A4*B3*C1)');
        if (sum(conf) ~= 0)
            error('Nao passou');
        end
    end
    
    clear Ai Bi Ci conf resul;
    [Ai, Bi, Ci] = define(59);
    resul = vertices(eval(operacao{indop}));
    conf(1) = norm(resul{1} + (A1*B1*C1)');
    conf(2) = norm(resul{2} + (A1*B1*C2 + A1*B2*C1 + A3*B1*C1)');
    conf(3) = norm(resul{3} + (A1*B2*C2 + A1*B3*C1 + A3*B1*C2 + A3*B2*C1)');
    conf(4) = norm(resul{4} + (A1*B3*C2 + A3*B2*C2 + A3*B3*C1)');
    conf(5) = norm(resul{5} + (A3*B3*C2)');
    conf(6) = norm(resul{6} + (A1*B4*C1 + A2*B1*C1)');
    conf(7) = norm(resul{7} + (A1*B4*C2 + A1*B5*C1 + A2*B1*C2 + A2*B2*C1 + A3*B4*C1 + A4*B1*C1)');
    conf(8) = norm(resul{8} + (A1*B5*C2 + A1*B6*C1 + A2*B2*C2 + A2*B3*C1 + A3*B4*C2 + A3*B5*C1 + A4*B1*C2 + A4*B2*C1)');
    conf(9) = norm(resul{9} + (A1*B6*C2 + A2*B3*C2 + A3*B5*C2 + A3*B6*C1 + A4*B2*C2 + A4*B3*C1)');
    conf(10) = norm(resul{10} + (A3*B6*C2 + A4*B3*C2)');
    conf(11) = norm(resul{11} + (A2*B4*C1)');
    conf(12) = norm(resul{12} + (A2*B4*C2 + A2*B5*C1 + A4*B4*C1)');
    conf(13) = norm(resul{13} + (A2*B5*C2 + A2*B6*C1 + A4*B4*C2 + A4*B5*C1)');
    conf(14) = norm(resul{14} + (A2*B6*C2 + A4*B5*C2 + A4*B6*C1)');
    conf(15) = norm(resul{15} + (A4*B6*C2)');
    if (sum(conf) ~= 0)
        error('Nao passou');
    end
end



%Testes com poly_derive
disp('Teste 119');
clear Ai Bi Ci conf resul A
A{1} = A1;
A{2} = A2;
Ai = rolmipvar(A,'A',2,1);
dotAi = diff(Ai,'dotA',[-1 2; -1 3]);
resul = vertices(Ai + dotAi);
conf(1) = norm(resul{1} - (2*A1 - A2));
conf(2) = norm(resul{2} - (A1));
conf(3) = norm(resul{3} - (A2));
conf(4) = norm(resul{4} - (2*A2 - A1));
if (sum(conf) ~= 0)
    error('Nao passou');
end



disp('Teste 120');
clear Ai Bi Ci conf resul A H
A{1} = {[2 0],A1};
A{2} = {[1 1],A2};
A{3} = {[0 2],A3};
Ai = rolmipvar(A,'A',2,2);
dotAi = diff(Ai,'dotA',[-3 2; -5 4]);
if (exist('Polyhedron'))
    H = [2 -3; -2 3];
else
    H = [-3 2; 3 -2];
end
resul = vertices(Ai + dotAi);
conf(1) = norm(resul{1} - (A1 + 2*H(1,1)*A1 + H(2,1)*A2));
conf(2) = norm(resul{2} - (A2 + 2*H(1,1)*A1 + H(1,1)*A2 + H(2,1)*A2 + 2*H(2,1)*A3));
conf(3) = norm(resul{3} - (A3 + H(1,1)*A2 + 2*H(2,1)*A3));
conf(4) = norm(resul{4} - (A1 + 2*H(1,2)*A1 + H(2,2)*A2));
conf(5) = norm(resul{5} - (A2 + 2*H(1,2)*A1 + H(1,2)*A2 + H(2,2)*A2 + 2*H(2,2)*A3));
conf(6) = norm(resul{6} - (A3 + H(1,2)*A2 + 2*H(2,2)*A3));
if (sum(conf) ~= 0)
    error('Nao passou');
end



disp('Teste 121');
clear Ai Bi Ci conf resul A dotbounds Ha Hb
A{1} = {[1 0],[1 0],A1};
A{2} = {[1 0],[0 1],A2};
A{3} = {[0 1],[1 0],A3};
A{4} = {[0 1],[0 1],A4};
Ai = rolmipvar(A,'A',[2 2],[1 1]);
dotbounds{1} = [-3 2; -5 4];
dotbounds{2} = [-8 3; -1 6];
dotAi = diff(Ai,'dotA',dotbounds);
resul = vertices(Ai + dotAi);
if (exist('Polyhedron'))
    Ha = [2 -3; -2 3];
    Hb = [-6 1; 6 -1];
else
    Ha = [-3 2; 3 -2];
    Hb = [1 -6; -1 6];
end
conf(1) = norm(resul{1} - (A1 + Ha(1,1)*A1 + Hb(1,1)*A1 + Hb(2,1)*A2 + Ha(2,1)*A3));
conf(2) = norm(resul{2} - (A3 + Ha(1,1)*A1 + Ha(2,1)*A3 + Hb(1,1)*A3 + Hb(2,1)*A4));
conf(3) = norm(resul{3} - (A2 + Hb(1,1)*A1 + Ha(1,1)*A2 + Hb(2,1)*A2 + Ha(2,1)*A4));
conf(4) = norm(resul{4} - (A4 + Ha(1,1)*A2 + Hb(1,1)*A3 + Ha(2,1)*A4 + Hb(2,1)*A4));
conf(5) = norm(resul{5} - (A1 + Ha(1,2)*A1 + Hb(1,1)*A1 + Hb(2,1)*A2 + Ha(2,2)*A3));
conf(6) = norm(resul{6} - (A3 + Ha(1,2)*A1 + Ha(2,2)*A3 + Hb(1,1)*A3 + Hb(2,1)*A4));
conf(7) = norm(resul{7} - (A2 + Hb(1,1)*A1 + Ha(1,2)*A2 + Hb(2,1)*A2 + Ha(2,2)*A4));
conf(8) = norm(resul{8} - (A4 + Ha(1,2)*A2 + Hb(1,1)*A3 + Ha(2,2)*A4 + Hb(2,1)*A4));
conf(9) = norm(resul{9} - (A1 + Ha(1,1)*A1 + Hb(1,2)*A1 + Hb(2,2)*A2 + Ha(2,1)*A3));
conf(10) = norm(resul{10} - (A3 + Ha(1,1)*A1 + Ha(2,1)*A3 + Hb(1,2)*A3 + Hb(2,2)*A4));
conf(11) = norm(resul{11} - (A2 + Hb(1,2)*A1 + Ha(1,1)*A2 + Hb(2,2)*A2 + Ha(2,1)*A4));
conf(12) = norm(resul{12} - (A4 + Ha(1,1)*A2 + Hb(1,2)*A3 + Ha(2,1)*A4 + Hb(2,2)*A4));
conf(13) = norm(resul{13} - (A1 + Ha(1,2)*A1 + Hb(1,2)*A1 + Hb(2,2)*A2 + Ha(2,2)*A3));
conf(14) = norm(resul{14} - (A3 + Ha(1,2)*A1 + Ha(2,2)*A3 + Hb(1,2)*A3 + Hb(2,2)*A4));
conf(15) = norm(resul{15} - (A2 + Hb(1,2)*A1 + Ha(1,2)*A2 + Hb(2,2)*A2 + Ha(2,2)*A4));
conf(16) = norm(resul{16} - (A4 + Ha(1,2)*A2 + Hb(1,2)*A3 + Ha(2,2)*A4 + Hb(2,2)*A4));
if (sum(conf) ~= 0)
    error('Nao passou');
end



disp('Teste 122');
clear Ai Bi Ci conf resul A dotbounds Ha Hb
A{1} = {[1 0],[2 0],A1};
A{2} = {[1 0],[1 1],A2};
A{3} = {[1 0],[0 2],A3};
A{4} = {[0 1],[2 0],B1};
A{5} = {[0 1],[1 1],B2};
A{6} = {[0 1],[0 2],B3};
Ai = rolmipvar(A,'A',[2 2],[1 2]);
dotbounds{1} = [-3 2; -5 4];
dotbounds{2} = [-8 3; -1 6];
dotAi = diff(Ai,'dotA',dotbounds);
resul = vertices(Ai + dotAi);
if (exist('Polyhedron'))
    Ha = [2 -3; -2 3];
    Hb = [-6 1; 6 -1];
else
    Ha = [-3 2; 3 -2];
    Hb = [1 -6; -1 6];
end
conf(1) = norm(resul{1} - (A1 + Ha(1,1)*A1 + 2*Hb(1,1)*A1 + Hb(2,1)*A2 + Ha(2,1)*B1));
conf(2) = norm(resul{2} - (B1 + Ha(1,1)*A1 + Ha(2,1)*B1 + 2*Hb(1,1)*B1 + Hb(2,1)*B2));
conf(3) = norm(resul{3} - (A2 + 2*Hb(1,1)*A1 + Ha(1,1)*A2 + Hb(1,1)*A2 + Hb(2,1)*A2 + 2*Hb(2,1)*A3 + Ha(2,1)*B2));
conf(4) = norm(resul{4} - (B2 + Ha(1,1)*A2 + 2*Hb(1,1)*B1 + Ha(2,1)*B2 + Hb(1,1)*B2 + Hb(2,1)*B2 + 2*Hb(2,1)*B3));
conf(5) = norm(resul{5} - (A3 + Hb(1,1)*A2 + Ha(1,1)*A3 + 2*Hb(2,1)*A3 + Ha(2,1)*B3));
conf(6) = norm(resul{6} - (B3 + Ha(1,1)*A3 + Hb(1,1)*B2 + Ha(2,1)*B3 + 2*Hb(2,1)*B3));
conf(7) = norm(resul{7} - (A1 + Ha(1,2)*A1 + 2*Hb(1,1)*A1 + Hb(2,1)*A2 + Ha(2,2)*B1));
conf(8) = norm(resul{8} - (B1 + Ha(1,2)*A1 + Ha(2,2)*B1 + 2*Hb(1,1)*B1 + Hb(2,1)*B2));
conf(9) = norm(resul{9} - (A2 + 2*Hb(1,1)*A1 + Ha(1,2)*A2 + Hb(1,1)*A2 + Hb(2,1)*A2 + 2*Hb(2,1)*A3 + Ha(2,2)*B2));
conf(10) = norm(resul{10} - (B2 + Ha(1,2)*A2 + 2*Hb(1,1)*B1 + Ha(2,2)*B2 + Hb(1,1)*B2 + Hb(2,1)*B2 + 2*Hb(2,1)*B3));
conf(11) = norm(resul{11} - (A3 + Hb(1,1)*A2 + Ha(1,2)*A3 + 2*Hb(2,1)*A3 + Ha(2,2)*B3));
conf(12) = norm(resul{12} - (B3 + Ha(1,2)*A3 + Hb(1,1)*B2 + Ha(2,2)*B3 + 2*Hb(2,1)*B3));
conf(13) = norm(resul{13} - (A1 + Ha(1,1)*A1 + 2*Hb(1,2)*A1 + Hb(2,2)*A2 + Ha(2,1)*B1));
conf(14) = norm(resul{14} - (B1 + Ha(1,1)*A1 + Ha(2,1)*B1 + 2*Hb(1,2)*B1 + Hb(2,2)*B2));
conf(15) = norm(resul{15} - (A2 + 2*Hb(1,2)*A1 + Ha(1,1)*A2 + Hb(1,2)*A2 + Hb(2,2)*A2 + 2*Hb(2,2)*A3 + Ha(2,1)*B2));
conf(16) = norm(resul{16} - (B2 + Ha(1,1)*A2 + 2*Hb(1,2)*B1 + Ha(2,1)*B2 + Hb(1,2)*B2 + Hb(2,2)*B2 + 2*Hb(2,2)*B3));
conf(17) = norm(resul{17} - (A3 + Hb(1,2)*A2 + Ha(1,1)*A3 + 2*Hb(2,2)*A3 + Ha(2,1)*B3));
conf(18) = norm(resul{18} - (B3 + Ha(1,1)*A3 + Hb(1,2)*B2 + Ha(2,1)*B3 + 2*Hb(2,2)*B3));
conf(19) = norm(resul{19} - (A1 + Ha(1,2)*A1 + 2*Hb(1,2)*A1 + Hb(2,2)*A2 + Ha(2,2)*B1));
conf(20) = norm(resul{20} - (B1 + Ha(1,2)*A1 + Ha(2,2)*B1 + 2*Hb(1,2)*B1 + Hb(2,2)*B2));
conf(21) = norm(resul{21} - (A2 + 2*Hb(1,2)*A1 + Ha(1,2)*A2 + Hb(1,2)*A2 + Hb(2,2)*A2 + 2*Hb(2,2)*A3 + Ha(2,2)*B2));
conf(22) = norm(resul{22} - (B2 + Ha(1,2)*A2 + 2*Hb(1,2)*B1 + Ha(2,2)*B2 + Hb(1,2)*B2 + Hb(2,2)*B2 + 2*Hb(2,2)*B3));
conf(23) = norm(resul{23} - (A3 + Hb(1,2)*A2 + Ha(1,2)*A3 + 2*Hb(2,2)*A3 + Ha(2,2)*B3));
conf(24) = norm(resul{24} - (B3 + Ha(1,2)*A3 + Hb(1,2)*B2 + Ha(2,2)*B3 + 2*Hb(2,2)*B3));
if (sum(conf) ~= 0)
    error('Nao passou');
end

%Montagem de matrizes

disp('Teste 123');
clear Ai Bi Ci conf resul A Term
A1i = rolmipvar(A1,'A1');
A2i = rolmipvar(A2,'A2');
A3i = rolmipvar(A3,'A3');
A4i = rolmipvar(A4,'A4');
resul = vertices([A1i A2i; A3i A4i]);
conf(1) = norm(resul{1} - ([A1 A2; A3 A4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 124');
clear Ai Bi Ci conf resul A B Term
A1i = rolmipvar(A1,'A1');
A{1} = A2;
A{2} = A3;
A2i = rolmipvar(A,  'A2', 2,1);
B{1} = {[2 0],B1};
B{2} = {[1 1],B2};
B{3} = {[0 2],B3};
Bi = rolmipvar(B,'B',2,2);
resul = vertices([A1 A2i; A2i Bi]);
conf(1) = norm(resul{1} - ([A1 A2; A2 B1]));
conf(2) = norm(resul{2} - ([2*A1 A2+A3; A2+A3 B2]));
conf(3) = norm(resul{3} - ([A1 A3; A3 B3]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 125');
clear Ai Bi Ci conf resul A B C Term 
A1i = rolmipvar(A1,'A11');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A1i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 126');
clear Ai Bi Ci conf resul A B C Term 
A11i = rolmipvar(A1,'A11');
A{1} = {[1 0],[0],A1};
A{2} = {[0 1],[0],A2};
A12i = rolmipvar(A,  'A12', [2 0],[1 0]);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 127');
clear Ai Bi Ci conf resul A B C Term 
A11i = rolmipvar(A1,'A11');
A{1} = A1;
A{2} = A2;
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 128');
clear Ai Bi Ci conf resul A B C Term 
A11i = rolmipvar(A1,'A11');
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 129');
clear Ai Bi Ci conf resul A B C Term 
A11i = rolmipvar(A1,'A11');
A{1} = {[1 0],[0],A1};
A{2} = {[0 1],[0],A2};
A12i = rolmipvar(A,  'A12', [2 0],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 130');
clear Ai Bi Ci conf resul A B C Term 
A11i = rolmipvar(A1,'A11');
A{1} = A1;
A{2} = A2;
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 131');
clear Ai Bi Ci conf resul A B C Term 
D{1} = {[0 0],[0],A1};
A11i = rolmipvar(D,  'A11', [2 0],[0 0]);
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 132');
clear Ai Bi Ci conf resul A B C Term 
A{1} = {[0 0],[0],A1};
A11i = rolmipvar(A,  'A11', [2 0],[0 0]);
A{1} = {[1 0],[0],A1};
A{2} = {[0 1],[0],A2};
A12i = rolmipvar(A,  'A12', [2 0],[1 0]);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 133');
clear Ai Bi Ci conf resul A B C Term 
A{1} = {[0 0],[0],A1};
A11i = rolmipvar(A,  'A11', [2 0],[0 0]);
A{1} = A1;
A{2} = A2;
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0],[1 0],B1};
B{2} = {[0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [0 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 134');
clear Ai Bi Ci conf resul A B C Term 
A{1} = {[0 0],[0],A1};
A11i = rolmipvar(A,  'A11', [2 0],[0 0]);
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 135');
clear Ai Bi Ci conf resul A B C Term 
A{1} = {[0 0],[0],A1};
A11i = rolmipvar(A,  'A11', [2 0],[0 0]);
A{1} = {[1 0],[0],A1};
A{2} = {[0 1],[0],A2};
A12i = rolmipvar(A,  'A12', [2 0],[1 0]);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 136');
clear Ai Bi Ci conf resul A B C Term 
A{1} = {[0 0],[0],A1};
A11i = rolmipvar(A,  'A11', [2 0],[0 0]);
A{1} = A1;
A{2} = A2;
A12i = rolmipvar(A,  'A12', 2,1);
B{1} = {[0 0],[1 0],B1};
B{2} = {[0 0],[0 1],B2};
A21i = rolmipvar(B,  'A21', [2 2],[0 1]);
C{1} = {[1 0],[1 0],C1};
C{2} = {[0 1],[1 0],C2};
C{3} = {[1 0],[0 1],C3};
C{4} = {[0 1],[0 1],C4};
A22i = rolmipvar(C,  'A22', [2 2],[1 1]);
resul = vertices([A11i A12i; A21i A22i]);
conf(1) = norm(resul{1} - ([A1 A1; B1 C1]));
conf(2) = norm(resul{2} - ([A1 A2; B1 C2]));
conf(3) = norm(resul{3} - ([A1 A1; B2 C3]));
conf(4) = norm(resul{4} - ([A1 A2; B2 C4]));
if (sum(conf) ~= 0)
    error('Nao passou');
end



disp('Testes de erro:');

try
    disp('Teste de erro 1');
    passou = 0;
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',[2 1],[1 0]);
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end

try
    disp('Teste de erro 2');
    passou = 0;
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',[2 1],[1 0]);
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end

try
    disp('Teste de erro 3');
    passou = 0;
    Ai = rolmipvar([A1 A2],'A',[2 1],[1 0]);
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end

try
    %Numeros diferentes de vertices
    disp('Teste de erro 4');
    passou = 0;
    A{1} = A1;
    A{2} = A2;
    B{1} = B1;
    B{2} = B2;
    B{3} = B3;
    Ai = rolmipvar(A,'A',2,1);
    Bi = rolmipvar(B,'B',3,1);
    A*B;
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end


%Testes para a recuperação de monômios
disp('Teste 137');
clear A Ai B Bi conf;
A{1} = {[1 0],[2 0 0],[3 0],A1};
A{2} = {[0 1],[2 0 0],[3 0],A2};
A{3} = {[1 0],[1 1 0],[3 0],A3};
A{4} = {[1 0],[0 2 0],[3 0],A4};
A{5} = {[0 1],[1 0 1],[3 0],A5};
A{6} = {[0 1],[0 0 2],[3 0],A6};
A{7} = {[1 0],[2 0 0],[0 3],B1};
A{8} = {[0 1],[2 0 0],[0 3],B2};
A{9} = {[1 0],[1 1 0],[0 3],B3};
A{10} = {[1 0],[0 2 0],[0 3],B4};
A{11} = {[0 1],[1 0 1],[0 3],B5};
A{12} = {[1 0],[0 0 2],[0 3],B6};
Ai = rolmipvar(A,'A',[2 3 2],[1 2 3]);

disp('Operacao 1');
resul = Ai([1 0],[1 1 0],[3 0]);
conf(1) = norm(resul{1} - A3);
resul = Ai([0 1],[2 0 0],[3 0]);
conf(2) = norm(resul{1} - A2);
resul = Ai([1 0],[1 0 1],[0 3]);
conf(3) = norm(resul{1});
if (sum(conf) ~= 0)
    error('Nao passou');
end

disp('Operacao 2');
clear conf;
resul = Ai([1 0],:,[3 0]);
conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A3);
conf(3) = norm(resul{3});
conf(4) = norm(resul{4} - A4);
conf(5) = norm(resul{5});
conf(6) = norm(resul{6});
if (sum(conf) ~= 0)
    error('Nao passou');
end

disp('Operacao 3');
clear conf;
resul = Ai(:,[2 0 0],:);
conf(1) = norm(resul{1} - A1);
conf(2) = norm(resul{2} - A2);
conf(3) = norm(resul{3});
conf(4) = norm(resul{4});
conf(5) = norm(resul{5});
conf(6) = norm(resul{6});
conf(7) = norm(resul{7} - B1);
conf(8) = norm(resul{8} - B2);

%%%%%%%%%%%%%%%%%%%%%%%


%Testes para o comando fork
disp('Teste 138');
clear A Ai B Bi conf;
A{1} = {[1 0],[2 0 0],[3 0],A1};
A{2} = {[0 1],[2 0 0],[3 0],A2};
A{3} = {[1 0],[1 1 0],[3 0],A3};
A{4} = {[1 0],[0 2 0],[3 0],A4};
A{5} = {[0 1],[1 0 1],[3 0],A5};
A{6} = {[1 0],[0 0 2],[3 0],A6};
A{7} = {[1 0],[2 0 0],[0 3],B1};
A{8} = {[0 1],[2 0 0],[0 3],B2};
A{9} = {[1 0],[1 1 0],[0 3],B3};
A{10} = {[1 0],[0 2 0],[0 3],B4};
A{11} = {[0 1],[1 0 1],[0 3],B5};
A{12} = {[1 0],[0 0 2],[0 3],B6};
Ai = rolmipvar(A,'A',[2 3 2],[1 2 3]);
Bi = fork(Ai,'B');
resul = Bi([0],[0],[0],[1 0],[2 0 0],[3 0]);
conf(1) = norm(resul{1} - A1);
resul = Bi([0],[0],[0],[0 1],[2 0 0],[3 0]);
conf(2) = norm(resul{1} - A2);
resul = Bi([0],[0],[0],[1 0],[1 1 0],[3 0]);
conf(3) = norm(resul{1} - A3);
resul = Bi([0],[0],[0],[1 0],[0 2 0],[3 0]);
conf(4) = norm(resul{1} - A4);
resul = Bi([0],[0],[0],[0 1],[1 0 1],[3 0]);
conf(5) = norm(resul{1} - A5);
resul = Bi([0],[0],[0],[1 0],[0 0 2],[3 0]);
conf(6) = norm(resul{1} - A6);
resul = Bi([0],[0],[0],[1 0],[2 0 0],[0 3]);
conf(7) = norm(resul{1} - B1);
resul = Bi([0],[0],[0],[0 1],[2 0 0],[0 3]);
conf(8) = norm(resul{1} - B2);
resul = Bi([0],[0],[0],[1 0],[1 1 0],[0 3]);
conf(9) = norm(resul{1} - B3);
resul = Bi([0],[0],[0],[1 0],[0 2 0],[0 3]);
conf(10) = norm(resul{1} - B4);
resul = Bi([0],[0],[0],[0 1],[1 0 1],[0 3]);
conf(11) = norm(resul{1} - B5);
resul = Bi([0],[0],[0],[1 0],[0 0 2],[0 3]);
conf(12) = norm(resul{1} - B6);
if (sum(conf) ~= 0)
    error('Nao passou');
end


disp('Teste 139');
clear A Ai B Bi conf;
A{1} = {[1 0],[2 0 0],[3 0],A1};
A{2} = {[0 1],[2 0 0],[3 0],A2};
A{3} = {[1 0],[1 1 0],[3 0],A3};
A{4} = {[1 0],[0 2 0],[3 0],A4};
A{5} = {[0 1],[1 0 1],[3 0],A5};
A{6} = {[1 0],[0 0 2],[3 0],A6};
A{7} = {[1 0],[2 0 0],[0 3],B1};
A{8} = {[0 1],[2 0 0],[0 3],B2};
A{9} = {[1 0],[1 1 0],[0 3],B3};
A{10} = {[1 0],[0 2 0],[0 3],B4};
A{11} = {[0 1],[1 0 1],[0 3],B5};
A{12} = {[1 0],[0 0 2],[0 3],B6};
Ai = rolmipvar(A,'A',[2 3 2],[1 2 3]);
Bi = fork(Ai,'B',[1 3]);
resul = Bi([0],[2 0 0],[0],[1 0],[3 0]);
conf(1) = norm(resul{1} - A1);
resul = Bi([0],[2 0 0],[0],[0 1],[3 0]);
conf(2) = norm(resul{1} - A2);
resul = Bi([0],[1 1 0],[0],[1 0],[3 0]);
conf(3) = norm(resul{1} - A3);
resul = Bi([0],[0 2 0],[0],[1 0],[3 0]);
conf(4) = norm(resul{1} - A4);
resul = Bi([0],[1 0 1],[0],[0 1],[3 0]);
conf(5) = norm(resul{1} - A5);
resul = Bi([0],[0 0 2],[0],[1 0],[3 0]);
conf(6) = norm(resul{1} - A6);
resul = Bi([0],[2 0 0],[0],[1 0],[0 3]);
conf(7) = norm(resul{1} - B1);
resul = Bi([0],[2 0 0],[0],[0 1],[0 3]);
conf(8) = norm(resul{1} - B2);
resul = Bi([0],[1 1 0],[0],[1 0],[0 3]);
conf(9) = norm(resul{1} - B3);
resul = Bi([0],[0 2 0],[0],[1 0],[0 3]);
conf(10) = norm(resul{1} - B4);
resul = Bi([0],[1 0 1],[0],[0 1],[0 3]);
conf(11) = norm(resul{1} - B5);
resul = Bi([0],[0 0 2],[0],[1 0],[0 3]);
conf(12) = norm(resul{1} - B6);
if (sum(conf) ~= 0)
    error('Nao passou');
end










disp('Teste 140');
clear A Ai B Bi conf;
A{1} = {[1 0],[2 0 0],[1 0],A1};
A{2} = {[0 1],[2 0 0],[1 0],A2};
A{3} = {[1 0],[1 1 0],[1 0],A3};
A{4} = {[1 0],[0 2 0],[1 0],A4};
A{5} = {[0 1],[1 0 1],[1 0],A5};
A{6} = {[1 0],[0 0 2],[1 0],A6};
A{7} = {[1 0],[2 0 0],[0 1],B1};
A{8} = {[0 1],[2 0 0],[0 1],B2};
A{9} = {[1 0],[1 1 0],[0 1],B3};
A{10} = {[1 0],[0 2 0],[0 1],B4};
A{11} = {[0 1],[1 0 1],[0 1],B5};
A{12} = {[1 0],[0 0 2],[0 1],B6};
Ai = rolmipvar(A,'A',[2 3 2],[1 2 1]);
Bi = fork(Ai,'B',[1 3],[3 4]);
resul = Bi([0],[2 0 0],[1 0],[1 0]);
conf(1) = norm(resul{1} - A1);
resul = Bi([0],[2 0 0],[0 1],[1 0]);
conf(2) = norm(resul{1} - A2);
resul = Bi([0],[1 1 0],[1 0],[1 0]);
conf(3) = norm(resul{1} - A3);
resul = Bi([0],[0 2 0],[1 0],[1 0]);
conf(4) = norm(resul{1} - A4);
resul = Bi([0],[1 0 1],[0 1],[1 0]);
conf(5) = norm(resul{1} - A5);
resul = Bi([0],[0 0 2],[1 0],[1 0]);
conf(6) = norm(resul{1} - A6);
resul = Bi([0],[2 0 0],[1 0],[0 1]);
conf(7) = norm(resul{1} - B1);
resul = Bi([0],[2 0 0],[0 1],[0 1]);
conf(8) = norm(resul{1} - B2);
resul = Bi([0],[1 1 0],[1 0],[0 1]);
conf(9) = norm(resul{1} - B3);
resul = Bi([0],[0 2 0],[1 0],[0 1]);
conf(10) = norm(resul{1} - B4);
resul = Bi([0],[1 0 1],[0 1],[0 1]);
conf(11) = norm(resul{1} - B5);
resul = Bi([0],[0 0 2],[1 0],[0 1]);
conf(12) = norm(resul{1} - B6);
if (sum(conf) ~= 0)
    error('Nao passou');
end




disp('Teste 141');
clear A Ai B Bi conf;
A{1} = {[1 0],[2 0 0],[2 0 0],A1};
A{2} = {[0 1],[2 0 0],[2 0 0],A2};
A{3} = {[1 0],[1 1 0],[2 0 0],A3};
A{4} = {[1 0],[0 2 0],[2 0 0],A4};
A{5} = {[0 1],[1 0 1],[2 0 0],A5};
A{6} = {[1 0],[0 0 2],[2 0 0],A6};
A{7} = {[1 0],[2 0 0],[0 2 0],B1};
A{8} = {[0 1],[2 0 0],[0 2 0],B2};
A{9} = {[1 0],[1 1 0],[0 2 0],B3};
A{10} = {[1 0],[0 2 0],[0 2 0],B4};
A{11} = {[0 1],[1 0 1],[0 2 0],B5};
A{12} = {[1 0],[0 0 2],[0 2 0],B6};
Ai = rolmipvar(A,'A',[2 3 3],[1 2 2]);
Bi = fork(Ai,'B',[2 3],[3 2]);
resul = Bi([1 0],[2 0 0],[2 0 0]);
conf(1) = norm(resul{1} - A1);
resul = Bi([0 1],[2 0 0],[2 0 0]);
conf(2) = norm(resul{1} - A2);
resul = Bi([1 0],[2 0 0],[1 1 0]);
conf(3) = norm(resul{1} - A3);
resul = Bi([1 0],[2 0 0],[0 2 0]);
conf(4) = norm(resul{1} - A4);
resul = Bi([0 1],[2 0 0],[1 0 1]);
conf(5) = norm(resul{1} - A5);
resul = Bi([1 0],[2 0 0],[0 0 2]);
conf(6) = norm(resul{1} - A6);
resul = Bi([1 0],[0 2 0],[2 0 0]);
conf(7) = norm(resul{1} - B1);
resul = Bi([0 1],[0 2 0],[2 0 0]);
conf(8) = norm(resul{1} - B2);
resul = Bi([1 0],[0 2 0],[1 1 0]);
conf(9) = norm(resul{1} - B3);
resul = Bi([1 0],[0 2 0],[0 2 0]);
conf(10) = norm(resul{1} - B4);
resul = Bi([0 1],[0 2 0],[1 0 1]);
conf(11) = norm(resul{1} - B5);
resul = Bi([1 0],[0 2 0],[0 0 2]);
conf(12) = norm(resul{1} - B6);
if (sum(conf) ~= 0)
    error('Nao passou');
end






try
    disp('Teste 142');
    clear A Ai B Bi conf;
    A{1} = {[1 0],[2 0 0],[3 0],A1};
    A{2} = {[0 1],[2 0 0],[3 0],A2};
    A{3} = {[1 0],[1 1 0],[3 0],A3};
    A{4} = {[1 0],[0 2 0],[3 0],A4};
    A{5} = {[0 1],[1 0 1],[3 0],A5};
    A{6} = {[1 0],[0 0 2],[3 0],A6};
    A{7} = {[1 0],[2 0 0],[0 3],B1};
    A{8} = {[0 1],[2 0 0],[0 3],B2};
    A{9} = {[1 0],[1 1 0],[0 3],B3};
    A{10} = {[1 0],[0 2 0],[0 3],B4};
    A{11} = {[0 1],[1 0 1],[0 3],B5};
    A{12} = {[1 0],[0 0 2],[0 3],B6};
    Ai = rolmipvar(A,'A',[2 3 2],[1 2 3]);
    Bi = fork(Ai,'B',[1 3],[3 4]);
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end







try
    disp('Teste 143');
    clear A Ai B Bi conf;
    A{1} = {[1 0],[2 0 0],[3 0],A1};
    A{2} = {[0 1],[2 0 0],[3 0],A2};
    A{3} = {[1 0],[1 1 0],[3 0],A3};
    A{4} = {[1 0],[0 2 0],[3 0],A4};
    A{5} = {[0 1],[1 0 1],[3 0],A5};
    A{6} = {[1 0],[0 0 2],[3 0],A6};
    A{7} = {[1 0],[2 0 0],[0 3],B1};
    A{8} = {[0 1],[2 0 0],[0 3],B2};
    A{9} = {[1 0],[1 1 0],[0 3],B3};
    A{10} = {[1 0],[0 2 0],[0 3],B4};
    A{11} = {[0 1],[1 0 1],[0 3],B5};
    A{12} = {[1 0],[0 0 2],[0 3],B6};
    Ai = rolmipvar(A,'A',[2 3 2],[1 2 3]);
    Bi = fork(Ai,'B',[2 3],[3 2]);
catch err
    passou = 1;
end
if (passou == 0)
    error('Nao detectou erro');
end

% Test input polynomials with bounded parameters
disp('Teste 144');
clear A Ai conf
am = -2; aM = 3;
A{1} = {[1],A1};
Ai = rolmipvar(A,'A',[am aM]);
resul = Ai([1 0]);
conf(1) = norm(resul{1} - am*A1);
resul = Ai([0 1]);
conf(2) = norm(resul{1} - aM*A1);
if(sum(conf) ~= 0)
	error('Nao passou');
end



disp('Teste 145');
clear A Ai conf
am = -2; aM = 3;
A{1} = {[0],A1};
A{2} = {[1],A2};
Ai = rolmipvar(A,'A',[am aM]);
resul = Ai([1 0]);
conf(1) = norm(resul{1} - (A1 + am*A2));
resul = Ai([0 1]);
conf(2) = norm(resul{1} - (A1 + aM*A2));
if(sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 146');
clear A Ai conf
a1m = -2; a1M = 3;
a2m = -4; a2M = -1;
A{1} = {[1 1],A1};
Ai = rolmipvar(A,'A',[a1m a1M; a2m a2M]);
resul = Ai([1 0],[1 0]);
conf(1) = norm(resul{1} - (a1m*a2m*A1));
resul = Ai([1 0],[0 1]);
conf(2) = norm(resul{1} - (a1m*a2M*A1));
resul = Ai([0 1],[1 0]);
conf(3) = norm(resul{1} - (a1M*a2m*A1));
resul = Ai([0 1],[0 1]);
conf(4) = norm(resul{1} - (a1M*a2M*A1));
if(sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 147');
clear A Ai conf
a1m = -2; a1M = 3;
a2m = -4; a2M = -1;
A{1} = {[0 0],A1};
A{2} = {[1 0],A2};
A{3} = {[1 1],A3};
Ai = rolmipvar(A,'A',[a1m a1M; a2m a2M]);
resul = Ai([1 0],[1 0]);
conf(1) = norm(resul{1} - (A1 + a1m*A2 + a1m*a2m*A3));
resul = Ai([1 0],[0 1]);
conf(2) = norm(resul{1} - (A1 + a1m*A2 + a1m*a2M*A3));
resul = Ai([0 1],[1 0]);
conf(3) = norm(resul{1} - (A1 + a1M*A2 + a1M*a2m*A3));
resul = Ai([0 1],[0 1]);
conf(4) = norm(resul{1} - (A1 + a1M*A2 + a1M*a2M*A3));
if(sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 148');
clear A Ai conf
a1m = -2; a1M = 3;
a2m = -4; a2M = -1;
a3m = -3; a3M = 5;
A{1} = {[2 0 0],A1};
A{2} = {[1 1 0],A2};
A{3} = {[1 0 3],A3};
A{4} = {[0 0 0],A4};
Ai = rolmipvar(A,'A',[a1m a1M; a2m a2M; a3m a3M]);
resul = Ai([2 0],[1 0],[3 0]);
conf(1) = norm(resul{1} - (a1m^2*A1 + a1m*a3m^3*A3 + a1m*a2m*A2 + A4));
resul = Ai([2 0],[1 0],[2 1]);
conf(2) = norm(resul{1} - (3*a1m^2*A1 + 3*a1m*a3m^2*a3M*A3 + 3*a1m*a2m*A2 + 3*A4));
resul = Ai([2 0],[1 0],[1 2]);
conf(3) = norm(resul{1} - (3*a1m^2*A1 + 3*a1m*a3m*a3M^2*A3 + 3*a1m*a2m*A2 + 3*A4));
resul = Ai([2 0],[1 0],[0 3]);
conf(4) = norm(resul{1} - (a1m^2*A1 + a1m*a3M^3*A3 + a1m*a2m*A2 + A4));

resul = Ai([2 0],[0 1],[3 0]);
conf(5) = norm(resul{1} - (a1m^2*A1 + a1m*a3m^3*A3 + a1m*a2M*A2 + A4));
resul = Ai([2 0],[0 1],[2 1]);
conf(6) = norm(resul{1} - (3*a1m^2*A1 + 3*a1m*a3m^2*a3M*A3 + 3*a1m*a2M*A2 + 3*A4));
resul = Ai([2 0],[0 1],[1 2]);
conf(7) = norm(resul{1} - (3*a1m^2*A1 + 3*a1m*a3m*a3M^2*A3 + 3*a1m*a2M*A2 + 3*A4));
resul = Ai([2 0],[0 1],[0 3]);
conf(8) = norm(resul{1} - (a1m^2*A1 + a1m*a3M^3*A3 + a1m*a2M*A2 + A4));

resul = Ai([1 1],[1 0],[3 0]);
conf(9) = norm(resul{1} - (2*a1m*a1M*A1 + (a1m+a1M)*a3m^3*A3 + (a1m+a1M)*a2m*A2 + 2*A4));
resul = Ai([1 1],[1 0],[2 1]);
conf(10) = norm(resul{1} - (6*a1m*a1M*A1 + 3*(a1m+a1M)*a3m^2*a3M*A3 + 3*(a1m+a1M)*a2m*A2 + 6*A4));
resul = Ai([1 1],[1 0],[1 2]);
conf(11) = norm(resul{1} - (6*a1m*a1M*A1 + 3*(a1m+a1M)*a3m*a3M^2*A3 + 3*(a1m+a1M)*a2m*A2 + 6*A4));
resul = Ai([1 1],[1 0],[0 3]);
conf(12) = norm(resul{1} - (2*a1m*a1M*A1 + (a1m+a1M)*a3M^3*A3 + (a1m+a1M)*a2m*A2 + 2*A4));

resul = Ai([1 1],[0 1],[3 0]);
conf(13) = norm(resul{1} - (2*a1m*a1M*A1 + (a1m+a1M)*a3m^3*A3 + (a1m+a1M)*a2M*A2 + 2*A4));
resul = Ai([1 1],[0 1],[2 1]);
conf(14) = norm(resul{1} - (6*a1m*a1M*A1 + 3*(a1m+a1M)*a3m^2*a3M*A3 + 3*(a1m+a1M)*a2M*A2 + 6*A4));
resul = Ai([1 1],[0 1],[1 2]);
conf(15) = norm(resul{1} - (6*a1m*a1M*A1 + 3*(a1m+a1M)*a3m*a3M^2*A3 + 3*(a1m+a1M)*a2M*A2 + 6*A4));
resul = Ai([1 1],[0 1],[0 3]);
conf(16) = norm(resul{1} - (2*a1m*a1M*A1 + (a1m+a1M)*a3M^3*A3 + (a1m+a1M)*a2M*A2 + 2*A4));

resul = Ai([0 2],[1 0],[3 0]);
conf(17) = norm(resul{1} - (a1M^2*A1 + a1M*a3m^3*A3 + a1M*a2m*A2 + A4));
resul = Ai([0 2],[1 0],[2 1]);
conf(18) = norm(resul{1} - (3*a1M^2*A1 + 3*a1M*a3m^2*a3M*A3 + 3*a1M*a2m*A2 + 3*A4));
resul = Ai([0 2],[1 0],[1 2]);
conf(19) = norm(resul{1} - (3*a1M^2*A1 + 3*a1M*a3m*a3M^2*A3 + 3*a1M*a2m*A2 + 3*A4));
resul = Ai([0 2],[1 0],[0 3]);
conf(20) = norm(resul{1} - (a1M^2*A1 + a1M*a3M^3*A3 + a1M*a2m*A2 + A4));

resul = Ai([0 2],[0 1],[3 0]);
conf(21) = norm(resul{1} - (a1M^2*A1 + a1M*a3m^3*A3 + a1M*a2M*A2 + A4));
resul = Ai([0 2],[0 1],[2 1]);
conf(22) = norm(resul{1} - (3*a1M^2*A1 + 3*a1M*a3m^2*a3M*A3 + 3*a1M*a2M*A2 + 3*A4));
resul = Ai([0 2],[0 1],[1 2]);
conf(23) = norm(resul{1} - (3*a1M^2*A1 + 3*a1M*a3m*a3M^2*A3 + 3*a1M*a2M*A2 + 3*A4));
resul = Ai([0 2],[0 1],[0 3]);
conf(24) = norm(resul{1} - (a1M^2*A1 + a1M*a3M^3*A3 + a1M*a2M*A2 + A4));

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 149');
clear A Ai conf;

A{1} = {[1 0],[1 0],A1};
A{2} = {[1 0],[0 1],A2};
A{3} = {[0 1],[1 0],A3};
A{4} = {[0 1],[0 1],A4};
Ai = rolmipvar(A,'A',[2 2],[1 1]);
T = [2 4 7; 3 5 6];
Bi = simpltransf(Ai,1,3,T);
resul = Bi([0 0],[1 0],[1 0 0]);
conf(1) = norm(resul{1} - (2*A1 + 3*A3));
resul = Bi([0 0],[1 0],[0 1 0]);
conf(2) = norm(resul{1} - (4*A1 + 5*A3));
resul = Bi([0 0],[1 0],[0 0 1 ]);
conf(3) = norm(resul{1} - (7*A1 + 6*A3));
resul = Bi([0 0],[0 1],[1 0 0]);
conf(4) = norm(resul{1} - (2*A2 + 3*A4));
resul = Bi([0 0],[0 1],[0 1 0]);
conf(5) = norm(resul{1} - (4*A2 + 5*A4));
resul = Bi([0 0],[0 1],[0 0 1 ]);
conf(6) = norm(resul{1} - (7*A2 + 6*A4));

if (sum(conf) ~= 0)
	error('Nao passou');
end



disp('Teste 150');
clear A Ai conf T;

A{1} = {[1 0 0],[1 0],A1};
A{2} = {[1 0 0],[0 1],A2};
A{3} = {[0 1 0],[1 0],A3};
A{4} = {[0 1 0],[0 1],A4};
A{5} = {[0 0 1],[1 0],A5};
A{6} = {[0 0 1],[0 1],A6};
Ai = rolmipvar(A,'A',[3 2],[1 1]);
T = [1 2; 3 5; 2 3];
Bi = simpltransf(Ai,1,3,T);
resul = Bi([0 0 0],[1 0],[1 0]);
conf(1) = norm(resul{1} - (A1 + 3*A3 + 2*A5));
resul = Bi([0 0 0],[1 0],[0 1]);
conf(2) = norm(resul{1} - (2*A1 + 5*A3 + 3*A5));
resul = Bi([0 0 0],[0 1],[1 0]);
conf(3) = norm(resul{1} - (A2 + 3*A4 + 2*A6));
resul = Bi([0 0 0],[0 1],[0 1]);
conf(4) = norm(resul{1} - (2*A2 + 5*A4 + 3*A6));

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 151');
clear A Ai conf;

A{1} = {[2 0],[1 0],A1};
A{2} = {[1 1],[1 0],A2};
A{3} = {[0 2],[1 0],A3};
A{4} = {[2 0],[0 1],A4};
A{5} = {[1 1],[0 1],A5};
A{6} = {[0 2],[0 1],A6};
Ai = rolmipvar(A,'A',[2 2],[2 1]);
T = [1 2 1; 2 3 3];
Bi = simpltransf(Ai,1,3,T);
resul = Bi([0 0],[1 0],[2 0 0]);
conf(1) = norm(resul{1} - (A1 + 2*A2 + 4*A3));
resul = Bi([0 0],[1 0],[1 1 0]);
conf(2) = norm(resul{1} - (4*A1 + 7*A2 + 12*A3));
resul = Bi([0 0],[1 0],[1 0 1]);
conf(3) = norm(resul{1} - (2*A1 + 5*A2 + 12*A3));
resul = Bi([0 0],[1 0],[0 1 1]);
conf(4) = norm(resul{1} - (4*A1 + 9*A2 + 18*A3));
resul = Bi([0 0],[1 0],[0 2 0]);
conf(5) = norm(resul{1} - (4*A1 + 6*A2 + 9*A3));
resul = Bi([0 0],[1 0],[0 0 2]);
conf(6) = norm(resul{1} - (A1 + 3*A2 + 9*A3));
resul = Bi([0 0],[0 1],[2 0 0]);
conf(7) = norm(resul{1} - (A4 + 2*A5 + 4*A6));
resul = Bi([0 0],[0 1],[1 1 0]);
conf(8) = norm(resul{1} - (4*A4 + 7*A5 + 12*A6));
resul = Bi([0 0],[0 1],[1 0 1]);
conf(9) = norm(resul{1} - (2*A4 + 5*A5 + 12*A6));
resul = Bi([0 0],[0 1],[0 1 1]);
conf(10) = norm(resul{1} - (4*A4 + 9*A5 + 18*A6));
resul = Bi([0 0],[0 1],[0 2 0]);
conf(11) = norm(resul{1} - (4*A4 + 6*A5 + 9*A6));
resul = Bi([0 0],[0 1],[0 0 2]);
conf(12) = norm(resul{1} - (A4 + 3*A5 + 9*A6));


    if (sum(conf) ~= 0)
	error('Nao passou');
end



disp('Teste 152');
clear A Ai conf T;

A{1} = {[2 0 0],[1 0],A1};
A{2} = {[1 1 0],[1 0],A2};
A{3} = {[1 0 1],[1 0],A3};
A{4} = {[0 1 1],[1 0],A4};
A{5} = {[0 2 0],[1 0],A5};
A{6} = {[0 0 2],[1 0],A6};
A{7} = {[2 0 0],[0 1],B1};
A{8} = {[1 1 0],[0 1],B2};
A{9} = {[1 0 1],[0 1],B3};
A{10} = {[0 1 1],[0 1],B4};
A{11} = {[0 2 0],[0 1],B5};
A{12} = {[0 0 2],[0 1],B6};

Ai = rolmipvar(A,'A',[3 2],[2 1]);
T = [1 1; 2 3; 3 3];
Bi = simpltransf(Ai,1,3,T);
resul = Bi([0 0 0],[1 0],[2 0]);
conf(1) = norm(resul{1} - (A1 + 2*A2 + 3*A3 + 6*A4 + 4*A5 + 9*A6));
resul = Bi([0 0 0],[1 0],[1 1]);
conf(2) = norm(resul{1} - (2*A1 + 5*A2 + 6*A3 + 15*A4 + 12*A5 + 18*A6));
resul = Bi([0 0 0],[1 0],[0 2]);
conf(3) = norm(resul{1} - (A1 + 3*A2 + 3*A3 + 9*A4 + 9*A5 + 9*A6));
resul = Bi([0 0 0],[0 1],[2 0]);
conf(4) = norm(resul{1} - (B1 + 2*B2 + 3*B3 + 6*B4 + 4*B5 + 9*B6));
resul = Bi([0 0 0],[0 1],[1 1]);
conf(5) = norm(resul{1} - (2*B1 + 5*B2 + 6*B3 + 15*B4 + 12*B5 + 18*B6));
resul = Bi([0 0 0],[0 1],[0 2]);
conf(6) = norm(resul{1} - (B1 + 3*B2 + 3*B3 + 9*B4 + 9*B5 + 9*B6));


if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 153');
clear A Ai conf T;

A{1} = {[1 0],[1 0],A1};
A{2} = {[1 0],[0 1],A2};
A{3} = {[0 1],[1 0],A3};
A{4} = {[0 1],[0 1],A4};
Ai = rolmipvar(A,'A',[2 2],[1 1]);
T = [1 2; 3 -1];

Bi = simpltransf(Ai,1,2,T);
resul = Bi([0 0],[2 0]);
conf(1) = norm(resul{1} - (A1 + 3*A3));
resul = Bi([0 0],[1 1]);
conf(2) = norm(resul{1} - (2*A1 + A2 - A3 + 3*A4));
resul = Bi([0 0],[0 2]);
conf(3) = norm(resul{1} - (2*A2 - A4));

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 154');
clear A Ai T conf;

A{1} = {[2 0 0],[1 0],A1};
A{2} = {[1 1 0],[1 0],A2};
A{3} = {[1 0 1],[1 0],A3};
A{4} = {[0 1 1],[1 0],A4};
A{5} = {[0 2 0],[1 0],A5};
A{6} = {[0 0 2],[1 0],A6};
A{7} = {[2 0 0],[0 1],B1};
A{8} = {[1 1 0],[0 1],B2};
A{9} = {[1 0 1],[0 1],B3};
A{10} = {[0 1 1],[0 1],B4};
A{11} = {[0 2 0],[0 1],B5};
A{12} = {[0 0 2],[0 1],B6};

Ai = rolmipvar(A,'A',[3 2],[2 1]);
T = [1 2; 3 -1; -1 4];
Bi = simpltransf(Ai,1,2,T);
resul = Bi([0 0],[3 0]);
conf(1) = norm(resul{1} - (A1 + 3*A2 - A3 - 3*A4 + 9*A5 + A6));
resul = Bi([0 0],[2 1]);
conf(2) = norm(resul{1} - (4*A1 + 5*A2 + 2*A3 + 13*A4 - 6*A5 - 8*A6 + B1 + 3*B2 - B3 - 3*B4 + 9*B5 + B6));
resul = Bi([0 0],[1 2]);
conf(3) = norm(resul{1} - (4*A1 - 2*A2 + 8*A3 - 4*A4 + A5 + 16*A6 + 4*B1 + 5*B2 + 2*B3 + 13*B4 - 6*B5 - 8*B6));
resul = Bi([0 0],[0 3]);
conf(4) = norm(resul{1} - (4*B1 - 2*B2 + 8*B3 - 4*B4 + B5 + 16*B6));

if (sum(conf) ~= 0)
	error('Nao passou');
end



disp('Teste 155');
clear A Ai conf T;

A{1} = {[1 0],[2 0],A1};
A{2} = {[0 1],[2 0],A2};
A{3} = {[1 0],[1 1],A3};
A{4} = {[0 1],[1 1],A4};
A{5} = {[1 0],[0 2],A5};
A{6} = {[0 1],[0 2],A6};

Ai = rolmipvar(A,'A',[2 2],[1 2]);
T = [1 3; 2 -1];
Bi = simpltransf(Ai,1,2,T);
resul = Bi([0 0],[3 0]);
conf(1) = norm(resul{1} - (A1 + 2*A2));
resul = Bi([0 0],[2 1]);
conf(2) = norm(resul{1} - (3*A1 - A2 + A3 + 2*A4));
resul = Bi([0 0],[1 2]);
conf(3) = norm(resul{1} - (3*A3 - A4 + A5 + 2*A6));
resul = Bi([0 0],[0 3]);
conf(4) = norm(resul{1} - (3*A5 - A6));

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 156');
clear A Ai T conf;

A{1} = {[1 0],[2 0 0],A1};
A{2} = {[1 0],[1 1 0],A2};
A{3} = {[1 0],[1 0 1],A3};
A{4} = {[1 0],[0 1 1],A4};
A{5} = {[1 0],[0 2 0],A5};
A{6} = {[1 0],[0 0 2],A6};
A{7} = {[0 1],[2 0 0],B1};
A{8} = {[0 1],[1 1 0],B2};
A{9} = {[0 1],[1 0 1],B3};
A{10} = {[0 1],[0 1 1],B4};
A{11} = {[0 1],[0 2 0],B5};
A{12} = {[0 1],[0 0 2],B6};

Ai = rolmipvar(A,'A',[2 3],[1 2]);
T = [1 2; 3 -1; -1 4];
Bi = simpltransf(Ai,2,1,T);
resul = Bi([3 0],[0 0]);
conf(1) = norm(resul{1} - (A1 + 3*A2 - A3 - 3*A4 + 9*A5 + A6));
resul = Bi([2 1],[0 0]);
conf(2) = norm(resul{1} - (4*A1 + 5*A2 + 2*A3 + 13*A4 - 6*A5 - 8*A6 + B1 + 3*B2 - B3 - 3*B4 + 9*B5 + B6));
resul = Bi([1 2],[0 0]);
conf(3) = norm(resul{1} - (4*A1 - 2*A2 + 8*A3 - 4*A4 + A5 + 16*A6 + 4*B1 + 5*B2 + 2*B3 + 13*B4 - 6*B5 - 8*B6));
resul = Bi([0 3],[0 0]);
conf(4) = norm(resul{1} - (4*B1 - 2*B2 + 8*B3 - 4*B4 + B5 + 16*B6));

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 157');
clear A Ai dA conf;
A{1} = {[1 0],A1};
A{2} = {[0 1],A2};

Ai = rolmipvar(A,'A',2,1);
dA = partial(Ai,1);
conf(1) = norm(coefs(dA{1}) - A1);
conf(2) = norm(coefs(dA{2}) - A2);
if (sum(conf) ~= 0)
	error('Nao passou');
end

disp('Teste 158');
clear A Ai conf dA1 dA2;

A{1} = {[2 0 0],[1 0],A1};
A{2} = {[1 1 0],[1 0],A2};
A{3} = {[1 0 1],[1 0],A3};
A{4} = {[0 1 1],[1 0],A4};
A{5} = {[0 2 0],[1 0],A5};
A{6} = {[0 0 2],[1 0],A6};
A{7} = {[2 0 0],[0 1],B1};
A{8} = {[1 1 0],[0 1],B2};
A{9} = {[1 0 1],[0 1],B3};
A{10} = {[0 1 1],[0 1],B4};
A{11} = {[0 2 0],[0 1],B5};
A{12} = {[0 0 2],[0 1],B6};

Ai = rolmipvar(A,'A',[3 2],[2 1]);
dA1 = partial(Ai,1);
dA2 = partial(Ai,2);
pol = dA1{1};
resul = pol([1 0 0],[1 0]);
conf(1) = norm(resul{1} - 2*A1);
resul = pol([0 1 0],[1 0]);
conf(2) = norm(resul{1} - A2);
resul = pol([0 0 1],[1 0]);
conf(3) = norm(resul{1} - A3);
resul = pol([1 0 0],[0 1]);
conf(4) = norm(resul{1} - 2*B1);
resul = pol([0 1 0],[0 1]);
conf(5) = norm(resul{1} - B2);
resul = pol([0 0 1],[0 1]);
conf(6) = norm(resul{1} - B3);

pol = dA1{2};
resul = pol([1 0 0],[1 0]);
conf(7) = norm(resul{1} - A2);
resul = pol([0 1 0],[1 0]);
conf(8) = norm(resul{1} - 2*A5);
resul = pol([0 0 1],[1 0]);
conf(9) = norm(resul{1} - A4);
resul = pol([1 0 0],[0 1]);
conf(10) = norm(resul{1} - B2);
resul = pol([0 1 0],[0 1]);
conf(11) = norm(resul{1} - 2*B5);
resul = pol([0 0 1],[0 1]);
conf(12) = norm(resul{1} - B4);

pol = dA1{3};
resul = pol([1 0 0],[1 0]);
conf(13) = norm(resul{1} - A3);
resul = pol([0 1 0],[1 0]);
conf(14) = norm(resul{1} - A4);
resul = pol([0 0 1],[1 0]);
conf(15) = norm(resul{1} - 2*A6);
resul = pol([1 0 0],[0 1]);
conf(16) = norm(resul{1} - B3);
resul = pol([0 1 0],[0 1]);
conf(17) = norm(resul{1} - B4);
resul = pol([0 0 1],[0 1]);
conf(18) = norm(resul{1} - 2*B6);

pol = dA2{1};
resul = pol([2 0 0],[0 0]);
conf(19) = norm(resul{1} - A1);
resul = pol([1 1 0],[0 0]);
conf(20) = norm(resul{1} - A2);
resul = pol([1 0 1],[0 0]);
conf(21) = norm(resul{1} - A3);
resul = pol([0 1 1],[0 0]);
conf(22) = norm(resul{1} - A4);
resul = pol([0 2 0],[0 0]);
conf(23) = norm(resul{1} - A5);
resul = pol([0 0 2],[0 0]);
conf(24) = norm(resul{1} - A6);

pol = dA2{2};
resul = pol([2 0 0],[0 0]);
conf(25) = norm(resul{1} - B1);
resul = pol([1 1 0],[0 0]);
conf(26) = norm(resul{1} - B2);
resul = pol([1 0 1],[0 0]);
conf(27) = norm(resul{1} - B3);
resul = pol([0 1 1],[0 0]);
conf(28) = norm(resul{1} - B4);
resul = pol([0 2 0],[0 0]);
conf(29) = norm(resul{1} - B5);
resul = pol([0 0 2],[0 0]);
conf(30) = norm(resul{1} - B6);

if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 159');
clear A Ai conf dA1 dA2 pol;

A{1} = {[1 0],[2 0],A1};
A{2} = {[0 1],[2 0],A2};
A{3} = {[1 0],[1 1],A3};
A{4} = {[0 1],[1 1],A4};
A{5} = {[1 0],[0 2],A5};
A{6} = {[0 1],[0 2],A6};

Ai = rolmipvar(A,'A',[2 2],[1 2]);
dA1 = partial(Ai,1);
dA2 = partial(Ai,2);
pol = dA1{1};
resul = pol([0 0],[2 0]);
conf(1) = norm(resul{1} - A1);
resul = pol([0 0],[1 1]);
conf(2) = norm(resul{1} - A3);
resul = pol([0 0],[0 2]);
conf(3) = norm(resul{1} - A5);

pol = dA1{2};
resul = pol([0 0],[2 0]);
conf(4) = norm(resul{1} - A2);
resul = pol([0 0],[1 1]);
conf(5) = norm(resul{1} - A4);
resul = pol([0 0],[0 2]);
conf(6) = norm(resul{1} - A6);

pol = dA2{1};
resul = pol([1 0],[1 0]);
conf(7) = norm(resul{1} - 2*A1);
resul = pol([0 1],[1 0]);
conf(8) = norm(resul{1} - 2*A2);
resul = pol([1 0],[0 1]);
conf(9) = norm(resul{1} - A3);
resul = pol([0 1],[0 1]);
conf(10) = norm(resul{1} - A4);

pol = dA2{2};
resul = pol([1 0],[1 0]);
conf(11) = norm(resul{1} - A3);
resul = pol([0 1],[1 0]);
conf(12) = norm(resul{1} - A4);
resul = pol([1 0],[0 1]);
conf(13) = norm(resul{1} - 2*A5);
resul = pol([0 1],[0 1]);
conf(14) = norm(resul{1} - 2*A6);


if (sum(conf) ~= 0)
	error('Nao passou');
end


disp('Teste 160');
clear A Ai conf dA1 dA2 pol;

A{1} = {[1 0],[2 0 0],A1};
A{2} = {[1 0],[1 1 0],A2};
A{3} = {[1 0],[1 0 1],A3};
A{4} = {[1 0],[0 1 1],A4};
A{5} = {[1 0],[0 2 0],A5};
A{6} = {[1 0],[0 0 2],A6};
A{7} = {[0 1],[2 0 0],B1};
A{8} = {[0 1],[1 1 0],B2};
A{9} = {[0 1],[1 0 1],B3};
A{10} = {[0 1],[0 1 1],B4};
A{11} = {[0 1],[0 2 0],B5};
A{12} = {[0 1],[0 0 2],B6};

Ai = rolmipvar(A,'A',[2 3],[1 2]);
dA1 = partial(Ai,1);
dA2 = partial(Ai,2);
pol = dA1{1};
resul = pol([0 0],[2 0 0]);
conf(1) = norm(resul{1} - A1);
resul = pol([0 0],[1 1 0]);
conf(2) = norm(resul{1} - A2);
resul = pol([0 0],[1 0 1]);
conf(3) = norm(resul{1} - A3);
resul = pol([0 0],[0 1 1]);
conf(4) = norm(resul{1} - A4);
resul = pol([0 0],[0 2 0]);
conf(5) = norm(resul{1} - A5);
resul = pol([0 0],[0 0 2]);
conf(6) = norm(resul{1} - A6);

pol = dA1{2};
resul = pol([0 0],[2 0 0]);
conf(7) = norm(resul{1} - B1);
resul = pol([0 0],[1 1 0]);
conf(8) = norm(resul{1} - B2);
resul = pol([0 0],[1 0 1]);
conf(9) = norm(resul{1} - B3);
resul = pol([0 0],[0 1 1]);
conf(10) = norm(resul{1} - B4);
resul = pol([0 0],[0 2 0]);
conf(11) = norm(resul{1} - B5);
resul = pol([0 0],[0 0 2]);
conf(12) = norm(resul{1} - B6);

pol = dA2{1};
resul = pol([1 0],[1 0 0]);
conf(13) = norm(resul{1} - 2*A1);
resul = pol([1 0],[0 1 0]);
conf(14) = norm(resul{1} - A2);
resul = pol([1 0],[0 0 1]);
conf(15) = norm(resul{1} - A3);
resul = pol([0 1],[1 0 0]);
conf(16) = norm(resul{1} - 2*B1);
resul = pol([0 1],[0 1 0]);
conf(17) = norm(resul{1} - B2);
resul = pol([0 1],[0 0 1]);
conf(18) = norm(resul{1} - B3);

pol = dA2{2};
resul = pol([1 0],[1 0 0]);
conf(19) = norm(resul{1} - A2);
resul = pol([1 0],[0 1 0]);
conf(20) = norm(resul{1} - 2*A5);
resul = pol([1 0],[0 0 1]);
conf(21) = norm(resul{1} - A4);
resul = pol([0 1],[1 0 0]);
conf(22) = norm(resul{1} - B2);
resul = pol([0 1],[0 1 0]);
conf(23) = norm(resul{1} - 2*B5);
resul = pol([0 1],[0 0 1]);
conf(24) = norm(resul{1} - B4);

pol = dA2{3};
resul = pol([1 0],[1 0 0]);
conf(25) = norm(resul{1} - A3);
resul = pol([1 0],[0 1 0]);
conf(26) = norm(resul{1} - A4);
resul = pol([1 0],[0 0 1]);
conf(27) = norm(resul{1} - 2*A6);
resul = pol([0 1],[1 0 0]);
conf(27) = norm(resul{1} - B3);
resul = pol([0 1],[0 1 0]);
conf(29) = norm(resul{1} - B4);
resul = pol([0 1],[0 0 1]);
conf(30) = norm(resul{1} - 2*B6);

if (sum(conf) ~= 0)
	error('Nao passou');
end

%tempo = 97.7010
return


function [Ai, Bi, Ci] = define(tipo)
global A1 A2 A3 A4 A5 A6;
global B1 B2 B3 B4 B5 B6;
global C1 C2 C3 C4 C5 C6;

rolmip('clearvar');
if (tipo == 1)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[1 0],B1};
    B{2} = {[0 1],B2};
    Bi = rolmipvar(B,'B',2,1);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
    %%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 2)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,'B',0,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
elseif (tipo == 3)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,'B',2,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
elseif (tipo == 4)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = B1;
    Bi = rolmipvar(B,'B',0,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
elseif (tipo == 5)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,'B',0,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
elseif (tipo == 6)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,  'B', 2,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
elseif (tipo == 7)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[2 0],C1};
    C{2} = {[1 1],C2};
    C{3} = {[0 2],C3};
    Ci = rolmipvar(C,  'C', 2,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 8)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],C1};
    Ci = rolmipvar(C,  'C', 0,0);
elseif (tipo == 9)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,  'B', 2,0);
    C{1} = {[0 0],C1};
    Ci = rolmipvar(C,  'C', 2,0);
elseif (tipo == 10)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = C1;
    Ci = rolmipvar(C,  'C', 0,0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 11)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 12)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,  'B', 2,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 13)
    A{1} = {[1 0],A1};
    A{2} = {[0 1],A2};
    Ai = rolmipvar(A,'A',2,1);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 14)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 15)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,  'B', 2,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 16)
    A{1} = A1;
    A{2} = A2;
    Ai = rolmipvar(A,'A',2,1);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 17)
    A{1} = {[1 0],[0],A1};
    A{2} = {[0 1],[0],A2};
    Ai = rolmipvar(A,'A',[2 0],[1 0]);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 18)
    A{1} = {[1 0],[0],A1};
    A{2} = {[0 1],[0],A2};
    Ai = rolmipvar(A,'A',[2 0],[1 0]);
    B{1} = {[0 0],B1};
    Bi = rolmipvar(B,  'B', 2,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 19)
    A{1} = {[1 0],[0],A1};
    A{2} = {[0 1],[0],A2};
    Ai = rolmipvar(A,'A',[2 0],[1 0]);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 20)
    A{1} = {[1 0],[0],A1};
    A{2} = {[0 1],[0],A2};
    Ai = rolmipvar(A,'A',[2 0],[1 0]);
    B{1} = {[0],[0],B1};
    Bi = rolmipvar(B,  'B', [0 0],[0 0]);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
elseif (tipo == 21)
    A{1} = {[1 0],[0],A1};
    A{2} = {[0 1],[0],A2};
    Ai = rolmipvar(A,'A',[2 0],[1 0]);
    B{1} = {[0 0],[0 0],B1};
    Bi = rolmipvar(B,  'B', [2 2],[0 0]);
    C{1} = {[0],[1 0],C1};
    C{2} = {[0],[0 1],C2};
    Ci = rolmipvar(C,  'C', [0 2],[0 1]);
    %%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 22)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 23)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 24)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[0],B1};
    Bi = rolmipvar(B,  'B', [0 0],[0 0]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 25)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[0 0],B1};
    Bi = rolmipvar(B,  'B', [2 2],[0 0]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 26)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = B1;
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 27)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 28)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[0],B1};
    Bi = rolmipvar(B,  'B', [0 0],[0 0]);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 29)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[0 0],B1};
    Bi = rolmipvar(B,  'B', [2 2],[0 0]);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 30)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = B1;
    Bi = rolmipvar(B,'B');
    Ci = rolmipvar([C1 C2],  'C', 2,1);
elseif (tipo == 31)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],B1};
    Bi = rolmipvar(B,  'B', 0,0);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
elseif (tipo == 32)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[0],B1};
    Bi = rolmipvar(B,  'B', [0 0],[0 0]);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
elseif (tipo == 33)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[0 0],B1};
    Bi = rolmipvar(B,  'B', [2 2],[0 0]);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 34)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[1 0],B1};
    B{2} = {[0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [0 2],[0 1]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 35)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[1 0],B1};
    B{2} = {[0 0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [2 2],[0 1]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 36)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[1 0],B1};
    B{2} = {[0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [0 2],[0 1]);
    C{1} = {[1 0],[0],C1};
    C{2} = {[0 1],[0],C2};
    Ci = rolmipvar(C,  'C', [2 0],[1 0]);
elseif (tipo == 37)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[1 0],B1};
    B{2} = {[0 0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [2 2],[0 1]);
    C{1} = {[1 0],[0],C1};
    C{2} = {[0 1],[0],C2};
    Ci = rolmipvar(C,  'C', [2 0],[1 0]);
elseif (tipo == 38)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0],[1 0],B1};
    B{2} = {[0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [0 2],[0 1]);
    C{1} = {[1 0],[0 0],C1};
    C{2} = {[0 1],[0 0],C2};
    Ci = rolmipvar(C,  'C', [2 2],[1 0]);
elseif (tipo == 39)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[0 0],[1 0],B1};
    B{2} = {[0 0],[0 1],B2};
    Bi = rolmipvar(B,  'B', [2 2],[0 1]);
    C{1} = {[1 0],[0 0],C1};
    C{2} = {[0 1],[0 0],C2};
    Ci = rolmipvar(C,  'C', [2 2],[1 0]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 40)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = C1;
    Ci = rolmipvar(C,  'C', 0,0);
elseif (tipo == 41)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = C1;
    Ci = rolmipvar(C,'C');
elseif (tipo == 42)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = {[0],[0],C1};
    Ci = rolmipvar(C,  'C', [0 0],[0 0]);
elseif (tipo == 43)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = {[0],[0],C1};
    Ci = rolmipvar(C,  'C', [0 0],[0 0]);
elseif (tipo == 44)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = {[0 0],[0 0 0],C1};
    Ci = rolmipvar(C,  'C', [2 3],[0 0]);
elseif (tipo == 45)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = {[0 0],[0 0 0],C1};
    Ci = rolmipvar(C,  'C', [2 3],[0 0]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 46)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 47)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 48)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = {[1 0],[0],C1};
    C{2} = {[0 1],[0],C2};
    Ci = rolmipvar(C,  'C', [2 0],[1 0]);
elseif (tipo == 49)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = {[1 0],[0],C1};
    C{2} = {[0 1],[0],C2};
    Ci = rolmipvar(C,  'C', [2 0],[1 0]);
elseif (tipo == 50)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = {[1 0],[0 0 0],C1};
    C{2} = {[0 1],[0 0 0],C2};
    Ci = rolmipvar(C,  'C', [2 3],[1 0]);
elseif (tipo == 51)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = {[1 0],[0 0 0],C1};
    C{2} = {[0 1],[0 0 0],C2};
    Ci = rolmipvar(C,  'C', [2 3],[1 0]);
elseif (tipo == 52)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 53)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    C{1} = C1;
    C{2} = C2;
    Ci = rolmipvar(C,  'C', 2,1);
elseif (tipo == 54)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0],[1 0 0],B1};
    B{2} = {[0],[0 1 0],B2};
    B{3} = {[0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [0 3],[0 1]);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
elseif (tipo == 55)
    A{1} = {[1 0],[1 0 0],A1};
    A{2} = {[1 0],[0 1 0],A2};
    A{3} = {[1 0],[0 0 1],A3};
    A{4} = {[0 1],[1 0 0],A4};
    A{5} = {[0 1],[0 1 0],A5};
    A{6} = {[0 1],[0 0 1],A6};
    Ai = rolmipvar(A,'A',[2 3],[1 1]);
    B{1} = {[0 0],[1 0 0],B1};
    B{2} = {[0 0],[0 1 0],B2};
    B{3} = {[0 0],[0 0 1],B3};
    Bi = rolmipvar(B,  'B', [2 3],[0 1]);
    Ci = rolmipvar([C1 C2],  'C', 2,1);
    %%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 56)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[2 0],B1};
    B{2} = {[1 1],B2};
    B{3} = {[0 2],B3};
    Bi = rolmipvar(B,  'B', 2,2);
    C{1} = C1;
    Ci = rolmipvar(C,  'C', 0,0);
elseif (tipo == 57)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[2 0],[0],B1};
    B{2} = {[1 1],[0],B2};
    B{3} = {[0 2],[0],B3};
    Bi = rolmipvar(B,  'B', [2 0],[2 0]);
    C{1} = C1;
    Ci = rolmipvar(C,  'C', 0,0);
elseif (tipo == 58)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[2 0],[0 0],B1};
    B{2} = {[1 1],[0 0],B2};
    B{3} = {[0 2],[0 0],B3};
    Bi = rolmipvar(B,  'B', [2 2],[2 0]);
    C{1} = C1;
    Ci = rolmipvar(C,  'C', 0,0);
    %%%%%%%%%%%%%%%%%%%%%%%%
elseif (tipo == 59)
    A{1} = {[1 0],[1 0],A1};
    A{2} = {[1 0],[0 1],A2};
    A{3} = {[0 1],[1 0],A3};
    A{4} = {[0 1],[0 1],A4};
    Ai = rolmipvar(A,'A',[2 2],[1 1]);
    B{1} = {[2 0],[1 0],B1};
    B{2} = {[1 1],[1 0],B2};
    B{3} = {[0 2],[1 0],B3};
    B{4} = {[2 0],[0 1],B4};
    B{5} = {[1 1],[0 1],B5};
    B{6} = {[0 2],[0 1],B6};
    Bi = rolmipvar(B,  'B', [2 2],[2 1]);
    C{1} = {[1 0],C1};
    C{2} = {[0 1],C2};
    Ci = rolmipvar(C,  'C', 2,1);
end
    
return
