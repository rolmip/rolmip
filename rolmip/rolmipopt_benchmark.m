function rolmipopt_benchmark(modo, arquivo)
% ROLMIPOPT_BENCHMARK  Benchmark do ROLMIP/ROLMIPopt.
%
%   rolmipopt_benchmark                    mede e imprime os tempos das
%                                          operacoes tipicas com o parser
%                                          que estiver no path.
%   rolmipopt_benchmark('save', ARquivo)   mede e salva os tempos em
%                                          ARquivo (.mat).
%   rolmipopt_benchmark('compare', ARquivo) mede com o parser atual e
%                                          compara com os tempos salvos.
%
%   Para comparar o ROLMIPopt com o ROLMIP original, use DUAS sessoes
%   distintas do MATLAB/Octave (o MATLAB mantem a classe @rolmipvar em
%   cache; trocar o path na mesma sessao nao e confiavel):
%
%     % sessao 1 (ROLMIP original no path):
%     rolmipopt_benchmark('save', 'bench_original.mat')
%     % sessao 2 (ROLMIPopt no path):
%     rolmipopt_benchmark('compare', 'bench_original.mat')
%
%   Operacoes medidas (menor de 3 medicoes; operacoes rapidas repetidas
%   dentro do cronometro): produto (v=4, grau 3x3; v=5, grau 2x2; e
%   multi-simplexo), Polya, soma com homogeneizacao, construtor
%   multi-simplexo e derivada temporal.

if (nargin == 0)
    modo = 'print';
end

T = local_run();
nomes = fieldnames(T);

switch lower(modo)
    case 'print'
        fprintf('\n%-22s %12s\n', 'operacao', 'tempo(s)');
        for k = 1:length(nomes)
            fprintf('%-22s %12.4f\n', nomes{k}, T.(nomes{k}));
        end
    case 'save'
        save(arquivo, '-struct', 'T');
        fprintf('Tempos salvos em %s\n', arquivo);
    case 'compare'
        R = load(arquivo);
        fprintf('\n%-22s %12s %12s %10s\n', 'operacao', 'referencia(s)', ...
                'atual(s)', 'speedup');
        for k = 1:length(nomes)
            a = R.(nomes{k});
            b = T.(nomes{k});
            fprintf('%-22s %12.4f %12.4f %9.1fx\n', nomes{k}, a, b, a/b);
        end
    otherwise
        error('Modo invalido. Use ''save'' ou ''compare''.');
end
end

function T = local_run
rand('state', 42);

n1 = nchoosek(4+3-1,3);
p1 = rolmipvar(rand(8,8*n1),'P',4,3);
p2 = rolmipvar(rand(8,8*n1),'Q',4,3);
T.prod_v4_d3d3 = local_bestof(@() p1*p2, 3);

n2 = nchoosek(5+2-1,2);
p3 = rolmipvar(rand(4,4*n2),'P',5,2);
p4 = rolmipvar(rand(4,4*n2),'Q',5,2);
T.prod_v5_d2d2 = local_bestof(@() p3*p4, 5);

n3 = nchoosek(4+2-1,2);
p5 = rolmipvar(rand(4,4*n3),'P',4,2);
T.polya_v4_d2_r3 = local_bestof(@() polya(p5,3), 10);

n4b = nchoosek(4+5-1,5);
p6 = rolmipvar(rand(4,4*4),'A',4,1);
p7 = rolmipvar(rand(4,4*n4b),'B',4,5);
T.soma_homog_d1_d5 = local_bestof(@() p6+p7, 10);

e2 = generate_homogeneous_exponents(3,2);
M = cell(1, size(e2,1)^2);
cont = 0;
for i=1:size(e2,1)
    for j=1:size(e2,1)
        cont = cont+1;
        M{cont} = {e2(i,:), e2(j,:), rand(3)};
    end
end
T.construtor_ms = local_bestof(@() rolmipvar(M,'X',[3 3],[2 2]), 20);

n6 = nchoosek(3+2-1,2);
p8 = rolmipvar(rand(3,3*n6),'D',3,2);
db = [-.5 .5; -.5 .5; -.5 .5];
T.diff_v3_d2 = local_bestof(@() diff(p8,db), 10);

MA = cell(1,9); MB = cell(1,9);
cont = 0;
for i=1:3
    for j=1:3
        cont = cont+1;
        ei = zeros(1,3); ei(i)=1;
        ej = zeros(1,3); ej(j)=1;
        MA{cont} = {ei, ej, rand(4)};
        MB{cont} = {ei, ej, rand(4)};
    end
end
pa = rolmipvar(MA,'A',[3 3],[1 1]);
pb = rolmipvar(MB,'B',[3 3],[1 1]);
T.prod_ms_33 = local_bestof(@() pa*pb, 10);
end

function t = local_bestof(f, reps)
% menor de 3 medicoes; repeticoes dentro do cronometro para operacoes
% rapidas ficarem acima da resolucao do tic/toc
if (nargin < 2)
    reps = 1;
end
f();   % aquecimento (caches/JIT)
t = inf;
for k = 1:3
    t0 = tic;
    for r = 1:reps
        f();
    end
    t = min(t, toc(t0)/reps);
end
end
