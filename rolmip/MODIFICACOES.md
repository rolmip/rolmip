# ROLMIPopt — Resumo detalhado das modificações

Este documento lista todas as modificações feitas sobre o ROLMIP original
(versão distribuída com o manual, arquivos de 2012–2021) e o porquê de
cada uma. Nenhuma modificação altera a semântica: a bateria de validação
produz resultados **idênticos bit a bit** aos do original (dados
numéricos) e matrizes-base de LMIs (`getbase` do YALMIP) **idênticas bit a
bit** (variáveis de decisão).

## 1. Gargalos do original que motivaram as mudanças

1. **`gethash` (busca linear)** — em `operation_poly.m`, `rolmipvar.m` e
   `diff.m`, cada consulta de monômio varria a tabela inteira de expoentes
   com `find`/`histc`/`repmat`: custo O(m·v) por consulta, dentro do laço
   O(m₁·m₂) do produto.
2. **`generate_homogeneous_exponents` recursiva, sem memoização** —
   reconstruída a cada operação, crescendo a matriz por concatenação.
3. **Strings `opcode`** — mais da metade de `operation_poly.m` era
   `strcat` aninhado dentro dos laços internos; strings crescem
   multiplicativamente a cada produto e só servem ao `lmifiles`.
4. **Homogeneização por produtos repetidos pelo polinômio "1"**
   (`homogenize.m`, `construct_lmi_terms.m`, `polya.m`): elevar δ graus
   custava δ produtos polinomiais completos.
5. **Reconstrução completa de objetos** em `insert_simplex.m` (desmontar
   em cell e reconstruir pelo construtor, revalidando e re-hasheando).
6. **`calccoefs` com fatoriais** em `double` e ramificações ad hoc.
7. **Montagem incremental das LMIs** (`T = [T; Taux]` elemento a
   elemento) em `construct_lmi_terms.m`.
8. **Incompatibilidades com ferramentas atuais**: `roundn` (Mapping
   Toolbox) em `diff.m`; desigualdades estritas (`T>0`) rejeitadas com
   erro pelo YALMIP moderno; `isstr` (removido no Octave 10, deprecado no
   MATLAB); `set()` (API antiga do YALMIP).

## 2. Arquivos novos

| arquivo | função |
|---|---|
| `rolmipopt.m` | opções globais: `codegen` on/off (padrão **off**) e `clearcache`. |
| `rolmipopt_pascal.m` | tabela de Pascal memoizada — binômios **inteiros exatos** por recorrência aditiva (sem fatoriais). |
| `rolmipopt_exptable.m` | tabelas de expoentes memoizadas, geração **iterativa prealocada**, ordem idêntica ao original. |
| `rolmipopt_index.m` | posição de um expoente na ordem canônica em **O(v) por linha, vetorizado** (fórmula fechada "hockey stick") — substitui o `gethash`. |
| `rolmipopt_prodtable.m` | tabela memoizada (m₁×m₂) com o índice do produto de cada par de monômios: a indexação do produto vira consulta vetorizada. |
| `rolmipopt_lifttable.m` | tabela memoizada de homogeneização + pesos multinomiais inteiros exatos. |
| `@rolmipvar/polylift.m` | multiplicação por (Σαⱼ)^δ = 1 em **uma única passada** multinomial (novo método). |
| `rolmipopt_test.m` | autoteste com 22 verificações (não requer o original nem YALMIP; seção de LMIs opcional). |
| `rolmipopt_benchmark.m` | benchmark, com modos `'save'`/`'compare'` para comparação contra o ROLMIP original em sessões separadas. |

## 3. Arquivos reescritos (mesma interface e semântica)

* **`@rolmipvar/operation_poly.m`** — núcleo de `+`, `-`, `*`:
  - índices de todos os pares calculados de uma vez por tabelas
    memoizadas (`rolmipopt_prodtable`) e aritmética de saltos (`jump`),
    eliminando todas as chamadas `gethash`;
  - coeficientes numéricos identicamente nulos são pulados na acumulação
    (soma-se zero de qualquer forma; a grade homogênea completa continua
    sendo criada e preenchida, como no original);
  - grade do resultado inicializada com `zeros(dims)` do tamanho correto
    (o original inicializava com escalar 0);
  - `opcode`s vazios por padrão; com `rolmipopt('codegen','on')` executa
    o código original integral (`operation_poly_codegen.m`).
* **`@rolmipvar/homogenize.m`** — usa `polylift` (uma passada) em vez de
  δ produtos pelo polinômio "1"; original preservado em
  `homogenize_codegen.m`.
* **`@rolmipvar/polya.m`** — relaxação de Polya via `polylift`; caminho
  original mantido para `codegen on`.
* **`@rolmipvar/construct_lmi_terms.m`** —
  - homogeneização dos blocos por `polylift`;
  - montagem de cada LMI por concatenação em bloco (`cat`) em vez de
    elemento a elemento;
  - sintaxe moderna do YALMIP (`[LMIs, T>=0]`) em vez de `set()`;
  - desigualdades estritas convertidas em não estritas com aviso
    (`ROLMIPopt:strict`) — comportamento efetivo do YALMIP antigo; o
    YALMIP moderno rejeitaria `T>0` com erro;
  - não usa mais o registro global do polinômio "1" (salvar/restaurar);
  - original preservado em `construct_lmi_terms_codegen.m`.
* **`@rolmipvar/insert_simplex.m`** — anexação direta dos expoentes
  (convenção `[0]` do ROLMIP), sem reconstrução pelo construtor. Como os
  simplexos novos têm grau zero, a ordem canônica não muda.
