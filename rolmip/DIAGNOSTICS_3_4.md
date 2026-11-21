# Diagnóstico, rastreabilidade e verificação de certificados

As APIs são opcionais. Os operadores existentes (`>=`, `<=`, etc.) executam
checagens automáticas somente durante uma sessão ativada explicitamente.
A construção matemática das restrições permanece a mesma.
Esta primeira versão trabalha com LMIs reais simétricas e coeficientes
numéricos ou afins em variáveis de decisão YALMIP.

## 1. Diagnóstico: `rolmip_check`

```matlab
r = rolmip_check(P);             % expressão intermediária geral
r = rolmip_check(P,'lmi',true);  % expressão destinada a uma LMI
r.issues
```

O diagnóstico verifica vértices, vetores de expoentes, homogeneidade por
simplexo, monômios duplicados, dimensões dos coeficientes e do campo `dims`,
NaN/Inf, simetria, valores reais e dependência afim nas decisões.
`issues` registra severidade, código, índice do coeficiente e do simplexo;
índice zero indica um problema global. Não altera nem corrige a expressão.
Aceita também `struct(P)` para inspecionar dados malformados.

- `valid`: não há erros no modo solicitado.
- `lmi_ready`: a representação é válida e todos os coeficientes são reais,
  estruturalmente simétricos e afins nas decisões.
- `degree`, `vertices`, `dimensions`, `stored_monomials`, `expected_monomials`:
  propriedades da expressão; a contagem esperada corresponde à grade completa.
- `coefficients`: diagnóstico individual e IDs de variáveis por coeficiente.

Uma matriz retangular é uma expressão intermediária válida, mas não uma LMI.
Por isso, simetria e afinidade geram avisos no modo geral e erros no modo LMI.
Um polinômio quadrático nos parâmetros incertos pode perfeitamente gerar LMIs;
um produto entre variáveis de decisão deixa de ser afim. Operadores estendidos
YALMIP (como `abs(x)`) são rejeitados nesta API mesmo quando admitem outra
reformulação convexa: aqui se exige uma matriz afim explícita.

Simetria estrutural é verificada sem usar valores atribuídos às decisões e sem
tolerância. Não há simetrização silenciosa. Complexos/Hermitianos não são
suportados como LMIs nesta primeira versão. Ausência de monômios gera aviso;
monômios ausentes são tratados como suporte nulo nas APIs seguintes.

## 2. Construção rastreável: `rolmip_lmi`

```matlab
% P deve representar a expressão completa do lado esquerdo contra zero.
[F,origem] = rolmip_lmi(P,'>=','Estabilidade');
```

São aceitas apenas `>=` e `<=`. Para `P >= Q`, construir primeiro `P-Q`;
para uma margem, construir `P-epsilon*eye(n)`. Aplicar `polya` previamente se
necessário. Uma chamada corresponde a uma condição polinomial completa.
Não é uma nova linguagem de montagem de blocos nem substitui `lmifiles`.

Cada entrada de `origem.entries` contém:

| Campo | Conteúdo |
| --- | --- |
| `monomial` | Índice do coeficiente na expressão final |
| `exponents` | Uma linha de expoentes por simplexo |
| `order` | Ordem da matriz do coeficiente |
| `coefficient` | Expressão assinada que deve ser positiva semidefinida |
| `constraint_index` | Índice **local ao F retornado**, ou vazio para constantes |
| `kind` | Classificação efetiva: `sdp`, `elementwise` ou `constant_psd` |
| `tag` | Nome da condição, monômio e expoentes, também aplicado no YALMIP |

Para `<=`, o coeficiente armazenado é o negativo do coeficiente de P. O
certificado é sempre verificado como positividade. Use nomes distintos para
condições distintas. Ao concatenar ou reordenar restrições, os índices locais
não são atualizados; as tags e as expressões retidas continuam identificando
as condições. Não são índices da representação interna do solver.

`origem.V` e `origem.L` seguem as definições da API de medição para **esse F**.
V não deve ser somado entre origens que compartilham decisões. Matrizes
diagonais podem ser convertidas pelo YALMIP em desigualdades elemento a
elemento; nesses casos não contribuem para L, mesmo tendo ordem maior que um.

