# Memória e cache do Opt 3.4 — etapa 2

Data: 17/10/2026. Comparação com a versão **corrigida na etapa 1**, e não com
o ROLMIP original do GitHub. Alterações incorporadas à branch de desenvolvimento 3.4.

## O que mudou

- `rolmipopt_prodtable`: constrói somas de expoentes em blocos, em vez de
  materializar todos os pares em uma grande matriz com `kron`/`repmat`.
  Usa a mesma fórmula de rank. Guarda uma orientação por par de graus;
  a ordem inversa reaproveita sua transposta.
- Cache compartilhado LRU: expoentes, mapas de produto e pesos de levantamento
  compartilham um orçamento de dados numéricos de 64 MiB por padrão.
  Entradas grandes demais são calculadas e retornadas sem armazenamento.
  Reduzir o orçamento descarta entradas imediatamente.
- `rolmipopt_lifttable`: guarda somente os pesos, pois o mapa já pertence ao
  cache de produtos. Os pesos dependem de vértices e incremento de grau,
  permitindo reutilização entre diferentes graus de origem.
- `operation_poly`: pré-aloca a grade de saída; seleciona coeficientes ativos
  antes de calcular os destinos; processa destinos em blocos. Quando o mapa
  completo seria grande ou desproporcional ao suporte ativo, calcula apenas
  os índices dos pares utilizados, sem construir esse mapa completo.
- `polylift`: pré-aloca structs e células de saída.
- Mantidas a grade pública completa, a representação `data(k).value`, a ordem
  de acumulação por monômio de origem e a indexação combinatória validada.
  Coeficientes simbólicos não são descartados como zeros. NaN/Inf conservam
  o tratamento da etapa de correções.
- Os caminhos legados de `codegen on` não foram reescritos nesta etapa.

## Configuração

```matlab
rolmipopt('cachebytes',64*1024^2); % armazenamento: padrão 64 MiB
rolmipopt('workbytes',8*1024^2);   % blocos temporários: padrão 8 MiB
rolmipopt('cachebytes',0);        % desativa o cache compartilhado
s = rolmipopt('cachestats');      % bytes, entries, hits, misses, evictions, limit
rolmipopt('clearcache');          % limpa tabelas e contadores, preserva opções
```

`workbytes` é um alvo estimado para blocos de cálculo, mínimo 1024 bytes.
**Nenhuma dessas opções representa um limite de memória total do MATLAB.**
A contabilização do cache não inclui o overhead de estruturas MATLAB, cópias
mantidas pelo chamador, coeficientes, tabelas de Pascal e demais dados do processo.
Os blocos usam estimativas conservadoras, mas os temporários do MATLAB e pelo
menos uma linha de expoentes precisam existir mesmo para orçamentos mínimos.

A chamada direta de `rolmipopt_prodtable` retorna uma matriz double completa.
Esse resultado ainda custa `8*m1*m2` bytes, mesmo se exceder o cache.
`polylift` também recebe o mapa completo de levantamento. Esses limites devem
ser considerados em problemas muito grandes; a próxima melhoria possível é
consumir o levantamento em blocos, sem exigir o mapa inteiro.

## Medições

Ambiente: MATLAB R2023b Update 5 no mesmo computador. Execuções anteriores e
posteriores foram sequenciais, em processos separados. A cópia anterior está
em `../../output/opt34-memory/before/` no workspace. Não se alterou a base
`ROLMIP_github`.

### Construção de mapa maior

Um simplexo com 10 vértices; graus 5 × 5; matriz de destinos 2002 × 2002.
Uma execução por versão, cache inicialmente vazio. Tempo medido somente em
`rolmipopt_prodtable`; pico RSS coletado pelo `/usr/bin/time -v` para o processo
completo, incluindo inicialização do MATLAB.

| Métrica | Etapa 1 | Etapa 2 |
| --- | ---: | ---: |
| Construção do mapa | 1,063162 s | 0,513796 s |
| Pico RSS do processo | 2.135.636 KiB | 1.592.652 KiB |
| Soma dos índices retornados | 174.619.106.760 | 174.619.106.760 |