* **`@rolmipvar/gt.m` / `lt.m`** — constroem `>=`/`<=` com aviso
  (`warning('off','ROLMIPopt:strict')` para silenciar).

## 4. Arquivos com patches pontuais

* **`generate_homogeneous_exponents.m`** — agora delega a
  `rolmipopt_exptable` (memoizada, iterativa; mesma ordem e mesmos
  valores).
* **`@rolmipvar/rolmipvar.m`** (construtor) —
  - `gethash` interno substituído por `rolmipopt_index` (O(v) exato);
  - `calccoefs` substituído por binômio inteiro exato via tabela de
    Pascal;
  - no ramo de expoentes explícitos, indexação **em lote**: uma chamada
    vetorizada de `rolmipopt_index` por simplexo, e índice direto (o
    próprio contador) na enumeração canônica dos monômios nulos;
  - geração dos `opcode`s base com `sprintf` (o `strcat`+`num2str` do
    original é custoso no MATLAB);
  - resto do arquivo inalterado.
* **`@rolmipvar/diff.m`** —
  - `gethash` interno substituído por `rolmipopt_index`;
  - `roundn` (Mapping Toolbox) substituído por comparação com tolerância
    (`abs(...) < 1e-8`) — remove a dependência da toolbox;
  - construção de `opcode`/`opcodein` condicionada a
    `rolmipopt('codegen','on')`.
* **`isstr` → `ischar`** em todos os arquivos (o `isstr` foi removido no
  Octave 10 e está deprecado no MATLAB).

## 5. Guardas de robustez de despacho

Métodos da classe que sombreiam builtins/operadores receberam guarda de
tipo — se o argumento não é `rolmipvar`, delegam ao builtin:

`size` (agora também aceita `size(poly,dim)`), `sum`, `full`, `round`,
`double`, `isnan`, `ndims`, `transpose`, `ctranspose`, `uminus`, `uplus`,
`mpower`, `mtimes`, `plus`, `minus`, `eq`, `horzcat`, `vertcat`,
`blkdiag` (fallback manual, pois `blkdiag` não é builtin), `diff`,
`subsref`, `subsasgn`.

No MATLAB essas guardas são inócuas (o despacho já é restrito à classe);
no Octave elas são **necessárias** (o Octave despacha métodos de classes
antigas em contextos em que o MATLAB usaria o builtin) — é o que torna o
ROLMIPopt utilizável também no Octave.

## 6. O que não mudou

* A estrutura de dados (`label`, `vertices`, `data(n).exponent`,
  `data(n).value`, `opcode`, `bounds`) e a **ordem canônica dos
  monômios** são as mesmas — objetos do ROLMIPopt são intercambiáveis com
  scripts escritos para o ROLMIP.
* Todos os demais métodos e funções do pacote original foram mantidos.
* A grade homogênea completa continua sendo materializada (mesma política
  de monômios nulos e, portanto, as mesmas LMIs).
* `lmifiles`/`opcode` continuam disponíveis via
  `rolmipopt('codegen','on')`.

## 7. Precisão

* Toda a combinatória (tabelas, índices, binômios, multinômios) é feita
  com inteiros exatos (recorrência de Pascal); o original usava
  `factorial` em `double`.
* As operações em ponto flutuante executadas são exatamente as mesmas do
  original — na homogeneização, o ROLMIPopt faz **menos** somas em ponto
  flutuante (uma acumulação com peso inteiro em vez de δ produtos
  encadeados), o que reduz o acúmulo de arredondamento.
* Validação: 25 resultados numéricos idênticos bit a bit ao original;
  bases das LMIs (`getbase`) idênticas bit a bit; exemplo H∞ do manual
  reproduzido (γ = 2.842944 / 1.053982 para graus 0/1), com confirmação
  cruzada por implementação e solver independentes.

## 8. Speedups medidos

Menor de 3 medições, com repetições dentro do cronômetro para operações
rápidas (amortização) e chamada de aquecimento.

**MATLAB R2026a:**

| operação | original | ROLMIPopt | speedup |
|---|---:|---:|---:|
| produto v=4, grau 3×3, blocos 8×8 | 34,3 ms | 1,1 ms | **32,1×** |
| produto v=5, grau 2×2, blocos 4×4 | 18,1 ms | 0,6 ms | **29,1×** |
| Polya grau 3 (v=4, grau 2) | 7,5 ms | 0,3 ms | **24,0×** |
| produto multi-simplexo [3 3] | 7,6 ms | 0,4 ms | **18,1×** |
| soma com homogeneização (grau 1+5) | 9,9 ms | 0,8 ms | **12,7×** |
| derivada temporal (v=3, grau 2) | 16,1 ms | 1,9 ms | **8,6×** |
| construtor multi-simplexo | 1,2 ms | 0,4 ms | **3,3×** |

**GNU Octave** (sem JIT, os laços do original pesam mais): produto 33–40×,
Polya 36×, multi-simplexo 22×, `diff` 7×, construtor 1,4×.

Os ganhos crescem com o número de monômios (vértices/graus maiores), pois
o custo de indexação do original cresce quadraticamente com ele.

Observação metodológica: a comparação deve ser feita em sessões separadas
do MATLAB (uma por parser) — o MATLAB mantém a classe `@rolmipvar` em
cache e não a recarrega de forma confiável ao trocar o path na mesma
sessão. O `rolmipopt_benchmark` oferece os modos `'save'`/`'compare'`
para isso.