Coeficientes puramente numéricos são verificados por autovalores, não por
comparação elemento a elemento. Constantes PSD não adicionam restrições, mas
permanecem na origem. Constantes com autovalor negativo são rejeitadas: nessa
etapa não há tolerância de aceitação, portanto casos numericamente limítrofes
podem precisar de inspeção. Um bloco constante negativo impossibilita este
certificado por coeficientes; não prova que a expressão seja negativa em todo
o domínio. Todos os coeficientes são diagnosticados antes da construção.

A origem descreve os monômios da expressão final passada à função. Não recupera
um histórico completo das operações nem os blocos originais de uma expressão
já expandida. Não é possível acrescentar essa informação retroativamente a
um conjunto arbitrário de LMIs. As expressões simbólicas são da sessão atual:
**não reutilizar a origem após `yalmip('clear')` ou em outra sessão**.

## 3. Verificação: `rolmip_verify`

```matlab
diagnostics = optimize(F,[],sdpsettings('solver','sedumi'));
r = rolmip_verify(origem,'solver',diagnostics);

% Para um simplexo de dois vértices, amostras opcionais:
pontos = {{[1 0]}, {[0 1]}, {[.5 .5]}};
r = rolmip_verify(origem,'solver',diagnostics,'points',pontos, ...
                  'abs_tol',1e-8,'rel_tol',1e-8);
r.status
r.worst
```

A função lê os valores correntes do YALMIP, após `optimize` ou `assign`.
Não resolve novamente nem altera atribuições. `solver` é opcional e serve
para registrar o diagnóstico, nunca para substituir a inspeção das matrizes.

Para cada coeficiente assinado A:

- Escala: `max(1,norm(A,2))`.
- Tolerância: `abs_tol + rel_tol*escala` (padrões: 1e-8 e 1e-8).
- Erro de simetria: `norm(A-A.','fro')`, limitado pela mesma tolerância.
- Resíduo: menor autovalor da parte simétrica de A; deve ser pelo menos
  `-tolerancia`. A parte simétrica só é aceita se o erro de simetria passar.
- São reportados resíduo absoluto, resíduo relativo, erro de simetria,
  escala, tolerância e identificação de origem.

`worst` é o coeficiente com menor resíduo relativo; fica vazio quando alguma
matriz não pode ser avaliada. Valores não atribuídos, NaN/Inf ou falhas de
representação numérica impedem aprovação. `optimality_checked` é sempre falso.

| `status` | Significado |
| --- | --- |
| `certificate_passed` | Todos os coeficientes passaram numericamente; solver ausente ou sem aviso |
| `certificate_passed_solver_warning` | Coeficientes passaram, mas o código do solver é diferente de zero |
| `certificate_failed` | Pelo menos um coeficiente finito reprovou |
| `not_evaluable` | Há coeficientes sem valor utilizável ou falha numérica |
| `sample_check_failed` | Coeficientes passaram nas tolerâncias, mas alguma amostra reprovou |

`certificate_passed` refere-se somente à verificação dos coeficientes;
`samples_passed` é separado e fica vazio quando não há amostras. `solver`
retém o código e o texto originais, inclusive quando os resíduos passam.
Nenhuma dessas situações afirma convergência ao ótimo.

Cada amostra é uma célula com uma linha baricêntrica por simplexo. Exemplo
para dois simplexos: `{{[.3 .7],[.2 .3 .5]}}`. Para simplexo ausente, usar `1`.
As coordenadas devem ser finitas, não negativas e somar um (erro até 1e-10).
Amostras não são geradas automaticamente e não substituem o certificado.

PSD de todos os coeficientes é condição suficiente sobre o produto dos
simplexos unitários, pois os monômios são não negativos. A aprovação é numérica,
com tolerâncias, sem aritmética intervalar. A reprovação dessa condição
suficiente não prova inviabilidade do problema original. Não são verificadas
restrições adicionais que não estejam representadas nesta origem.

