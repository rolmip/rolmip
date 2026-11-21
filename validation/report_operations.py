import json,csv,hashlib,statistics
from pathlib import Path
root=Path(__file__).resolve().parents[2];out=root/'output/opt34-operation-benchmark'
a={r['id']:r for r in json.loads((out/'timings_reference.json').read_text())};b={r['id']:r for r in json.loads((out/'timings_opt.json').read_text())};assert len(a)==len(b)==960 and a.keys()==b.keys()
checks={}
for key,val in json.loads((out/'input_source_manifest.json').read_text()).items():
 if isinstance(val,str):checks[key]=hashlib.sha256((root/key).read_bytes()).hexdigest()==val
 else:
  for name,digest in val.items():checks[key+'/'+name]=hashlib.sha256((root/key/'rolmip'/name).read_bytes()).hexdigest()==digest
assert all(checks.values());(out/'integrity_check.json').write_text(json.dumps(checks,indent=2))
rows=[]
for key,r in a.items():
 s=b[key];assert s['relative_model_error']<1e-12 and s['V']==r['V'] and s['L']==r['L'];assert len(r['seconds'])==len(s['seconds'])==7
 rows.append(dict(id=key,operation=r['operation'],**r['case'],V=(r['V'] if r['operation'] in ['constraints','yalmip_only'] else ''),L=(r['L'] if r['operation'] in ['constraints','yalmip_only'] else ''),github_s=r['median_seconds'],opt_s=s['median_seconds'],ratio=r['median_seconds']/s['median_seconds'],github_min_s=r['min_seconds'],github_max_s=r['max_seconds'],opt_min_s=s['min_seconds'],opt_max_s=s['max_seconds'],model_error=s['relative_model_error'],batch=r['batch']))
