# Correções do Opt 3.4 — etapa 1

Data: 17/10/2026. Base recebida: `e34630436e7700e2e3c0a61af359461a701c1b58`.
Registro da etapa de correções incorporada à branch de desenvolvimento 3.4.

## Implementação

| Achado | Alteração |
| --- | --- |
| F01 | `diff` restaura o arredondamento da cópia local selecionada, conservando os extremos de taxas no reprodutor de pequena escala. |
| F02 | Removida a exigência de zero em cada intervalo individual de taxas, conforme a base local selecionada. |
| F03 | O produto verifica dimensões antes de saltar termos nulos; com coeficientes numéricos não finitos, efetua os produtos para preservar NaN/Inf. |
| F04 | O construtor valida vértices/graus e os vetores explícitos de expoentes homogêneos: finitos, reais, inteiros, não negativos e de comprimento compatível. A convenção `[0]` de grau zero é preservada. |
| F05 | Exportação verifica opcodes antes de escrever; ativar `codegen` posteriormente não recupera objetos sem histórico. Os operadores de transposta, negação, multiplicação por constantes e concatenação preservam a ausência de histórico, permitindo rejeitar a exportação. Os núcleos de compatibilidade rejeitam entradas sem opcodes. |
| F06 | `size` retorna dimensões unitárias além das duas armazenadas e valida o argumento de dimensão; continua usando `dims`. |
| H01 | Concatenação, transpostas e multiplicações por matrizes constantes atualizam `dims`. |
| H02 | O método `construct_lmi_terms_codegen` usa a mesma política de desigualdades não estritas com aviso que o método padrão. |
| Q01 | O autoteste fornecido lança `ROLMIP:TestFailure` se alguma verificação retornar falso. A documentação passa a indicar as 21 verificações existentes. |
| Cache | `clearcache` também limpa os persistentes de `rolmipopt_index`. |

A fórmula de indexação combinatória e a ordem dos monômios foram preservadas.
A implementação numérico-afim de `ROLMIP_optimized` não foi alterada.
O arquivo histórico `codeReviewOpt34.tex` permanece como registro da versão recebida.

## Validação executada

Ambiente: MATLAB R2023b Update 5, YALMIP 20250626 e SeDuMi.

- Autoteste fornecido: 21 verificações aprovadas.
- Nova suíte `rolmipopt_regression_test`: extremos de derivadas, taxas assimétricas,
  entradas inválidas, NaN/Inf, dimensões, preservação de opcodes ausentes,
  rejeição de exportação antes de escrever termos, parser do arquivo gerado e
  desigualdades estritas nos dois modos.
- Exemplo exportado e resolvido com SeDuMi: minimizar `P{1}` sujeito a `P{1} >= 2`.
  O argumento do objetivo é a expressão MATLAB `P{1}`, pois a variável matricial
  exportada é armazenada em uma célula.
- Avaliação independente ampliada: 720 verificações numéricas aprovadas,
  erro relativo máximo `6.265e-16`.
- Álgebra com variáveis de decisão: 12 atribuições aprovadas,
  erro relativo máximo `2.248e-16`.

Os logs desta etapa estão em `../../output/opt34-development/` no workspace.
Para executar os testes da distribuição, deixe apenas esta implementação do
ROLMIP no path e execute:

```matlab
rolmipopt_test
rolmipopt_regression_test
```

A nova suíte restaura o modo `codegen` e cria os arquivos de exportação em uma
pasta temporária própria. Não execute durante outra exportação: o exportador
legado usa estado global da sessão. Os testes com YALMIP/SeDuMi são opcionais
quando essas dependências não estão instaladas, com indicação explícita de skip.

## Limites e próxima etapa

A política de tolerância restaurada em `diff` é a escolhida para compatibilidade;
ela não é uma nova solução geométrica independente de escala. Permanecem fora
desta etapa a auditoria completa dos operadores legados, a exportação de todos
os exemplos, Octave, MPT e a certificação para graus muito elevados.

A etapa seguinte, documentada em `MEMORIA_3_4.md`, passou a limitar a memória de mapas de produto e caches e a
pré-alocar estruturas de saída e avaliar suporte ativo. Não foram introduzidas
essas mudanças de representação/memória junto das correções de comportamento.

## Normalização de expoentes de grau zero — 24/10/2026

O construtor continua aceitando vetores-linha não vazios de zeros com qualquer
comprimento, conforme a compatibilidade introduzida na revisão de Cristiano.
Após validar os valores e a soma dos expoentes, passa a armazenar a linha
canônica de `generate_homogeneous_exponents`: um zero por vértice, ou o escalar
zero para um simplexo ausente. Graus positivos mantêm a validação anterior.

Isso evita que objetos aceitos pelo construtor falhem em soma/multiplicação
com `codegen=on`, quando o vetor fornecido tem comprimento diferente do número
de vértices. A indexação combinatória e os coeficientes não foram alterados.

A regressão cobre os dois modos, simplexos com 0, 1 e 3 vértices, quatro
comprimentos de vetores nulos, operações multi-simplexo e entradas inválidas.
A suíte completa passou, incluindo o SDP exportado resolvido com SeDuMi.
A suíte ampliada `validation/test_robustness_opt34.m` concluiu 76 casos e
4.277 verificações, sem falhas, com erro relativo máximo de 9,993e-16.
Logs locais: `../../output/opt34-zero-normalization/`.
