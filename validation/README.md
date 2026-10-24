# Testes e campanhas de validação

Para a suíte final que funciona com um checkout independente, consulte
[VALIDATION_3_4.md](../VALIDATION_3_4.md) e execute `run_release_tests` com
YALMIP e SeDuMi configurados. Os scripts de campanhas abaixo preservam o
layout e os caminhos do workspace de pesquisa; bases e resultados completos
não acompanham este repositório. Os geradores de relatórios também dependem
dos manifestos e certificados dessa campanha.

# Validação na base de sistemas

A campanha atual usa as bases regeneradas e quadraticamente estáveis. O relatório e as tabelas finais estão em `output/opt34-validation`; `previous_campaign.txt` aponta para a campanha anterior preservada. O arquivo `database_origin.json` registra a origem das bases novas. A cópia discreta antiga foi guardada no arquivo da campanha anterior antes de atualizar a cópia local.

Resultado da nova campanha: 417 resoluções aprovadas sem aviso, duas com resíduos aprovados e aviso numérico, uma resolução rejeitada nos resíduos. Para esta última, um certificado transferido do ensaio com taxa limitada passou na verificação do modelo congelado, dando limites numericamente aceitos para todos os 420 casos. O resultado suplementar não afirma otimalidade. Os 160 sistemas passaram na auditoria quadrática independente.

## Escopo

Leitura `BASE{n,N,i}.sys`, com `n=2:5`, `N=2:5` e `i=1:5`: 80 sistemas por domínio. São 105 condições por domínio/métrica H₂ ou H∞, totalizando 420: 320 com P comum, 64 com P afim congelado, 32 com variação limitada (dois vértices) e quatro com Pólya de ordem 1. Taxas contínuas 0,1 e 1; incrementos discretos 0,2 e 0,5.

H₂ contínuo usa variantes com D=0 somente em memória, autorizadas pelo usuário. Os custos não se aplicam aos sistemas originais com transmissão direta não nula. Para parâmetros variantes, o custo H₂ limita uniformemente a energia impulsiva somada pelos canais.

`audit_quadratic.m` verifica estabilidade quadrática independentemente do ROLMIP, por condições matriciais de Lyapunov nos vértices e inspeção dos autovalores. As matrizes dos certificados são salvas.

## Execução

Usar a raiz do workspace e processos MATLAB separados. O script contém caminhos locais para YALMIP, SeDuMi, MPT e cddmex; ajustá-los se transferir os ensaios. Foi utilizado MATLAB R2023b Update 5, YALMIP 20250626 e MPT com `mptopt('lpsolver','cdd')`.

```bash
matlab -batch "addpath('ROLMIP_opt_34/validation'); validate_database('reference',true);"
matlab -batch "addpath('ROLMIP_opt_34/validation'); validate_database('opt',true);"
matlab -batch "addpath('ROLMIP_opt_34/validation'); summarize_validation;"
# Preservar opt_results.json como initial_opt_results.json antes da repetição.
matlab -batch "addpath('ROLMIP_opt_34/validation'); validate_database('opt',true,1,Inf,true);"
matlab -batch "addpath('ROLMIP_opt_34/validation'); summarize_validation;"
matlab -batch "addpath('ROLMIP_opt_34/validation'); audit_quadratic;"
matlab -batch "addpath('ROLMIP_opt_34/validation'); check_transferred_certificate;"
python3 ROLMIP_opt_34/validation/report_validation.py
```

A repetição seleciona `solver_warning`, `feasible_solver_warning` e `numerical_check_failed`. Usa tolerância do SeDuMi 1e-7 e até 300 iterações, em lugar de 1e-8 e 150. Os critérios de aceitação permanecem iguais. A primeira tentativa de cada caso é preservada em `initial_warnings`.

O script retoma arquivos já existentes. **Ao mudar fontes, bases ou dependências, arquivar a campanha e começar uma pasta de resultados vazia**, com novo manifesto inicial de SHA-256. Não reutilizar resultados antigos. O gerador do relatório exige 420 casos, os certificados quadráticos, um manifesto de integridade e a referência à campanha anterior; não sobrescreve o manifesto.

## Resultados

- `relatorio/main.tex` e `relatorio/main.pdf`: relatório, equações, critérios e classificação final.
- `transferred_certificate.json` e `.mat`: certificado suplementar para o caso discreto n=4, N=2, i=1 com P afim congelado, reutilizando o certificado com incremento 0,2 e verificando todos os coeficientes e as matrizes físicas.
- `resultados.csv`: custo e origem desse certificado em colunas suplementares; custos principais apenas para soluções com resíduos aprovados. `feasible_solver_warning` não afirma convergência ao ótimo.
- `comparacao_campanhas.csv`: classificação anterior e atual por identificador. Os sistemas mudaram; não comparar custos como se isso medisse melhoria do parser.
- `reference_results.json`, `opt_results.json`: resumos completos. Valores brutos de soluções rejeitadas não são custos certificados.
- `reference/*.mat`: coeficientes afins e dimensões. A referência não é resolvida separadamente.
- `opt/*.mat`: resultados, vetor de decisão e coeficientes de P, quando retornados e avaliados.
- `quadratic_certificates.json`: certificados de estabilidade e resíduos independentes; `inventory.json`: inventário das bases.
- `input_source_manifest.json`, `integrity_check.json`: identificação dos fontes/bases e conferência de preservação durante a execução.
- `initial_warnings/*.mat`, `initial_opt_results.json`: primeira tentativa, antes da repetição.

A positividade dos coeficientes é uma condição suficiente e pode ser conservadora. As verificações são em ponto flutuante, sem aritmética intervalar. Os tempos registrados não constituem benchmark de aceleração.

## Comparação dos tempos de parser

A API `rolmip_begin` / `[time,V,L]=rolmip_end(LMIs)` foi incorporada ao trecho
de criação das variáveis e das restrições, antes da extração de coeficientes.
A referência usa uma cópia idêntica da API em `output/opt34-validation/timer_api`,
sem alteração nos fontes GitHub. O arquivo `validation_model.m` é compartilhado
pela validação e pelo benchmark para manter o trecho de construção idêntico.

Depois de gerar os resultados de referência e Opt, executar **sequencialmente**:

```bash
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_parser('reference');"
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_parser('opt');"
```

Cada versão faz duas construções de aquecimento e sete medições por caso.
O YALMIP é limpo antes de cada construção, fora do tempo medido. Os caches
ROLMIP são mantidos: mede-se execução aquecida. O solver não é chamado pelo
benchmark. A referência mantém seus opcodes; a Opt usa `codegen=off` (padrão).
As dimensões V/L são conferidas em todas as repetições e os coeficientes da
última construção são comparados integralmente à referência, fora da medição.

`timings_reference.json` e `timings_opt.json` contêm as sete amostras por caso;
`tempos_parser.csv` contém medianas, mínimos, máximos, V, L e razões de tempo.
`resultados.csv` também inclui as medianas de ambas as versões. O relatório
traz totais por domínio/métrica e um anexo com os 420 casos. Os totais são
somas das medianas por caso, e não duração da campanha. A máquina pode estar
executando outras tarefas; pequenas diferenças exigem cautela.

Para iniciar outra campanha em pasta vazia, recriar `timer_api` antes da
referência, copiando `rolmip_begin.m`, `rolmip_end.m` e a subpasta `private`
correspondente da versão Opt. A cópia deve ser idêntica à API usada na Opt.
Os caminhos de dependências e a preparação do manifesto também devem ser
conferidos. `timing_environment.json` registra as condições desta medição.
