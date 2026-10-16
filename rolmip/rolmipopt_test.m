function rolmipopt_test
% ROLMIPOPT_TEST  Autoteste do ROLMIPopt.
%
%   Executa uma bateria de verificacoes numericas independentes (nao
%   requer o ROLMIP original nem o YALMIP):
%     * ordem das tabelas de expoentes identica ao algoritmo recursivo
%       original do ROLMIP;
%     * indexacao combinatoria (ROLMIPOPT_INDEX) consistente com as
%       tabelas;
%     * identidades de avaliacao: (P*Q)(a) = P(a)*Q(a), (P+Q)(a) =
%       P(a)+Q(a), invariancia sob Polya/homogeneizacao, derivada temporal
%       contra o gradiente analitico, conversao por bounds contra a
%       avaliacao direta;
%     * se o YALMIP estiver no path, construcao de LMIs com variaveis de
%       decisao.
%
%   Uso:  >> rolmipopt_test

nfail = 0;
tol = 1e-10;

    function check(nome, cond)
        if (cond)
            fprintf('  [ok]     %s\n', nome);
        else
            fprintf('  [FALHOU] %s\n', nome);
            nfail = nfail + 1;
        end
    end

    function e = ghe_ref(v,d)
        % referencia: algoritmo recursivo do ROLMIP original
        e = [];
        if (v == 1), e = d; return; end
        if (d == 0), e = zeros(1,v); return; end
        for c = d:-1:0
            ea = ghe_ref(v-1, d-c);
            e = [e; c*ones(size(ea,1),1) ea];
        end
    end

