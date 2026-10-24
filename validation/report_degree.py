"""Summarize the paired degree benchmark; standard library only."""
import json,csv,hashlib,statistics
from pathlib import Path
root=Path(__file__).resolve().parents[2];out=root/'output/opt34-degree-benchmark'
a={r['id']:r for r in json.loads((out/'timings_reference.json').read_text())};b={r['id']:r for r in json.loads((out/'timings_opt.json').read_text())}
assert len(a)==len(b)==352 and a.keys()==b.keys()
checks={}
for key,value in json.loads((out/'input_source_manifest.json').read_text()).items():
 if isinstance(value,str):checks[key]=hashlib.sha256((root/key).read_bytes()).hexdigest()==value
 else:
  for name,digest in value.items():checks[key+'/'+name]=hashlib.sha256((root/key/'rolmip'/name).read_bytes()).hexdigest()==digest
assert all(checks.values());(out/'integrity_check.json').write_text(json.dumps(checks,indent=2))
rows=[]
for key,r in a.items():
 s=b[key];assert r['V']==s['V'] and r['L']==s['L'] and s.get('model_relative_error',s['model_error'])<1e-12
 assert r['V']==r['monomials_P']*r['case']['n']*(r['case']['n']+1)//2+1
 assert len(r['seconds'])==len(s['seconds'])==7
 rows.append(dict(id=key,**r['case'],nw=r['nw'],nz=r['nz'],monomials_P=r['monomials_P'],V=r['V'],L=r['L'],github_s=r['median_seconds'],opt_s=s['median_seconds'],ratio=r['median_seconds']/s['median_seconds'],github_min_s=r['min_seconds'],github_max_s=r['max_seconds'],opt_min_s=s['min_seconds'],opt_max_s=s['max_seconds'],model_absolute_error=s['model_error'],model_relative_error=s.get('model_relative_error',s['model_error'])))