Redução observada de aproximadamente **25,4% no pico RSS** (530,3 MiB), com
construção aproximadamente **2,07 vezes mais rápida**. O checksum coincidente
é uma conferência adicional; a validação exata dos índices é feita pela suíte
com uma busca independente em tabelas menores. RSS não representa apenas a
memória do kernel e o ensaio isolado não estabelece uma garantia universal.

### Operações com cache aquecido

Matrizes de coeficientes 3 × 3, dados com semente fixa. Cinco execuções de
aquecimento e mediana de 15 execuções cronometradas, construção dos objetos
fora do cronômetro. A representação e os dados de entrada são os mesmos.

| Operação | Etapa 1 | Etapa 2 | Observação |
| --- | ---: | ---: | --- |
| Produto denso, 4 vértices, grau 3 × 3 | 0,858 ms | 0,966 ms | Aproximadamente 13% mais lento |
| Produto denso, 6 vértices, grau 3 × 3 | 5,287 ms | 4,965 ms | Aproximadamente 6% mais rápido |
| Produto, 6 vértices, grau 3 × 3, apenas 1 e 2 coeficientes ativos | 1,244 ms | 1,036 ms | Aproximadamente 17% mais rápido |
| Polya, 4 vértices, grau 3, incremento 3 | 2,491 ms | 0,575 ms | Aproximadamente 4,33 vezes mais rápido |

São medições locais, sujeitas a variação do sistema/JIT. O controle de cache e
blocos tem custo e não acelera todos os casos pequenos. Esta etapa prioriza a
redução de temporários grandes e a previsibilidade do armazenamento em cache.
Não foram medidos ganhos no tempo total de solução de LMIs.

## Validação

- Autoteste original: 21 verificações aprovadas.
- `rolmipopt_regression_test`: aprovado, incluindo as correções de `diff`,
  NaN/Inf, exportação, desigualdades e solução do arquivo gerado com SeDuMi.
- Novo `rolmipopt_memory_test`: orçamento, descarte LRU, redução imediata do
  limite, cache desligado, reutilização por transposta, pesos multinomiais,
  índices contra busca independente e igualdade exata de coeficientes entre
  blocos grandes e pequenos.
- Cache **desativado** e `workbytes=1024`: 720 verificações numéricas independentes
  aprovadas (erro relativo máximo `6.265e-16`) e 12 atribuições YALMIP aprovadas
  (`2.248e-16`). Essa configuração força o caminho em blocos pequenos.
- Não se alteraram a fórmula de `rolmipopt_index` nem sua ordem de monômios.
- Não foram certificados Octave, graus acima da precisão inteira de double,
  todos os exemplos do manual ou consumo máximo de todo o MATLAB.

Para executar os testes, com somente esta implementação do ROLMIP no path:

```matlab
rolmipopt_test
rolmipopt_regression_test
rolmipopt_memory_test
```

A suíte de memória restaura as opções anteriores e limpa os caches ao terminar.
A suíte de regressão identifica como skip testes de solver quando faltam as
dependências; no ensaio completo desta etapa, YALMIP e SeDuMi estavam disponíveis.

## Evidências

Pasta `../../output/opt34-memory/` no workspace:

- `before/`: snapshot da etapa 1 usada nas comparações.
- `bench_memory.m`, `before.log`, `after.log`, `before.mat`, `after.mat`:
  operações pequenas e médias; os tempos finais acima usam cinco aquecimentos
  e 15 amostras. As primeiras sondagens com menos aquecimentos foram substituídas.
- `bench_peak.m`, `peak_before.log`, `peak_after.log`: ensaio maior de tempo/RSS.
- `tests.log`, `low_budget_tests.log`: validação das correções e dos blocos pequenos.
- `source_manifest.json`: hashes das fontes antes e depois da etapa.