fprintf('1. Tabelas de expoentes e indexacao\n');
ok1 = true; ok2 = true;
for v = 1:6
    for d = 0:5
        A = ghe_ref(v,d);
        B = rolmipopt_exptable(v,d);
        ok1 = ok1 && isequal(A,B);
        if (v > 1 && d > 0)
            idx = rolmipopt_index(B);
            ok2 = ok2 && isequal(idx, (1:builtin('size',B,1))');
        end
    end
end
check('ordem identica ao ROLMIP original (v=1..6, d=0..5)', ok1);
check('indexacao combinatoria consistente', ok2);

[L,w] = rolmipopt_lifttable(4,2,3);
check('pesos multinomiais somam v^delta', sum(w) == 4^3);

fprintf('2. Operacoes validadas por avaliacao\n');
rand('state', 7);
n1 = nchoosek(3+2-1,2); n2 = 3;
P = rolmipvar(rand(4,4*n1), 'P', 3, 2);
Q = rolmipvar(rand(4,4*n2), 'Q', 3, 1);
al = {[0.2 0.3 0.5]};
vP = evalpar(P, al); vQ = evalpar(Q, al);
check('(P+Q)(a) = P(a)+Q(a)', norm(evalpar(P+Q,al) - (vP+vQ)) < tol);
check('(P-Q)(a) = P(a)-Q(a)', norm(evalpar(P-Q,al) - (vP-vQ)) < tol);
check('(P*Q)(a) = P(a)*Q(a)', norm(evalpar(P*Q,al) - vP*vQ) < tol);
check('transposta', norm(evalpar(P',al) - vP') < tol);
C = rand(4);
check('P*C constante', norm(evalpar(P*C,al) - vP*C) < tol);
check('P+C constante', norm(evalpar(P+C,al) - (vP+C)) < tol);

% multi-simplexo com simplexos distintos
ma{1} = {[1 0], -2}; ma{2} = {[0 1], 3};
a = rolmipvar(ma, 'a', 2, 1);
mb{1} = {[0], [1 0], -3}; mb{2} = {[0], [0 1], 2};
b = rolmipvar(mb, 'b', [0 2], [0 1]);
al2 = {[0.3 0.7], [0.6 0.4]};
va = -2*0.3 + 3*0.7; vb = -3*0.6 + 2*0.4;
check('a*b em simplexos distintos', abs(evalpar(a*b,al2) - va*vb) < tol);
check('a+b em simplexos distintos', abs(evalpar(a+b,al2) - (va+vb)) < tol);

fprintf('3. Polya, homogeneizacao, fork, concatenacao\n');
Pp = polya(P, 2);
check('Polya preserva o valor', norm(evalpar(Pp,al) - vP) < tol);
check('Polya eleva o grau (numero de monomios)', ...
      length(coefs(Pp)) == nchoosek(3+4-1,4));
Pl = polylift(P, 1, 3);
check('polylift preserva o valor', norm(evalpar(Pl,al) - vP) < tol);
Pf = fork(P, 'Pf', 1, 2);
alf = {[0.2 0.3 0.5],[0.5 0.4 0.1]};
check('fork avalia no novo simplexo', ...
      norm(evalpar(Pf, alf) - evalpar(P, {alf{2}})) < tol);
T = [P Q; Q' P];
VT = [vP vQ; vQ' vP];
check('concatenacao em bloco', norm(evalpar(T,al) - VT) < tol);

fprintf('4. Parametros com bounds\n');
clear MB;
A0 = rand(2); Ab1 = rand(2); Ab2 = rand(2); Ab3 = rand(2);
MB{1} = {[0 0], A0}; MB{2} = {[1 0], Ab1};
MB{3} = {[0 1], Ab2}; MB{4} = {[2 1], Ab3};
bounds = [-2 3; -4 8];
pB = rolmipvar(MB, 'Ab', bounds);
okb = true;
for k = 1:10
    p1 = -2 + 5*rand; p2 = -4 + 12*rand;
    direto = A0 + Ab1*p1 + Ab2*p2 + Ab3*p1^2*p2;
    okb = okb && (norm(evalpar(pB,[p1 p2]) - direto) < 1e-8);
end
check('A(p) com bounds = avaliacao direta (10 pontos)', okb);

fprintf('5. Derivada temporal\n');
clear MD;
D1 = rand(2); D2 = rand(2); D3 = rand(2);
MD{1} = {[2 0], D1}; MD{2} = {[1 1], D2}; MD{3} = {[0 2], D3};
pD = rolmipvar(MD, 'Ad', 2, 2);
db = [-0.5 0.5; -0.5 0.5];
dp = diff(pD, db);
% H: vertices do politopo das taxas
H = [0.5 -0.5; -0.5 0.5];
okd = true;
for k = 1:5
    aa = rand(1,2); aa = aa/sum(aa);
    bb = rand(1,2); bb = bb/sum(bb);
    dota = H*bb';
    grad1 = 2*aa(1)*D1 + aa(2)*D2;   % dP/da1
    grad2 = aa(1)*D2 + 2*aa(2)*D3;   % dP/da2
    ref = grad1*dota(1) + grad2*dota(2);
    okd = okd && (norm(evalpar(dp, {aa, bb}) - ref) < 1e-8);
end
check('diff = gradiente x taxas (5 pontos)', okd);

fprintf('6. LMIs com YALMIP (pulado se ausente)\n');
if (exist('sdpvar','file'))
    ws = warning('off','ROLMIPopt:strict');
    A1 = [-2 1; 0 -3]; A2 = [-1.5 0.2; 0.3 -2];
    Ai = rolmipvar([A1 A2], 'Ay', 2, 1);
    Pv = rolmipvar(2, 2, 'Py', 2, 1);
    LMIs = [Pv >= 0, (Ai'*Pv + Pv*Ai) <= 0];
    check('construcao de LMIs (>=, <=)', length(LMIs) == 5);
    LMIs2 = [Pv > 0];
    check('estrita convertida em nao estrita', length(LMIs2) == 2);
    Tb = [Pv Ai'*Pv; Pv*Ai Pv];
    LMIs3 = [Tb >= 0];
    check('LMI de bloco concatenado', length(LMIs3) == 3);
    warning(ws);
else
    fprintf('  [pulado] YALMIP nao encontrado no path\n');
end

fprintf('\n');
if (nfail == 0)
    fprintf('ROLMIPOPT_TEST: todos os testes passaram.\n');
else
    fprintf('ROLMIPOPT_TEST: %d teste(s) FALHARAM.\n', nfail);
end
end
