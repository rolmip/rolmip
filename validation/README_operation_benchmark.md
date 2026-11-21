# Operações isoladas: GitHub versus Opt 3.4

Entradas preparadas fora da medição, mesmos sistemas e graus 0:4, n/N 2:5, i=1. Sem solver. Duas chamadas de aquecimento e sete amostras por operação, caches ativos, sem limpar YALMIP entre amostras sobre os mesmos objetos. YALMIP é limpo ao preparar cada nova condição. Opt usa codegen=off; GitHub mantém opcodes. Execuções separadas e sequenciais.

- `multiply`: A' * P, com A' previamente calculada. A afim numérica e P simbólico simétrico de grau d. 160 casos (domínio × n × N × d); usados os casos H∞ para evitar duplicar entradas iguais por métrica. Três execuções por amostra, tempo dividido por três.
- `homogenize`: homogenize(Q,P), com Q constante simbólica de ordem n. Eleva Q ao grau d; P já possui o grau alvo. Mesmos 160 casos, três execuções por amostra. Grau zero é controle sem elevação efetiva.
- `constraints`: montagem de F a partir de G{j}>=0, com todos os polinômios G prontos. 320 casos (duas normas e domínios). Uma execução por amostra. Inclui homogeneização interna com zero e a interface ROLMIP/YALMIP.
- `yalmip_only`: montagem direta das restrições a partir dos coeficientes de G, previamente extraídos. Mesmos 320 casos. Mantém os mesmos grupos e a mesma ordem de concatenação da via ROLMIP. Controle do custo da camada YALMIP; a extração dos coeficientes não é cronometrada.

Total: 960 medições pareadas. Cada caso usa mediana das sete amostras. Os tempos NÃO são parcelas disjuntas de um único parser completo e NÃO devem ser somados para estimar seu tempo. A multiplicação e a homogeneização são cargas representativas, não todas as chamadas do modelo original. A comparação da construção com a conversão direta ajuda a localizar oportunidades, mas a diferença não é uma decomposição rigorosa de custo.

Verificações: dimensões, expoentes (constantes com expoente escalar zero ou vetor de zeros são normalizadas somente para comparação), e coeficientes afins entre versões (erro relativo <1e-12); avaliação numérica de produtos/homogeneização (erro <1e-9); equivalência das restrições da via ROLMIP e da via YALMIP direta, incluindo V/L. As bases e fontes do parser não são alterados. H₂ contínuo usa D=0 em memória.

```bash
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_operations('reference');"
matlab -batch "addpath('ROLMIP_opt_34/validation'); benchmark_operations('opt');"
```

Resultados em `output/opt34-operation-benchmark`; preparar manifesto de hashes e cópia idêntica da API begin/end em `timer_api` antes da primeira execução. Arquivos por caso permitem retomar. Não reutilizar resultados se fontes, bases ou configuração mudarem.

Consolidação e figura:

```bash
python3 ROLMIP_opt_34/validation/report_operations.py
matlab -batch "addpath('ROLMIP_opt_34/validation'); plot_operations;"
```

Compilar `relatorio/main.tex` dentro de sua pasta, onde fica a figura PDF.

Um controle inicial concatenava todos os coeficientes sem agrupamento. Foi
substituído pelo controle com agrupamento correspondente ao ROLMIP; os
resultados preliminares foram preservados em `flat_control_archive` e não
entram nas tabelas finais.
