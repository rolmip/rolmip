# ROLMIPopt — ROLMIP (Robust LMI Parser) otimizado

Versão otimizada do **ROLMIP** (Robust LMI Parser, de C. M. Agulhari,
A. Felipe, R. C. L. F. Oliveira e P. L. D. Peres) para MATLAB/Octave.

O ROLMIPopt é um **substituto direto (drop-in)** do ROLMIP: mesma API
(`rolmipvar`, `evalpar`, `polya`, `fork`, `insert_simplex`,
`construct_lmi_terms`, `diff`, operadores `+ - * ' [ ]`, `>` `>=` `<` `<=`
etc.), mesma estrutura interna de dados (`label`, `vertices`,
`data(n).exponent`, `data(n).value`, `opcode`, `bounds`) e resultados numericamente equivalentes nos ensaios descritos abaixo, com os
núcleos computacionais reescritos. A igualdade bit a bit não é garantida para
todos os modelos; os ensaios de graus maiores apresentaram diferenças de
arredondamento da ordem da precisão de máquina.

**Medições históricas da versão recebida, não repetidas nesta revisão** (MATLAB R2026a, menor de 3 medições amortizadas;
entre parênteses, GNU Octave 11, onde os ganhos são ainda maiores):

| operação                                  | speedup MATLAB (Octave) |
|-------------------------------------------|------------------------:|
| produto, 1 simplexo (v=4, grau 3 × 3)     |      32× (≈40×)         |
| produto, 1 simplexo (v=5, grau 2 × 2)     |      29× (≈33×)         |
| relaxação de Polya (grau 3)               |      24× (≈36×)         |
| produto multi-simplexo ([3 3], grau [1 1])|      18× (≈22×)         |
| soma com homogeneização (grau 1 + grau 5) |      13× (≈22×)         |
| derivada temporal (`diff`)                |      8,6× (≈7×)         |
| construtor multi-simplexo                 |      3,3× (≈1,4×)       |

## Instalação

1. Copie a pasta `rolmip` para o local desejado.
2. No MATLAB/Octave:

   ```matlab
   addpath('caminho/para/rolmip');
   ```

   **Importante:** não deixe o ROLMIP original no path ao mesmo tempo
   (ambos definem as mesmas funções).

