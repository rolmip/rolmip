"""Build benchmark tables from seven warm measurements per model/version."""
import csv,json,statistics

def build_timing_report(out):
    ref={r['id']:r for r in json.loads((out/'timings_reference.json').read_text())}
    opt={r['id']:r for r in json.loads((out/'timings_opt.json').read_text())}
    assert len(ref)==len(opt)==420 and ref.keys()==opt.keys()
    rows=[]
    for key,a in ref.items():
        b=opt[key];assert a['V']==b['V'] and a['L']==b['L']
        assert a['model_error']==b['model_error']==0
        assert len(a['seconds'])==len(b['seconds'])==7
        rows.append(dict(id=key,**a['case'],V=a['V'],L=a['L'],github_median_s=a['median_seconds'],opt34_median_s=b['median_seconds'],speedup=a['median_seconds']/b['median_seconds'],github_min_s=a['min_seconds'],github_max_s=a['max_seconds'],opt34_min_s=b['min_seconds'],opt34_max_s=b['max_seconds']))
    with (out/'tempos_parser.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    lookup={r['id']:r for r in rows}
    # Add benchmark columns to the main result table as well.
    with (out/'resultados.csv').open() as f:
        reader=csv.DictReader(f);fields=reader.fieldnames;main=list(reader)
    extra=['V','L','github_median_s','opt34_median_s','speedup']
    fields=fields+[k for k in extra if k not in fields]
    for r in main:r.update({k:lookup[r['id']][k] for k in extra})
    with (out/'resultados.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(main)
    def stats(items):
        a=sum(r['github_median_s'] for r in items);b=sum(r['opt34_median_s'] for r in items)
        return dict(cases=len(items),github_sum_medians_s=a,opt_sum_medians_s=b,speedup=a/b,reduction_percent=100*(1-b/a),median_case_speedup=statistics.median(r['speedup'] for r in items),opt_faster=sum(r['speedup']>1 for r in items))
    totals=stats(rows);groups=[];table=[]
    for d,m,label in [('c','hinf',r'Contínuo $H_\infty$'),('c','h2',r'Contínuo $H_2$ ($D=0$)'),('d','hinf',r'Discreto $H_\infty$'),('d','h2',r'Discreto $H_2$')]:
        g=stats([r for r in rows if r['domain']==d and r['metric']==m]);groups.append(dict(domain=d,metric=m,**g))
        table.append(label+f" & {g['github_sum_medians_s']:.3f} & {g['opt_sum_medians_s']:.3f} & {g['speedup']:.2f}"+r' \\')
    table.append(r'\midrule Total'+f" & {totals['github_sum_medians_s']:.3f} & {totals['opt_sum_medians_s']:.3f} & {totals['speedup']:.2f}"+r' \\')
    summary=dict(total=totals,groups=groups,fastest=max(rows,key=lambda x:x['speedup']),slowest=min(rows,key=lambda x:x['speedup']))
    (out/'timing_summary.json').write_text(json.dumps(summary,indent=2))
    section=r'''\section{Tempo de parser: GitHub versus Opt 3.4}
A API implementada é \texttt{rolmip\_begin} seguida de
\texttt{[time,V,L] = rolmip\_end(LMIs)}, sem argumento de objetivo.
Ela mede tempo decorrido de construção, em segundos. A coleta de estatísticas
ocorre depois de parar o cronômetro. $V$ é
\texttt{numel(getvariables(LMIs))}; $L$ é a soma da primeira coluna de
\texttt{lmiinfo(LMIs).sdp}, excluindo restrições escalares e igualdades.
As estatísticas coincidiram entre as versões em todos os casos.

Cada um dos 420 modelos foi construído duas vezes para aquecimento e mais
sete vezes para medição, em cada versão. A tabela usa a mediana das sete
medições. Os dois benchmarks rodaram sequencialmente, em processos MATLAB
separados, sem solver concorrente iniciado pela campanha. A máquina é um
Intel Core i7-14700, Ubuntu 24.04.5 LTS, MATLAB R2023b Update 5.
O ambiente não foi isolado de outras atividades do usuário ou da variação
de frequência da CPU; diferenças pequenas exigem cautela.

O trecho cronometrado inclui criação de variáveis, operações polinomiais,
montagem dos blocos e conversão em restrições YALMIP. Inclui a construção
auxiliar da geometria de taxas usada pelo exemplo. Exclui leitura das bases,
limpeza do YALMIP, cálculo de $V,L$, extração/comparação de coeficientes,
checagem de normas e resolução. As rotinas de montagem são compartilhadas
entre validação e benchmark. As últimas construções repetidas foram novamente
comparadas, coeficiente por coeficiente, com a referência.

O YALMIP é limpo antes de cada repetição, fora do intervalo cronometrado.
Os caches do ROLMIP não são limpos: o resultado descreve construção com código
e caches aquecidos, não a primeira chamada após iniciar o MATLAB.
Usou-se a configuração padrão da Opt: \texttt{codegen=off}, cache de 64 MiB e
área temporária de 8 MiB. A referência mantém a construção de opcodes original.
Portanto, o ganho mede o fluxo de análise LMI padrão dessas versões, não
exportação de código. A API de medição foi copiada para uma pasta auxiliar
para cronometrar a referência, sem modificar seus fontes.

\begin{center}\begin{tabular}{lrrr}\toprule
Ensaio & GitHub (s) & Opt 3.4 (s) & Razão GitHub/Opt\\\midrule
@@TABLE@@
\bottomrule\end{tabular}\end{center}
Os tempos agregados são somas das medianas dos casos de cada grupo, não o tempo
total da campanha. No conjunto, a razão foi @@SPEED@@ e a redução do tempo,
@@REDUCTION@@\%. A mediana das razões individuais foi @@MEDIAN@@.
A Opt foi mais rápida em @@WINS@@ dos 420 casos. Esses resultados não indicam
que o solver tenha sido acelerado; ele não faz parte da medição.

As tabelas do anexo informam $V,L$, ambos os tempos e a razão em cada caso.
O arquivo \path{tempos_parser.csv} também traz mínimos e máximos das sete
medições; os JSON de tempos preservam todas as amostras.
'''.replace('@@TABLE@@','\n'.join(table)).replace('@@SPEED@@',f"{totals['speedup']:.2f}").replace('@@REDUCTION@@',f"{totals['reduction_percent']:.1f}").replace('@@MEDIAN@@',f"{totals['median_case_speedup']:.2f}").replace('@@WINS@@',str(totals['opt_faster']))
    appendix=r'''\clearpage\appendix\section{Tempos e dimensões por condição}
Tempos em milissegundos (mediana de sete medições). $p$ é o grau de $P$;
$q$ é a ordem da relaxação Pólya; $\rho$ indica a taxa ou incremento.
Com $p=1$ e $\rho=0$, o parâmetro é congelado. $R=t_{GitHub}/t_{Opt}$:
valores maiores que um favorecem a Opt. H2 contínuo usa $D=0$.
'''
    for d,m,label in [('c','hinf',r'Contínuo $H_\infty$'),('c','h2',r'Contínuo $H_2$'),('d','hinf',r'Discreto $H_\infty$'),('d','h2',r'Discreto $H_2$')]:
        appendix+='\n'+r'\subsection{'+label+'}\n'+r'\begingroup\small\setlength{\tabcolsep}{4pt}\begin{longtable}{rrrrrrrrrrr}'+'\n'
        header=r'\toprule $n$ & $N$ & $i$ & $p$ & $\rho$ & $q$ & $V$ & $L$ & GitHub (ms) & Opt (ms) & $R$\\\midrule'
        appendix+=header+r'\endfirsthead'+header+r'\endhead\bottomrule\endfoot'+'\n'
        selected=sorted((r for r in rows if r['domain']==d and r['metric']==m),key=lambda r:(r['n'],r['N'],r['i'],r['degree'],r['rho'],r['relax']))
        for r in selected:
            vals=[str(r[k]) for k in ['n','N','i','degree','rho','relax','V','L']]+[f"{1000*r['github_median_s']:.3f}",f"{1000*r['opt34_median_s']:.3f}",f"{r['speedup']:.2f}"]
            appendix+=' & '.join(vals)+r' \\'+'\n'
        appendix+=r'\end{longtable}\endgroup'+'\n'
    return section,appendix,summary