## Exemplo completo e testes

Com YALMIP e SeDuMi no path, a partir da raiz do repositório:

```matlab
addpath('rolmip');
addpath('validation');
results = example_model_diagnostics;
test_model_diagnostics;
```

O exemplo resolve estabilidade para parâmetros congelados em um sistema com
dois vértices, verifica positividade de P e a condição de Lyapunov, e mostra
o coeficiente com pior resíduo. Não é um teste de variação arbitrária dos
parâmetros. O teste novo também integra `run_release_tests`.

Validação local: MATLAB R2023b, YALMIP 20250626 e SeDuMi. Foram exercitados
entradas inválidas, decisões não afins, os dois modos de codegen, igualdade
com os operadores existentes, tags, múltiplos simplexos, constantes,
desigualdades escalares, falta de valores, reprovação de coeficientes com
amostragem favorável, avisos do solver e um SDP efetivamente resolvido.
A suíte de regressão e as 4.277 verificações de robustez também passaram.

## 4. Diagnóstico geral por sessão

O diagnóstico individual permanece disponível. Para coletar problemas durante
um trecho inteiro do programa:

```matlab
rolmip_check_begin;

% Definir variáveis e construir as condições com ROLMIP.
LMIs = [P >= epsilon*eye(n), A'*P + P*A <= 0];

parcial = rolmip_check_report;  % consulta sem encerrar nem apagar
relatorio = rolmip_check_end;  % encerra e preserva o relatório

if relatorio.has_errors
    disp(relatorio.issues);
else
    solucao = optimize(LMIs,objetivo,opcoes);
end
```

`begin` reinicia o registro; se já houver uma sessão ativa, emite
`ROLMIP:CheckRestarted` antes de descartar o relatório anterior. Não há sessões
aninhadas. `end` exige uma sessão ativa. `report` funciona durante a sessão e
após seu encerramento, até o próximo `begin`; nunca reinicia a coleta.
As funções não limpam variáveis YALMIP nem caches ROLMIP.

### O que é coletado

- Desigualdades `>=`, `<=`, `>` e `<` com objetos ROLMIP.
- Construção de desigualdades por `construct_lmi_terms`, seus caminhos de
  compatibilidade e chamadas de `construct_lmi` que chegam a eles.
- Chamadas a `rolmip_lmi`, aproveitando o diagnóstico já calculado.
- Falhas de construção nesses caminhos são registradas quando interceptadas,
  e a exceção original é relançada. O modo de coleta nunca descarta uma
  restrição inválida silenciosamente para continuar a execução.

A comparação é inspecionada como residual entre os lados homogeneizados;
nos blocos, inspeciona-se a matriz final já montada. Assim, blocos retangulares
intermediários são permitidos quando a LMI final é simétrica. Desigualdades
estritas produzem um aviso agrupado, sem duplicar a condição por passarem
internamente pelo operador não estrito.

A checagem individual `rolmip_check(P)` não adiciona uma condição ao registro.
Construções auxiliares com `construct_lmi_terms(...,'Term')` também não contam.

### Campos do relatório

- `active`, `elapsed_seconds`: estado e tempo de parede da sessão, incluindo
  o código do usuário; não é tempo exclusivo das checagens.
- `condition_count`: número de condições observadas, não número de blocos SDP.
- `has_errors`, `has_warnings`, `error_groups`, `warning_groups`: resumo.
- `conditions`: ID local da condição, nome, relação, número de monômios,
  vértices, graus, dimensões, origem e indicação de falha de construção.
- `issues`: severidade, código, mensagem, `condition_id` e `locations`.
  Cada linha de `locations` é `[coeficiente, simplexo]`; zero significa global.

Problemas com o mesmo código e severidade são agrupados dentro da condição.
Não há agrupamento entre chamadas diferentes: duas condições construídas na
mesma linha continuam distintas. As advertências originais do MATLAB/YALMIP
não são suprimidas; o agrupamento é do relatório, não da saída do console.

Para localizar um problema:

```matlab
item = relatorio.issues(1);
origem = relatorio.conditions(item.condition_id);
disp(origem.name);
disp(origem.source); % file, line, function
disp(item.locations);
```

