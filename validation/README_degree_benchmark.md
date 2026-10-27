# Benchmark de grau, vértices e ordem

Usa as mesmas bases `baseSis_c.mat` e `baseSis_d.mat` da validação, sem modificá-las e sem resolver os SDPs. Resultados separados em `output/opt34-degree-benchmark`.

- Grade principal: domínios contínuo/discreto × H₂/H∞ × ordens 2:5 × vértices 2:5 × graus de P 0:4, usando i=1: 320 casos.
- Verificação entre sistemas: n=N=5, i=2:5, graus 1 e 4, ambos os domínios e métricas: 32 casos adicionais.
- Total: 352 condições pareadas entre versões. H₂ contínuo usa D=0 somente em memória. Sem taxas ou Pólya, para separar seu efeito do aumento do grau.
- Duas construções de aquecimento e sete medições. YALMIP limpo fora da medição; caches do ROLMIP mantidos. Versões executadas sequencialmente, em processos separados, Opt com codegen=off (padrão). Referência conserva opcodes.
- Cronometragem inclui variáveis, manipulação polinomial e geração de restrições YALMIP. Exclui estatísticas V/L, leitura, limpeza, verificações e solver.
- Conferência exata de V/L e dimensões; comparação de todos os coeficientes afins entre versões com erro relativo inferior a 1e-12. O teste inicialmente exigia igualdade bit a bit, mas detectou diferença de arredondamento de 4,44e-16 no grau 2; os erros absolutos e relativos são registrados. Comparação adicional com expressões matriciais numéricas após atribuição aleatória às decisões, nos vértices, centro e três pontos internos.
- A avaliação de P usa evalpar; a checagem matricial testa a montagem, não constitui um oráculo independente para toda a indexação de monômios.

Executar a partir da raiz do projeto:

```bash
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_degree('reference');"
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_degree('opt');"
```

A pasta deve conter `timer_api`, cópia idêntica de rolmip_begin/end e seu helper privado, usada para cronometrar a referência sem alterar os fontes GitHub. As dependências YALMIP e os caminhos estão no script. Resultados MAT por caso permitem retomada; ao alterar bases ou fontes, criar uma nova pasta e manifesto antes de executar, sem reutilizar arquivos antigos.

A comparação do grau é pareada sobre as mesmas matrizes. Comparações entre ordens/vértices são descritivas: as matrizes e dimensões B/C mudam entre sistemas. As dimensões de entrada e saída são registradas. Não se conclui que diferenças de tempo sejam causadas exclusivamente pela ordem ou pelo número de vértices.

Após as duas versões terminarem:

```bash
python3 ROLMIP_opt_34/validation/report_degree.py
matlab -batch "addpath('ROLMIP_opt_34/validation'); plot_degree;"
```

O gerador produz o relatório LaTeX, tabelas CSV por caso/grau/vértices/ordem/norma e `summary.json`. `plot_degree` gera figuras PDF vetorial e PNG usando MATLAB. Compilar `relatorio/main.tex` dentro da pasta `relatorio`, onde fica a figura. O teste piloto separado (`benchmark_degree('reference',true)`) cobre quatro condições máximas com uma medição e não entra nos resultados principais.