with (out/'tempos_por_operacao.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
labels={'multiply':r'Multiplicação $A^TP$','homogenize':'Homogeneização','constraints':'Construção via ROLMIP','yalmip_only':'YALMIP direto (controle)'}
def stats(rs):
 x=sum(r['github_s'] for r in rs);y=sum(r['opt_s'] for r in rs)
 return dict(count=len(rs),github_sum_s=x,opt_sum_s=y,github_mean_ms=1000*x/len(rs),opt_mean_ms=1000*y/len(rs),ratio=x/y,reduction_percent=100*(1-y/x),median_ratio=statistics.median(r['ratio'] for r in rs),wins=sum(r['ratio']>1 for r in rs))
groups=[dict(operation=k,**stats([r for r in rows if r['operation']==k])) for k in labels]
bydegree=[dict(operation=k,degree=d,**stats([r for r in rows if r['operation']==k and r['degree']==d])) for k in labels for d in range(5)]
summary=dict(operations=groups,by_degree=bydegree,max_model_relative_error=max(r['relative_model_error'] for r in b.values()),max_point_error=max(r['point_error'] for r in list(a.values())+list(b.values())))
(out/'summary.json').write_text(json.dumps(summary,indent=2))
for name,data in [('resumo_operacoes.csv',groups),('resumo_graus.csv',bydegree)]:
 with (out/name).open('w',newline='') as f:w=csv.DictWriter(f,fieldnames=list(data[0]));w.writeheader();w.writerows(data)
def line(vals):return ' & '.join(map(str,vals))+r' \\'
main='\n'.join(line([labels[r['operation']],r['count'],f"{r['github_mean_ms']:.3f}",f"{r['opt_mean_ms']:.3f}",f"{r['ratio']:.2f}",f"{r['reduction_percent']:.1f}"]) for r in groups)
grad='\n'.join(line([labels[k]]+[f"{next(r for r in bydegree if r['operation']==k and r['degree']==d)['ratio']:.2f}" for d in range(5)]) for k in labels)
def sci(v):return '$'+('%.3e'%v).replace('e',r'\times10^{')+'}$'
text=r'''\documentclass[10pt,a4paper]{article}
\usepackage[utf8]{inputenc}\usepackage[T1]{fontenc}\usepackage[brazil]{babel}
\usepackage[margin=2.2cm]{geometry}\usepackage{amsmath,booktabs,graphicx}
\usepackage[hidelinks]{hyperref}\setlength{\emergencystretch}{3em}
\title{ROLMIP: medição de operações isoladas\\GitHub versus Opt 3.4}\date{18 de outubro de 2026}\author{Multiplicação, homogeneização e construção das restrições}
\begin{document}\maketitle
\section{Resultados}
Foram realizadas 960 comparações pareadas de operações, com entradas
preparadas a partir das mesmas bases de sistemas, graus de $P$ de 0 a 4,
ordens e números de vértices de 2 a 5. Cada resultado usa a mediana de sete
amostras, após duas chamadas de aquecimento. A tabela mostra a média dessas
medianas por operação; a razão é o quociente entre as somas das medianas.
\begin{center}\small\begin{tabular}{lrrrrr}\toprule
Operação & Casos & GitHub (ms) & Opt (ms) & GitHub/Opt & Redução (\%)\\\midrule
@@MAIN@@
\bottomrule\end{tabular}\end{center}
Os casos de multiplicação e homogeneização não são repetidos para cada norma,
pois as entradas são as mesmas; há 160 casos de cada. A construção das
restrições depende da norma e tem 320 casos em cada uma das duas vias.
O controle YALMIP direto é uma comparação auxiliar, não uma quarta etapa do
parser. Não há um fator global obtido somando essas quatro linhas.

\section{O que foi medido}
\begin{description}
\item[Multiplicação:] produto $A^TP$, com $A$ afim numérica e $P$ simbólica
simétrica de grau $d$. A transposta de $A$ e os operandos já estão prontos
antes de iniciar o cronômetro. Isso representa um produto comum nas LMIs,
mas não caracteriza todos os produtos possíveis, como grau $d$ por grau $d$.
\item[Homogeneização:] \texttt{homogenize(Q,P)}, com $Q$ uma matriz simbólica
constante e $P$ já no grau alvo. A operação eleva $Q$ ao grau $d$ e preserva
$P$. O grau zero é um controle sem elevação efetiva.
\item[Construção via ROLMIP:] criação do conjunto de restrições
\texttt{F=[F,G\{j\}>=0]}, com todos os polinômios matriciais $G$ previamente
montados. Inclui a homogeneização interna da comparação com zero e a
construção dos objetos de restrição YALMIP.
\item[YALMIP direto:] criação das mesmas restrições diretamente a partir dos
coeficientes de $G$, previamente extraídos. A extração fica fora do tempo. A concatenação usa os mesmos grupos de
coeficientes e a mesma ordem de inserção da via ROLMIP.
Serve para avaliar quanto do custo de conversão permanece na camada YALMIP,
sem passar novamente pelo operador de comparação do ROLMIP.
\end{description}

Os três ensaios principais não são parcelas exclusivas de uma única execução
completa. Por exemplo, a construção via ROLMIP inclui chamadas internas de
homogeneização, e o teste de homogeneização usa uma carga específica separada.
Seus tempos não devem ser somados nem interpretados como porcentagens exatas
do tempo total do parser medido nas campanhas anteriores.

\section{Resultados por grau}
As entradas abaixo são razões GitHub/Opt entre somas das medianas.
Valores superiores a um favorecem a Opt; inferiores a um favorecem a referência.
\begin{center}\begin{tabular}{lrrrrr}\toprule
Operação & Grau 0 & Grau 1 & Grau 2 & Grau 3 & Grau 4\\\midrule
@@GRADES@@
\bottomrule\end{tabular}\end{center}
\begin{center}\includegraphics[width=.98\linewidth]{operations.pdf}\end{center}

\section{Interpretação}
@@INTERPRETATION@@
O controle YALMIP direto apresentou razão agregada próxima de um, sem
melhoria consistente por caso. A construção via ROLMIP ficou, em média,
aproximadamente 1,82 vezes o controle direto na referência e 1,07 vezes
na Opt. Isso sugere que a conversão da Opt já está próxima do custo do
controle nesta carga, mas não estabelece um limite inferior rigoroso.

As cinco multiplicações com mediana maior na Opt ocorreram no grau zero
de $P$, com dois vértices. As diferenças foram pequenas, aproximadamente
5 a 20 microssegundos por operação; não se deve concluir que todo produto
polinomial é acelerado em qualquer tamanho.

A diferença entre a via ROLMIP e o YALMIP direto indica uma oportunidade de
investigação na conversão, mas não é uma medição exclusiva de uma função.
A via direta exclui a extração de coeficientes e usa entradas já preparadas.
No código atual, \texttt{ge.m} chama \texttt{homogenize(lhs,rhs)} antes de
criar cada desigualdade dos coeficientes. Assim, um atalho especializado para
comparação com zero é um candidato a experimento posterior, desde que
preserve dimensões, simetria, classificação das restrições e tratamento de
casos especiais. Nenhuma alteração desse tipo foi feita nesta campanha.

O grau zero da homogeneização não executa uma elevação efetiva. A referência
ainda prepara polinômios auxiliares de soma das coordenadas antes de verificar
se precisa elevar o grau; a Opt evita essa preparação. Por isso, um ganho
grande nesse controle não deve ser interpretado como aceleração de uma
expansão polinomial inexistente.

O teste de multiplicação inclui o custo das operações simbólicas do YALMIP,
não apenas a indexação dos monômios. A configuração \texttt{codegen=off} da
Opt também faz parte da comparação; a referência mantém os opcodes.
Portanto, os fatores não podem ser atribuídos exclusivamente a um algoritmo
ou extrapolados para geração de código, coeficientes puramente numéricos,
polinômios esparsos ou produtos entre dois graus elevados.

\section{Protocolo e verificações}
Usaram-se os primeiros sistemas de cada combinação da base, com parâmetros
congelados e sem Pólya. A construção cobre $H_2$ e $H_\infty$ nos domínios
contínuo e discreto. Para $H_2$ contínuo, $D=0$ apenas na cópia em memória.
Nenhum solver foi chamado e nenhum arquivo de base foi alterado.

As entradas são preparadas uma vez por condição, fora do tempo. O YALMIP é
limpo ao mudar de condição, mas não entre repetições sobre os mesmos objetos.
Multiplicação e homogeneização executam três operações por amostra; o tempo
é dividido por três. As conversões em restrições executam uma por amostra.
Todos os tempos incluem o pequeno custo do laço e da chamada da rotina de
despacho, iguais nas duas versões. Os caches permanecem ativos e as versões
rodam sequencialmente, em processos MATLAB separados. Esse protocolo mede
operações aquecidas sobre entradas prontas; difere da reconstrução completa
dos operandos a cada medição das campanhas anteriores.

Ambiente: Intel Core i7-14700, Ubuntu 24.04.5 LTS, MATLAB R2023b Update 5,
YALMIP 20250626. O computador não foi isolado de outras tarefas nem teve a
frequência fixada. Pequenas diferenças, especialmente no controle YALMIP,
não devem ser tratadas como ganhos garantidos ou efeitos exclusivos do ROLMIP.

Para comparar expoentes de constantes, normalizou-se a representação
escalar zero e o vetor de zeros: ambos representam o mesmo monômio
constante. Isso é necessário no controle de grau zero da homogeneização;
não altera as operações cronometradas.
As dimensões, os expoentes e os coeficientes afins das saídas foram comparados
entre versões com tolerância relativa $10^{-12}$. O maior erro relativo
observado foi @@MODELERR@@. Produtos e homogeneizações também foram avaliados
nos vértices e no centro, após atribuição aleatória às decisões; o maior erro
relativo foi @@POINTERR@@, abaixo de $10^{-9}$. A avaliação de $P$ usa
\texttt{evalpar}, portanto não é um oráculo independente de toda a indexação.

As restrições construídas pelas duas vias foram comparadas integralmente
dentro de cada versão. Também coincidiram $V$ e $L$, com as convenções
\texttt{numel(getvariables(F))} e soma das ordens dos blocos SDP de
\texttt{lmiinfo(F)}. Desigualdades escalares e igualdades não entram em $L$.
A equivalência testada refere-se à formulação; não demonstra otimalidade ou
factibilidade dos problemas, que não foram resolvidos nesta campanha.

Os resultados por caso estão em \path{tempos_por_operacao.csv}, com mínimos
e máximos das sete amostras; os JSON retêm todas as medições. Há tabelas
resumidas por operação e grau, modelos por caso e manifestos de integridade.
Os scripts ficam em \path{ROLMIP_opt_34/validation}.
\end{document}
'''
best=max((r for r in groups if r['operation']!='yalmip_only'),key=lambda r:r['ratio'])
interp=f"Entre as três cargas principais, a maior razão agregada ocorreu em {labels[best['operation']].lower()}, com {best['ratio']:.2f}. "
for r in groups:
 interp+=f"{labels[r['operation']]} teve menor mediana na Opt em {r['wins']} de {r['count']} casos. "
for k,v in {'MAIN':main,'GRADES':grad,'INTERPRETATION':interp,'MODELERR':sci(summary['max_model_relative_error']),'POINTERR':sci(summary['max_point_error'])}.items():text=text.replace('@@'+k+'@@',v)
(out/'relatorio/main.tex').write_text(text);print(json.dumps(groups,indent=2));print('All integrity/equivalence checks passed.')