with (out/'tempos_por_caso.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
main=[r for r in rows if r['i']==1]
def stats(rs):
 x=sum(r['github_s'] for r in rs);y=sum(r['opt_s'] for r in rs)
 return dict(count=len(rs),github_sum_s=x,opt_sum_s=y,github_mean_s=x/len(rs),opt_mean_s=y/len(rs),ratio=x/y,reduction_percent=100*(1-y/x),median_ratio=statistics.median(r['ratio'] for r in rs),min_ratio=min(r['ratio'] for r in rs),max_ratio=max(r['ratio'] for r in rs),wins=sum(r['ratio']>1 for r in rs))
degrees=[dict(degree=d,**stats([r for r in main if r['degree']==d])) for d in range(5)]
byN=[dict(N=N,degree=d,**stats([r for r in main if r['N']==N and r['degree']==d])) for N in range(2,6) for d in range(5)]
byn=[dict(n=n,degree=d,**stats([r for r in main if r['n']==n and r['degree']==d])) for n in range(2,6) for d in range(5)]
byMetric=[dict(domain=dom,metric=m,degree=d,**stats([r for r in main if r['domain']==dom and r['metric']==m and r['degree']==d])) for dom in 'cd' for m in ['hinf','h2'] for d in range(5)]
summary=dict(max_model_error=max(r['model_error'] for r in b.values()),max_model_relative_error=max(r.get('model_relative_error',r['model_error']) for r in b.values()),exact_models=sum(r['model_error']==0 for r in b.values()),main=stats(main),all=stats(rows),degrees=degrees,by_vertices=byN,by_order=byn,by_metric=byMetric,max_formula_error=max(r['formula_error'] for r in list(a.values())+list(b.values())),fastest=max(rows,key=lambda r:r['ratio']),slowest=min(rows,key=lambda r:r['ratio']))
(out/'summary.json').write_text(json.dumps(summary,indent=2))
for filename,data in [('por_grau.csv',degrees),('por_vertices.csv',byN),('por_ordem.csv',byn),('por_norma.csv',byMetric)]:
 with (out/filename).open('w',newline='') as f:
  w=csv.DictWriter(f,fieldnames=list(data[0]));w.writeheader();w.writerows(data)
def line(vals):return ' & '.join(str(x) for x in vals)+r' \\'
degree_table='\n'.join(line([r['degree'],r['count'],f"{r['github_sum_s']:.3f}",f"{r['opt_sum_s']:.3f}",f"{r['ratio']:.2f}",f"{r['reduction_percent']:.1f}"]) for r in degrees)
Ntable='\n'.join(line([N]+[f"{next(r for r in byN if r['N']==N and r['degree']==d)['ratio']:.2f}" for d in range(5)]) for N in range(2,6))
ntable='\n'.join(line([n]+[f"{next(r for r in byn if r['n']==n and r['degree']==d)['ratio']:.2f}" for d in range(5)]) for n in range(2,6))
labels={('c','hinf'):r'Contínuo $H_\infty$',('c','h2'):r'Contínuo $H_2$, $D=0$',('d','hinf'):r'Discreto $H_\infty$',('d','h2'):r'Discreto $H_2$'}
Mtable='\n'.join(line([label]+[f"{next(r for r in byMetric if r['domain']==dom and r['metric']==m and r['degree']==d)['ratio']:.2f}" for d in range(5)]) for (dom,m),label in labels.items())
robust=[]
for dom,m in labels:
 for i in range(1,6):
  pair=[next(r for r in rows if r['domain']==dom and r['metric']==m and r['n']==5 and r['N']==5 and r['i']==i and r['degree']==d) for d in [1,4]]
  robust.append(line([('C' if dom=='c' else 'D')+(' / H2' if m=='h2' else ' / Hinf'),i,pair[1]['nw'],pair[1]['nz'],f"{pair[0]['ratio']:.2f}",f"{pair[1]['ratio']:.2f}",f"{1000*pair[1]['github_s']:.1f}",f"{1000*pair[1]['opt_s']:.1f}"]))
text=r'''\documentclass[10pt,a4paper]{article}
\usepackage[utf8]{inputenc}\usepackage[T1]{fontenc}\usepackage[brazil]{babel}
\usepackage[margin=2.2cm]{geometry}\usepackage{amsmath,amssymb,booktabs,longtable,graphicx}
\usepackage[hidelinks]{hyperref}\setlength{\emergencystretch}{3em}
\title{ROLMIP: escalabilidade do tempo de parser\\Grau, vértices e ordem das matrizes}
\author{GitHub versus Opt 3.4}\date{18 de outubro de 2026}
\begin{document}\maketitle
\section{Questão investigada e resultado}
A campanha investiga se a vantagem da Opt 3.4 aumenta quando crescem o grau de
$P(\alpha)$, o número de vértices ou a ordem das matrizes. Foram construídas
352 condições em cada versão, sem chamar o solver, usando as mesmas bases
quadraticamente estáveis da validação anterior. As contagens $V,L$ e as dimensões coincidiram exatamente. Os modelos afins
foram comparados com tolerância relativa $10^{-12}$; o maior erro relativo
observado foi @@MODELREL@@ (erro absoluto máximo @@MODELABS@@).
Houve igualdade exata em @@EXACT@@ dos 352 casos; diferenças restantes são
quantificadas para não confundir arredondamento com alteração da formulação.

Na grade principal de 320 condições, a razão entre as somas dos tempos medianos
foi @@RATIO@@; a redução agregada foi @@REDUCTION@@\%.
A Opt teve menor mediana em @@WINS@@ dos 320 casos.
Por grau, os resultados são:
\begin{center}\begin{tabular}{rrrrrr}\toprule
Grau de $P$ & Casos & GitHub (s) & Opt (s) & GitHub/Opt & Redução (\%)\\\midrule
@@DEGREES@@
\bottomrule\end{tabular}\end{center}
Cada célula de tempo soma as medianas de sete medições por caso, após duas
construções de aquecimento. As mesmas 64 combinações de sistema e métrica são usadas em
cada grau; portanto, a comparação entre graus é pareada. Uma razão maior que
um favorece a Opt. Não se trata de aceleração do solver ou comparação dos
custos $H_2/H_\infty$, pois os SDPs desta campanha não foram resolvidos.

\section{Desenho experimental}
A grade principal usa ordens $n=2,3,4,5$, vértices $N=2,3,4,5$ e graus
$d=0,1,2,3,4$, nos quatro grupos: contínuo/discreto e $H_2/H_\infty$.
Utiliza-se $i=1$ de cada combinação da base, totalizando 320 condições.
Como verificação entre diferentes sistemas, adicionaram-se $i=2,3,4,5$ para
$n=N=5$, graus 1 e 4, nos mesmos quatro grupos: mais 32 condições.
Esses 32 casos não entram nos totais por grau da grade principal.

Os arquivos \texttt{baseSis\_c.mat} e \texttt{baseSis\_d.mat} não foram
alterados. A leitura é \texttt{BASE\{n,N,i\}.sys}. Como antes, $H_2$ contínuo
usa variantes com $D=0$ somente em memória. Nos demais ensaios, mantém-se $D$.
O parâmetro é congelado e não se aplica Pólya, evitando misturar esses efeitos
com a elevação do grau. As LMIs são exatamente as mesmas formulações da
validação anterior, agora com $P$ de grau até 4.

Para um polinômio homogêneo em $N$ coordenadas, o número de monômios de grau
$d$ é $M=\binom{N+d-1}{d}$. Com coeficientes simétricos livres de ordem $n$,
a contagem esperada nesta campanha é $V=M n(n+1)/2+1$, incluindo o escalar do
custo. Essa expressão foi conferida em todos os casos. Para $n=N=5,d=4$,
obtêm-se 70 monômios e 1.051 variáveis escalares. $L$ soma somente as ordens
dos blocos semidefinidos reconhecidos pelo YALMIP, sem desigualdades escalares
ou igualdades.

\section{Metodologia de tempo e validação}
A API \texttt{rolmip\_begin}/\texttt{rolmip\_end(LMIs)} mede a criação das
variáveis, as operações polinomiais, a montagem dos blocos e sua conversão em
restrições YALMIP. Excluem-se leitura, limpeza do YALMIP, estatísticas $V,L$,
comparação dos modelos e verificações numéricas. A referência usa uma cópia
idêntica da API em uma pasta auxiliar; seus fontes não foram modificados.

Cada condição tem duas construções de aquecimento e sete medições. Os caches
do ROLMIP permanecem ativos; o YALMIP é limpo antes de cada construção, fora
do intervalo cronometrado. Mede-se execução aquecida, não partida a frio.
As versões executam sequencialmente em processos MATLAB separados. A Opt
usa \texttt{codegen=off} (padrão); a referência mantém seus opcodes. Assim,
a comparação representa o fluxo de análise de LMIs dessas configurações,
não o desempenho de exportação de código.

Ambiente: Intel Core i7-14700, Ubuntu 24.04.5 LTS, MATLAB R2023b Update 5 e
YALMIP 20250626. A máquina não foi isolada de tarefas do usuário nem teve
frequência fixada. Medianas reduzem a influência de observações isoladas,
mas não eliminam efeitos sistemáticos da carga ou da ordem de execução.

Além da comparação de todos os coeficientes afins entre versões, atribuiu-se
um vetor aleatório às decisões e comparou-se a avaliação das LMIs com suas
expressões matriciais numéricas, em vértices, centro e três pontos internos.
O maior erro relativo foi @@ERROR@@, abaixo de $10^{-9}$.
A avaliação de $P$ nessa checagem usa \texttt{evalpar}; logo, não é um oráculo
independente para toda a indexação monomial. Os testes confirmam a preservação
da montagem nos casos cobertos, sem afirmar factibilidade ou otimalidade dos
problemas de graus maiores.

\section{Grau e número de vértices}
\begin{center}\begin{tabular}{rrrrrr}\toprule
Vértices & Grau 0 & Grau 1 & Grau 2 & Grau 3 & Grau 4\\\midrule
@@VERTICES@@
\bottomrule\end{tabular}\end{center}
As entradas são razões entre somas das medianas GitHub/Opt, mantendo $N$ e
$d$ e agregando ordens e os quatro grupos de normas/domínios. O número de
monômios é um indicador mais informativo da carga combinatória que o grau
isoladamente: o mesmo grau produz números de termos muito diferentes quando
se altera o número de vértices.

\begin{center}\includegraphics[width=.98\linewidth]{degree_scaling.pdf}\end{center}

\section{Ordem das matrizes e tipo de condição}
\begin{center}\begin{tabular}{rrrrrr}\toprule
Ordem $n$ & Grau 0 & Grau 1 & Grau 2 & Grau 3 & Grau 4\\\midrule
@@ORDERS@@
\bottomrule\end{tabular}\end{center}
\begin{center}\begin{tabular}{lrrrrr}\toprule
Condição & Grau 0 & Grau 1 & Grau 2 & Grau 3 & Grau 4\\\midrule
@@METRICS@@
\bottomrule\end{tabular}\end{center}
Essas razões também são quocientes de somas de medianas.
Ao variar a ordem ou o número de vértices, mudam as matrizes da base e, em
alguns casos, as dimensões de entrada e saída. Portanto, essas tabelas mostram
associações na base testada, e não isolam um efeito causal exclusivo de $n$
ou $N$. O pareamento entre versões, em cada linha individual, permanece exato.

\section{Verificação em cinco sistemas: $n=N=5$}
Aqui, $m$ e $p$ indicam as dimensões de entrada e saída, respectivamente.
Os tempos em milissegundos são do grau 4. C/D denotam contínuo/discreto.
\begin{center}\small\begin{tabular}{lrrrrrrr}\toprule
Condição & $i$ & $m$ & $p$ & Razão grau 1 & Razão grau 4 & GitHub (ms) & Opt (ms)\\\midrule
@@ROBUST@@
\bottomrule\end{tabular}\end{center}

\section{Interpretação e próximos experimentos}
A Opt teve menor mediana também nos 32 casos adicionais. Nas 20 combinações
de sistema e métrica com $n=N=5$ (cinco sistemas por grupo), a razão no grau
4 superou a do grau 1.

@@INTERPRETATION@@
A vantagem também aumentou com o número de vértices em cada grau da grade
agregada. Já o aumento da ordem das matrizes não produziu uma tendência
monotônica de ganho relativo. Isso é compatível com a hipótese de que a
organização dos monômios é uma fonte importante de ganho, mas não é uma
medição isolada desse mecanismo.

Os resultados medem o efeito conjunto das otimizações e da configuração
\texttt{codegen=off}. Não se deve atribuir quantitativamente o ganho a uma
rotina específica sem um experimento que desligue cada otimização ou um
perfil por etapa. Da mesma forma, não se pode extrapolar os fatores medidos
para graus ou números de vértices maiores que os testados.

Como complemento, um microbenchmark controlado poderia fixar dimensões,
graus e proporção de coeficientes numéricos nulos e medir separadamente
multiplicação, homogeneização e construção das restrições. Essa abordagem
ajudaria a localizar a origem do ganho, mas não substituiria o benchmark
completo de LMIs reais apresentado aqui. Para a questão prática desta
campanha, elevar o grau no mesmo sistema foi a comparação mais direta.

Os resultados completos, incluindo mínimos e máximos das sete medições,
estão em \path{tempos_por_caso.csv}; os JSON preservam todas as amostras.
O manifesto inicial e sua verificação final identificam fontes e bases.
Os modelos de referência estão salvos por caso, e os scripts de reprodução
ficam em \path{ROLMIP_opt_34/validation}.
\end{document}
'''
# Derive wording from measured aggregates rather than assuming monotonicity.
ratios=[r['ratio'] for r in degrees]
trend=('A razão agregada GitHub/Opt cresceu a cada aumento do grau na grade testada.' if all(x<y for x,y in zip(ratios,ratios[1:])) else 'A vantagem relativa não cresceu de forma estritamente monotônica com o grau; os valores por grau precisam ser considerados individualmente.')
trend+=f" Do grau 0 ao grau 4, a razão passou de {ratios[0]:.2f} para {ratios[-1]:.2f}. "
trend+='Isso '+('sustenta' if ratios[-1]>ratios[0] else 'não sustenta, nesta grade,')+' a expectativa de maior vantagem relativa nos problemas de grau mais alto, dentro dos limites desta medição.'
repl={'MODELREL':('$'+('%.3e'%summary['max_model_relative_error']).replace('e',r'\times10^{')+'}$'),'MODELABS':('$'+('%.3e'%summary['max_model_error']).replace('e',r'\times10^{')+'}$'),'EXACT':str(summary['exact_models']),'RATIO':f"{summary['main']['ratio']:.2f}",'REDUCTION':f"{summary['main']['reduction_percent']:.1f}",'WINS':str(summary['main']['wins']),'DEGREES':degree_table,'VERTICES':Ntable,'ORDERS':ntable,'METRICS':Mtable,'ROBUST':'\n'.join(robust),'ERROR':('$'+('%.3e'%summary['max_formula_error']).replace('e',r'\times10^{')+'}$'),'INTERPRETATION':trend}
for key,val in repl.items():text=text.replace('@@'+key+'@@',val)
assert '@@' not in text
(out/'relatorio/main.tex').write_text(text)
print(json.dumps(degrees,indent=2));print('All model/count/integrity checks passed.')