3. Para resolver LMIs é necessário o [YALMIP](https://yalmip.github.io) e
   um solver SDP (SeDuMi, SDPT3, Mosek, ...), como no ROLMIP original.

4. Verificação da instalação (não requer YALMIP; a seção de LMIs é pulada
   se ele não estiver no path):

   ```matlab
   rolmipopt_test
   ```

5. Benchmark. Para comparar com o ROLMIP original use **duas sessões
   separadas** (o MATLAB mantém a classe `@rolmipvar` em cache — trocar o
   path na mesma sessão não é confiável):

   ```matlab
   % sessão 1, com o ROLMIP original no path:
   rolmipopt_benchmark('save', 'bench_original.mat')
   % sessão 2, com o ROLMIPopt no path:
   rolmipopt_benchmark('compare', 'bench_original.mat')
   ```

## Uso

Idêntico ao ROLMIP original — o manual do ROLMIP
(`manual_rolmip.pdf`) continua válido. Exemplos:

```matlab
% politopo de dados e variável de Lyapunov polinomial
A1 = [-2 1; 0 -3];  A2 = [-1.5 0.2; 0.3 -2];
Ai = rolmipvar([A1 A2], 'A', 2, 1);
P  = rolmipvar(2, 2, 'P', 2, 1);

LMIs = [P >= 1e-6*eye(2), (Ai'*P + P*Ai) <= 0];
optimize(LMIs, [], sdpsettings('solver','sedumi'));
Pnum = double(P);
evalpar(Pnum, {[0.5 0.5]})
```

Os exemplos do manual estão em `../docs/manual_examples/`.

## Diferenças de comportamento (todas documentadas)

* **Desigualdades estritas** (`>`/`<`): o YALMIP moderno as rejeita com
  erro (o ROLMIP original quebra). O ROLMIPopt as converte em não estritas
  (`>=`/`<=`) com um aviso — exatamente o comportamento efetivo do YALMIP
  antigo. Desative o aviso com `warning('off','ROLMIPopt:strict')`; para
  margem estrita use, por exemplo, `P >= 1e-6*eye(n)`.
* **`opcode`/LMIFILES**: por padrão (`rolmipopt('codegen','off')`) as
  strings simbólicas `opcode` não são construídas nos laços internos (é
  uma das principais fontes de lentidão do original). Elas só são usadas
  pelo gerador de arquivos `lmifiles`. Se você usa `lmifiles`, ative o
  modo de compatibilidade **antes** de criar as variáveis:

  ```matlab
  rolmipopt('codegen','on');   % executa os caminhos originais integrais
  ```
* **`diff` sem Mapping Toolbox**: a dependência de `roundn` (Mapping
  Toolbox) foi removida.
* **Octave**: a versão recebida relata testes no GNU Octave 10 e 11. As
  correções atuais ainda não foram revalidadas nesse ambiente.
* `size(poly,dim)` passou a funcionar (o original só aceitava
  `size(poly)`).

## Conteúdo do pacote

```
ROLMIPopt/
├── @rolmipvar/            classe (métodos otimizados + originais)
│   ├── operation_poly.m   núcleo de +,-,* (reescrito)
│   ├── polylift.m         homogeneização multinomial (novo)
│   ├── homogenize.m       homogeneização (reescrito)
│   ├── polya.m            relaxação de Polya (reescrito)
│   ├── construct_lmi_terms.m  montagem de LMIs (reescrito)
│   ├── insert_simplex.m   inserção direta de simplexos (reescrito)
│   ├── rolmipvar.m        construtor (indexação otimizada)
│   ├── diff.m             derivada temporal (indexação otimizada)
│   ├── *_codegen.m        caminhos originais p/ rolmipopt('codegen','on')
│   └── ...                demais métodos do ROLMIP (inalterados/guardados)
├── rolmipopt.m            opções (codegen on/off, clearcache)
├── rolmipopt_exptable.m   tabelas de expoentes memoizadas
├── rolmipopt_index.m      indexação combinatória O(v) (substitui gethash)
├── rolmipopt_prodtable.m  tabelas de índices de produto memoizadas
├── rolmipopt_lifttable.m  tabelas de homogeneização multinomial
├── rolmipopt_pascal.m     tabela de Pascal exata memoizada
├── generate_homogeneous_exponents.m  (memoizado, mesma ordem do original)
├── rolmipopt_test.m       autoteste (21 verificações)
├── rolmipopt_benchmark.m  benchmark
├── manual_examples/       exemplos do manual do ROLMIP
├── README_ROLMIPopt.md    este arquivo
├── MODIFICACOES.md        resumo detalhado das modificações
└── (demais arquivos do ROLMIP original, inalterados)
```

## Validação histórica da versão recebida

Os resultados desta seção foram fornecidos com a versão inicial Opt. Para a
revisão atual, validada no MATLAB R2023b, consulte [VALIDATION_3_4.md](../VALIDATION_3_4.md).

* Bateria com 25 resultados numéricos (construção, `+`, `-`, `*`,
  transposta, multi-simplexo, `polya`, `fork`, `insert_simplex`,
  concatenação, bounds, `diff`, `construct_lmi_terms`) comparados com o
  ROLMIP original **no MATLAB R2026a e no GNU Octave 11**: diferença
  máxima **0.0 (idênticos bit a bit)** em ambos.
* LMIs com variáveis de decisão (YALMIP): matrizes-base (`getbase`) das
  restrições geradas **idênticas bit a bit** às do original.
* Exemplo H∞ do manual (Algoritmo 1, Seção 6) resolvido com SeDuMi:
  γ = 2.842944 (grau 0) e γ = 1.053982 (grau 1) — valores confirmados de
  forma independente por outra implementação/solver.
* Autoteste (`rolmipopt_test`, 21 verificações) aprovado no MATLAB R2026a
  e no Octave 11.

## Créditos e licença

O ROLMIP original é de C. M. Agulhari, A. Felipe, R. C. L. F. Oliveira e
P. L. D. Peres ("Algorithm 998: The Robust LMI Parser", ACM TOMS, 2019).
O ROLMIPopt mantém a licença e os créditos do pacote original; as
otimizações estão descritas em `MODIFICACOES.md`.


## Correções de 17/10/2026

A etapa de correções descrita em `CORRECOES_3_4.md` incorpora os achados
F01--F06, H01--H02 e Q01 de `codeReviewOpt34.tex`. A indexação combinatória
foi preservada. Execute também:

```matlab
rolmipopt_regression_test
```

O teste lança erro se houver falha; a resolução de um arquivo exportado é
exercitada quando YALMIP e SeDuMi estão disponíveis. As etapas que dependem
de ferramentas ausentes são identificadas como `[skip]`.

A exportação agora rejeita expressões sem histórico simbólico disponível.
Ativar `codegen` depois de construir uma expressão no modo rápido não recupera
esse histórico: reconstrua a expressão com a opção ativada. A rejeição é feita
antes de gravar os termos. O modo de compatibilidade também converte
as desigualdades estritas em não estritas com aviso.

A validação local foi realizada no MATLAB R2023b Update 5; não constitui nova
certificação do Octave ou de todos os exemplos do manual. Os números históricos
de desempenho acima não foram medidos novamente para esta revisão.


## Memória e cache — etapa 2 (17/10/2026)

As tabelas de expoentes, produtos e pesos de homogeneização usam um cache
compartilhado com descarte das entradas menos recentemente utilizadas.
Os mapas de produto são construídos em blocos; produtos de polinômios também
processam os destinos em blocos e preservam a ordem anterior de acumulação.
Coeficientes numéricos nulos são excluídos do trabalho quando todos os
coeficientes numéricos são finitos; a grade pública de monômios é preservada.

```matlab
rolmipopt('cachebytes', 64*1024^2);  % padrão: 64 MiB de dados em cache
rolmipopt('workbytes',   8*1024^2);  % padrão: alvo de tamanho dos blocos
stats = rolmipopt('cachestats');
rolmipopt('clearcache');
rolmipopt_memory_test;
```

`cachebytes=0` desativa o armazenamento no cache compartilhado. Reduzir o
limite descarta entradas imediatamente. `workbytes` aceita pelo menos 1024
bytes. Esses parâmetros **não limitam a memória total do MATLAB**: as saídas,
os coeficientes, as tabelas de Pascal, metadados e temporários internos não
estão todos incluídos na contabilização. Pedir diretamente uma tabela completa
com `rolmipopt_prodtable` ainda aloca essa tabela; `polylift` também recebe um
mapa completo. O caminho de multiplicação evita mapas completos grandes.

Os resultados medidos e os limites estão em `MEMORIA_3_4.md`. A fórmula de
indexação e a representação pública foram mantidas. Não foram alterados os
núcleos legados usados com `codegen on` nesta etapa.

## Tempo de construção e tamanho das LMIs

```matlab
rolmip_begin;
% Defina as variáveis, manipule os polinômios e construa LMIs.
[time,V,L] = rolmip_end(LMIs);
% Chame optimize(...) somente depois de rolmip_end.
```

`time` é o tempo total decorrido, em segundos, entre os comandos, incluindo
código do usuário executado nesse intervalo. A medição termina antes da coleta
de estatísticas. Não é uma soma exclusiva do tempo interno das funções ROLMIP.

`V = numel(getvariables(LMIs))` conta as variáveis escalares distintas usadas
nas restrições finais, incluindo as criadas antes de `rolmip_begin`; exclui as
não utilizadas ou presentes apenas no objetivo. Não há argumento de objetivo.
`L = sum(info.sdp(:,1))`, com `info = lmiinfo(LMIs)`, soma apenas as ordens dos
blocos semidefinidos reconhecidos pelo YALMIP. Desigualdades escalares e
igualdades não entram em `L`. Um conjunto vazio retorna `V=L=0`.

O timer usa um identificador próprio, portanto outros `tic`/`toc` não o
reiniciam. Uma nova chamada a `rolmip_begin` reinicia a medição. As sessões não
são aninhadas. `rolmip_end` consome a medição e exige um novo `rolmip_begin`
antes de outra chamada, inclusive se a inspeção das restrições falhar.
Nenhum dos comandos limpa caches ou variáveis do YALMIP. Estatísticas só são
calculadas quando suas saídas são solicitadas.
