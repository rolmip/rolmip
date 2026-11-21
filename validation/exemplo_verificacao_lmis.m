function resultados = exemplo_verificacao_lmis(nome_solver)
%EXEMPLO_VERIFICACAO_LMIS Exemplo para testar rolmip_verify(LMIs).
%
% Uso (com ROLMIP e YALMIP no path, em uma sessao sem outro modelo ativo):
%   resultados = exemplo_verificacao_lmis;          % SeDuMi
%   resultados = exemplo_verificacao_lmis('sdpt3'); % outro solver instalado
%
% Este exemplo limpa o estado do YALMIP. Nao usa rolmip_lmi nem exige
% rolmip_check_begin. Verifica todas as restricoes do objeto LMIs.
if nargin==0,nome_solver='sedumi';end
assert(~isempty(which('sdpvar')),'Inclua o YALMIP no path antes de executar.');
assert(~isempty(which('rolmip_verify')),'Inclua a pasta rolmip desta versao no path.');
yalmip('clear');

%% 1. Sistema continuo com dois vertices
A1 = [-2 0.2; 0 -1];
A2 = [-1 0; 0.2 -3];
A = rolmipvar({A1,A2},'A',2,1);
P = rolmipvar(2,2,'P','sym',2,1);
epsilon = 1e-5;

% P depende dos parametros: a condicao abaixo e para parametros congelados.
% Nao inclui a derivada de P e nao certifica variacao arbitraria no tempo.
LMIs = [P >= epsilon*eye(2), A'*P + P*A <= -epsilon*eye(2)];

% Acrescentamos restricoes YALMIP diretas para testar tambem esses tipos.
z = sdpvar(1);
LMIs = [LMIs, z >= 0, z == 1];

%% 2. Resolver e verificar TODO o objeto LMIs
opcoes = sdpsettings('solver',nome_solver,'verbose',0);
solucao = optimize(LMIs,[],opcoes);
verificacao = rolmip_verify(LMIs,'solver',solucao);
resultados.solucao = solucao;
resultados.aprovado = verificacao;

fprintf('\n=== Solucao calculada pelo solver ===\n');
fprintf('Solver: %s (codigo %d)\n',solucao.info,solucao.problem);
mostrar(verificacao);
if ~verificacao.constraints_passed
    warning('Exemplo:SolucaoNaoAprovada', ...
        'Inspecione resultados.aprovado. A demonstracao de alteracao foi omitida.');
    return
end

%% 3. Demonstracao controlada de reprovacao
% Alteramos SOMENTE a atribuicao de z, sem mudar as restricoes ou resolver
% novamente. z=-1 viola z>=0 e z==1. Isso nao e uma falha do solver.
z_original = value(z);
restaurar = onCleanup(@() assign(z,z_original));
assign(z,-1);
verificacao_ruim = rolmip_verify(LMIs); % sem associar a antiga saida do solver
resultados.alterado = verificacao_ruim;

fprintf('\n=== Atribuicao alterada manualmente: z = -1 ===\n');
mostrar(verificacao_ruim);
fprintf('Indices das restricoes reprovadas: ');
disp(verificacao_ruim.violated_indices);

% O registro completo de uma restricao fica em:
% resultados.alterado.constraints(indice)
% O pior residuo RELATIVO entre as restricoes avaliadas fica em:
% resultados.alterado.worst

%% 4. Restaurar a solucao original
clear restaurar; % executa assign(z,z_original)
resultados.restaurado = rolmip_verify(LMIs,'solver',solucao);
fprintf('\nSolucao original restaurada: %s\n',resultados.restaurado.status);
end

function mostrar(r)
fprintf('Estado: %s\n',r.status);
fprintf('Todas as restricoes aprovadas: %d\n',r.constraints_passed);
c=r.constraints;
if isempty(c),return;end
resumo=table([c.index].',{c.kind}.',[c.residual].',-[c.tolerance].', ...
    [c.passed].',{c.status}.','VariableNames', ...
    {'Indice','Tipo','Residuo','LimiteInferior','Aprovada','Estado'});
disp(resumo);
% O residuo deve ser >= LimiteInferior; SDP tambem exige simetria numerica.
if ~isempty(r.unevaluable_indices)
    fprintf('Indices sem verificacao completa: ');disp(r.unevaluable_indices);
end
end