A origem é a primeira chamada fora das funções internas instrumentadas.
Quando a construção ocorre na janela de comandos, o arquivo fica vazio e a
linha é zero. Os dados retidos são metadados e localizações, não coeficientes
simbólicos completos. Para reavaliar certificados, continue usando a origem
de `rolmip_lmi` e `rolmip_verify`.

### Limites e comportamento após erros

O registro inclui tentativas de construção, mesmo que suas restrições sejam
posteriormente descartadas, substituídas ou não adicionadas a `LMIs`. Não é
uma análise do conjunto final nem uma inspeção estática do arquivo MATLAB.
Restrições criadas diretamente com YALMIP, igualdades `==` e falhas durante
operações anteriores à construção da desigualdade não estão cobertas nesta
versão. Uma chamada com assinatura inválida pode falhar antes de ser coletada.
Linhas não executadas após uma exceção não podem ser diagnosticadas.

Depois de uma exceção, a sessão continua ativa; use `rolmip_check_report` para
consultá-la ou `rolmip_check_end` para encerrá-la. Uma falha interna da própria
inspeção gera `DiagnosticFailure`, sem substituir a matemática original.
`has_errors=false` significa apenas ausência de erros nas condições cobertas,
não garantia de viabilidade nem de correção de todo o programa.

O modo geral apenas registra: não converte BMIs em LMIs, não simetriza matrizes
nem intercepta `optimize`. Os operadores antigos mantêm seu comportamento,
inclusive a eventual aceitação de desigualdades elemento a elemento para
matrizes não simétricas; o relatório aponta esse uso como erro de intenção LMI.
A API explícita `rolmip_lmi` continua rejeitando expressões inadequadas, como
antes. A decisão de chamar o solver permanece com o usuário.

Desativado, o modo não executa inspeção dos coeficientes; há apenas a consulta
ao estado e os pontos de interceptação. Ativado, há custo adicional de análise
e captura da pilha. Esse custo entra no tempo de `rolmip_begin`/`rolmip_end`
quando ambas as sessões se sobrepõem. Não compare esses tempos com benchmarks
feitos sem diagnóstico como se as configurações fossem iguais.

`validation/example_check_session.m` contém um exemplo completo com dois
vértices. `test_check_session` foi incorporado a `run_release_tests`, cobrindo
consulta parcial, agrupamento, arquivo/linha, exceções preservadas, reset,
compatibilidade codegen e igualdade dos modelos com a coleta ligada/desligada.

## 5. Verificação direta do conjunto completo `LMIs`

Não é necessário usar `rolmip_lmi` nem ativar a coleta para verificar o objeto
final de restrições. A mesma função aceita os dois tipos de entrada:

```matlab
solucao = optimize(LMIs,objetivo,opcoes);
r = rolmip_verify(LMIs,'solver',solucao);

r.status
r.violated_indices
r.unevaluable_indices
r.worst
```

A interface anterior `rolmip_verify(origem,...)` continua disponível para um
certificado polinomial identificado. Com `LMIs`, são inspecionadas as restrições
presentes no conjunto passado, incluindo aquelas construídas diretamente no
YALMIP. A classificação efetiva do YALMIP é respeitada:

| Tipo | Resíduo absoluto | Escala |
| --- | --- | --- |
| SDP real | Menor autovalor da parte simétrica da matriz | `max(1,norm(A,2))` |
| Desigualdade elemento a elemento | Menor componente da expressão normalizada como `A>=0` | `max(1,max(abs(A(:))))` |
| Igualdade | Negativo do maior valor absoluto da expressão normalizada como `A==0` | `max(1,max(abs(A(:))))` |

O resíduo deve ser pelo menos `-(abs_tol + rel_tol*escala)`, com padrões 1e-8
e 1e-8. Em SDP, o erro de simetria de Frobenius também deve respeitar essa
tolerância. A escala é da expressão residual avaliada, não uma análise de
condicionamento dos dados originais. As tolerâncias são configuráveis:

```matlab
r = rolmip_verify(LMIs,'solver',solucao,'abs_tol',1e-7,'rel_tol',1e-8);
```

O relatório contém:

- `mode='constraints'`, `constraint_count`: número de restrições/blocos YALMIP,
  não número de variáveis ou de linhas SDP.
- `constraints_passed`: verdadeiro somente para um conjunto não vazio em que
  todas as restrições foram suportadas, avaliadas e aprovadas.
- `all_evaluable`: todas as restrições do conjunto não vazio foram avaliadas.
- `constraints`: registros com `index`, `tag`, `kind`, `dimensions`, `order`
  (para SDP), resíduos absoluto/relativo, tolerância, escala e estado.
- `violated_indices`: restrições avaliadas que reprovaram.
- `unevaluable_indices`: inclui valores ausentes/não finitos, tipos não
  suportados e falhas de avaliação; não são tratados como aprovados.
- `unsupported_indices`: subconjunto de tipos não suportados.
- `worst`: pior resíduo relativo **entre as restrições avaliadas**; pode existir
  mesmo quando outras não puderam ser avaliadas. O campo `index` localiza a
  restrição no conjunto recebido; `tag` preserva o nome quando disponível.
- `worst_element`: em cada registro escalar/vetorial, posição `[linha,coluna]`
  na expressão extraída do YALMIP. Essa expressão pode estar vetorizada pelo
  YALMIP e não ter o formato escrito originalmente pelo usuário.

Os índices referem-se ao objeto `LMIs` recebido, na ordem atual. Blocos
vetoriais de desigualdades escalares podem ocupar um único índice. Uma matriz
não simétrica classificada pelo YALMIP como elemento a elemento é verificada
nessa interpretação: para detectar se isso contrariou a intenção de formular
uma LMI, use também o diagnóstico durante a construção.

Estados do modo direto:

| `status` | Significado |
| --- | --- |
| `constraints_passed` | Todas as restrições passaram numericamente |
| `constraints_passed_solver_warning` | Todas passaram, mas o solver retornou código diferente de zero |
| `constraints_failed` | Todas foram avaliadas e pelo menos uma reprovou |
| `not_evaluable` | Alguma restrição não pôde ser avaliada |
| `unsupported_constraints` | Há tipos de restrição não suportados |
| `empty_set` | Conjunto vazio; não se afirma aprovação |

Quando há problemas de tipos diferentes, as listas de índices preservam todos
os resultados. Tipos não suportados têm prioridade no estado geral; depois,
valores não avaliáveis; por último, violações numéricas. Assim, não se perde
uma violação conhecida só porque outra restrição ficou sem valor.

O diagnóstico do solver é informativo, separado da checagem dos valores
correntes. Código zero não sobrepõe resíduos ruins. Código não zero não apaga
resíduos aprovados, mas permanece como aviso. A função não altera atribuições,
não resolve o modelo e não verifica otimalidade, dualidade, objetivo ou
integralidade de variáveis. Restrições cônicas de outros tipos e matrizes
complexas são explicitamente marcadas como não suportadas nesta versão.
Objetos lógicos/números não vazios não são aceitos como substitutos de `LMIs`.

**Pontos dos parâmetros ainda exigem `origem`.** Passar `points` não vazio com
um objeto `LMIs` gera `ROLMIP:PointsNeedOrigin`, pois o conjunto não retém
expoentes e agrupamentos polinomiais. Não será adicionado um registro opcional
de expressões a `rolmip_check_begin`. Para investigar uma desigualdade em
pontos dos simplexos, use a origem retornada por `rolmip_lmi`.

Exemplo executável: `validation/example_verify_constraints.m`, com condições
ROLMIP de Lyapunov, desigualdade escalar e igualdade YALMIP. O teste
`test_verify_constraints` compara resíduos com `check(LMIs)` e também cobre
falhas, valores não atribuídos/NaN/Inf, tolerâncias, tags, conjuntos vazios,
cones não suportados, SDP complexo, compatibilidade com `origem` e um problema
resolvido com SeDuMi. Integra `run_release_tests`.
