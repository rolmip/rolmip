"""Aggregate MATLAB results; emit CSV and Portuguese LaTeX report (stdlib only)."""
import csv, json, hashlib
from pathlib import Path
from collections import Counter
root=Path(__file__).resolve().parents[2]
out=root/'output/opt34-validation'
records=json.loads((out/'opt_results.json').read_text())
refs=json.loads((out/'reference_results.json').read_text())
assert len(records)==len(refs)==420
assert {r['id'] for r in records}=={r['id'] for r in refs}
assert all(r['status']=='reference_built' for r in refs)
assert all(r['model_error']==0 for r in records)
manifest=json.loads((out/'input_source_manifest.json').read_text())
checks={}
for key,value in manifest.items():
    if isinstance(value,str): checks[key]=hashlib.sha256((root/key).read_bytes()).hexdigest()==value
    else:
        for name,digest in value.items():
            path=root/key/'rolmip'/name
            checks[str(path.relative_to(root))]=hashlib.sha256(path.read_bytes()).hexdigest()==digest
assert all(checks.values()), [k for k,v in checks.items() if not v]
(out/'integrity_check.json').write_text(json.dumps(checks,indent=2))
transfer=json.loads((out/'transferred_certificate.json').read_text())
assert transfer['passed']
accepted={'validated','feasible_solver_warning'}
fields=['id','domain','n','N','i','metric','degree','rho','relax','zeroD','status','problem','bound','eta','sample_lower_bound','residual','relative_residual','point_residual','model_error','formula_error','solved_formula_error','build_seconds','parse_seconds','V','L','solve_seconds','solver_eps','supplemental_bound','supplemental_source']
with (out/'resultados.csv').open('w',newline='') as f:
    writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader()
    for r in records:
        row={k:r.get(k,'') for k in fields};row.update(r['case'])
        if r['status'] not in accepted:
            for k in ['bound','eta']:row[k]=''
        if r['id']==transfer['target']:
            row['supplemental_bound']=transfer['bound'];row['supplemental_source']=transfer['source']
        writer.writerow(row)
def num(v): return ('%.6g'%v) if v is not None else '--'
def tex(s): return str(s).replace('_',r'\_')
statuses=['validated','feasible_solver_warning','infeasible_condition','numerical_check_failed']
rows=[]
for d,m,label in [('c','hinf',r'Contínuo $H_\infty$'),('c','h2',r'Contínuo $H_2$, $D=0$'),('d','hinf',r'Discreto $H_\infty$'),('d','h2',r'Discreto $H_2$')]:
    counts=Counter(r['status'] for r in records if r['case']['domain']==d and r['case']['metric']==m)
    rows.append(label+' & '+' & '.join(str(counts[s]) for s in statuses)+r' \\')
examples=[]
for r in records:
    c=r['case']
    if c['n']==2 and c['N']==2 and c['i']==1 and c['relax']==0:
        label=('C' if c['domain']=='c' else 'D')+(' / H2' if c['metric']=='h2' else ' / Hinf')
        examples.append(label+f" & {c['degree']} & {c['rho']:g} & "+(num(r['bound']) if r['status'] in accepted else '--')+' & '+(num(r.get('sample_lower_bound')) if r['status'] in accepted else '--')+r' \\')
issues=[]
for r in records:
    if r['status'] in ['feasible_solver_warning','numerical_check_failed']:
        c=r['case'];issues.append(f"{c['domain']} / {c['n']} / {c['N']} / {c['i']} & {c['degree']} & {c['rho']:g} & "+num(r['residual'])+' & '+('Com ressalva' if r['status']=='feasible_solver_warning' else 'Rejeitado')+r' \\')
previous=Path((out/'previous_campaign.txt').read_text())
old=json.loads((previous/'opt_results.json').read_text())
oldcounts=Counter(r['status'] for r in old);counts=Counter(r['status'] for r in records)
certs=json.loads((out/'quadratic_certificates.json').read_text())
inventory=json.loads((out/'inventory.json').read_text())
good=[r for r in records if r['status'] in accepted]
comparison=[]
labels=['Aprovado sem aviso','Resíduos aprovados, com aviso','Diagnóstico de inviabilidade','Rejeitado nos resíduos','Aviso sem solução aceita','Erro de execução']
for name,label in zip(statuses+['solver_warning','error'],labels):comparison.append(label+f" & {oldcounts[name]} & {counts[name]}"+r' \\')
# Do not compare cost changes as performance improvements: the systems changed.
with (out/'comparacao_campanhas.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['id','previous_status','current_status']);oldmap={r['id']:r for r in old}
 for r in records:w.writerow([r['id'],oldmap[r['id']]['status'],r['status']])
source=r'''\documentclass[10pt,a4paper]{article}
\usepackage[utf8]{inputenc}\usepackage[T1]{fontenc}\usepackage[brazil]{babel}
\usepackage[margin=2.2cm]{geometry}\usepackage{amsmath,amssymb,booktabs,longtable,array}
\usepackage[hidelinks]{hyperref}\setlength{\emergencystretch}{3em}
\title{Validação e tempo de parser do ROLMIP Opt 3.4}
\author{Comparação funcional e verificação numérica}\date{18 de outubro de 2026}
\begin{document}\maketitle
\section{Resultado e comparação}
Foram repetidas as 420 condições de custos garantidos $H_2$ e $H_\infty$,
com a mesma configuração da campanha anterior. Todos os modelos afins da
versão Opt coincidiram exatamente com os modelos da referência, incluindo
termos constantes, variáveis de decisão e dimensões dos blocos.
A coluna ``com medição'' abaixo resume a resolução direta de cada problema.
Um certificado adicional, transferido e verificado independentemente, resolveu
a única pendência de factibilidade. Assim, foram obtidos limites com resíduos
aprovados para os 420 casos, com as ressalvas numéricas descritas adiante.
\begin{center}\begin{tabular}{lrr}\toprule
Classificação & Campanha anterior & Com medição\\\midrule
@@COMPARISON@@
\bottomrule\end{tabular}\end{center}
Esta repetição usa as mesmas bases quadraticamente estáveis da campanha
anterior. Foram adicionados os comandos de medição; os algoritmos polinomiais
permaneceram inalterados. A comparação de desempenho entre as versões GitHub
e Opt usa medições repetidas separadas, descritas adiante.
\begin{center}\small\begin{tabular}{lrrrr}\toprule
Ensaio & Aprovado & Com aviso & Inviável & Rejeitado\\\midrule
@@ROWS@@
\bottomrule\end{tabular}\end{center}
``Com aviso'' significa resíduos aprovados apesar de aviso numérico do solver;
nesse caso, não se afirma convergência ao ótimo. ``Inviável'' designa o
diagnóstico para a condição suficiente, e não prova de instabilidade do
sistema. Custos de soluções rejeitadas não são publicados no CSV como limites
aceitos. Não houve relaxamento dos critérios de aceitação dos resíduos.

\section{Dados e estabilidade quadrática}
Foram lidos 80 sistemas contínuos e 80 discretos pela indexação
\texttt{BASE\{n,N,i\}.sys}, com $n,N=2,\ldots,5$ e $i=1,\ldots,5$.
As duas bases foram reutilizadas sem alteração desde a última validação.
Na preparação daquela campanha, a base discreta foi copiada de
\path{/home/ricfow/Dropbox/MatLab/LMIsolver/bench/baseSis_d.mat}.
A origem e os hashes dos arquivos efetivamente usados estão registrados.
Nenhum arquivo MAT de entrada foi alterado nesta execução.

Uma auditoria independente do ROLMIP buscou uma matriz comum $Q$ para cada
família, minimizando $\operatorname{tr}Q$, com $Q\succeq I$ e, em cada vértice,
\[
-A_j^TQ-QA_j\succeq I\quad\text{(contínuo)},\qquad
Q-A_j^TQA_j\succeq I\quad\text{(discreto)}.
\]
Foram aprovados @@CERTS@@ certificados entre 160, com verificação direta dos
autovalores das matrizes retornadas. A menor folga relativa ao lado direito
$I$ foi @@CERTRES@@; o critério admitiu erro absoluto de até $10^{-6}$.
Como a desigualdade física possui margem unitária, esses pequenos erros não
comprometem a positividade observada. Os certificados $Q$ estão salvos em
\path{quadratic_certificates.json}. A verificação é numérica, não intervalar.
No discreto, a convexidade matricial de $A^TQA$ estende a condição dos
vértices ao politopo; no contínuo a extensão segue da afinidade em $A$.

Os @@DNONZERO@@ sistemas contínuos possuem transmissão direta não nula.
Por isso, os testes $H_2$ contínuos continuam usando variantes com $D=0$
criadas somente em memória, conforme autorização anterior. Esses custos não
são custos $H_2$ dos sistemas originais com $D\ne0$. Nos demais testes,
preservou-se o $D$ fornecido. A documentação de
\href{https://www.mathworks.com/help/control/ref/dynamicsystem.norm.html}{\texttt{norm} do MATLAB}
descreve essa limitação da norma $H_2$ contínua.

\section{Configuração e cobertura}
Usaram-se MATLAB R2023b Update 5, YALMIP 20250626, SeDuMi e MPT com cdd.
A referência é \path{ROLMIP_github/rolmip}, incluindo a alteração local de
\texttt{diff.m} já selecionada pelo usuário; a versão avaliada é
\path{ROLMIP_opt_34/rolmip}, com as correções locais anteriores.
Os fontes efetivos estão identificados por SHA-256, e a integridade de
@@FILES@@ arquivos de fontes e bases foi confirmada ao final.
A referência foi montada em um processo MATLAB separado; somente os modelos
Opt foram resolvidos. A comparação abrange todos os coeficientes afins,
não apenas normas calculadas em alguns pontos.

São 105 problemas por domínio e métrica: 80 com $P$ comum, 16 com $P$ afim
congelado, 8 com $P$ afim e variação limitada e 1 com Pólya de ordem 1.
No total: 320 condições comuns, 64 afins congeladas, 32 com taxa e 4 com Pólya.
Os ensaios afins usam $i=1$. Os ensaios com taxa usam dois vértices, ordens
2 a 5, taxas contínuas $|\dot\alpha_j|\leq0{,}1$ ou $1$ e incrementos discretos
$|\alpha_j(k+1)-\alpha_j(k)|\leq0{,}2$ ou $0{,}5$. As somas das coordenadas
são preservadas. Os testes Pólya usam $n=N=2$, $i=1$.
Os valores de taxa são parâmetros de teste, não dados físicos das bases.
Com $P$ comum, as condições são suficientes também para variação arbitrária;
com $P$ afim e sem transformação de taxa, o parâmetro é congelado.

@@CONDITIONS@@
\section{Verificação das soluções}
A diferença entre os modelos afins foi exatamente zero nos 420 casos.
A avaliação direta das expressões matriciais, com matrizes interpoladas,
foi comparada com a avaliação dos polinômios do ROLMIP, antes e depois de
resolver os problemas. O maior erro relativo antes da resolução foi
@@FORMULA@@; entre as soluções aceitas, após a resolução, foi @@SOLVED@@.
Exigiram-se resíduos mínimos absoluto e normalizado de pelo menos $-10^{-7}$
em todos os coeficientes matriciais das restrições, e resíduo pontual
normalizado de pelo menos $-10^{-7}$. A normalização usa $1+\|M\|_2$.
O erro das fórmulas após a resolução deve ser inferior a $10^{-8}$.
O menor resíduo absoluto entre as soluções aceitas foi @@RESIDUAL@@.
Esses testes são em ponto flutuante; não são certificação intervalar.

As normas LTI foram calculadas com \texttt{ss} e \texttt{norm} em vértices,
centro e três pontos aleatórios com semente fixa. O custo retornado deve ser
maior que o máximo amostrado, com tolerância $10^{-5}\max(1,\text{máximo amostrado})$.
A amostragem é uma conferência adicional, não prova do máximo global nem
substituto da verificação de todos os coeficientes. A restrição escalar de
traço não recebe margem explícita; seus últimos dígitos devem ser interpretados
com a tolerância numérica adotada.
A primeira resolução usa \texttt{sedumi.eps=1e-8}, até 150 iterações.
@@RETRY@@

@@ISSUESECTION@@
\subsection{Certificado adicional para o caso rejeitado pelo solver}
No sistema discreto $n=4,N=2,i=1$, a minimização com $P$ afim e parâmetro
congelado retornou aviso numérico e resíduo $-1{,}32234\times10^{-7}$,
ligeiramente abaixo do limite $-10^{-7}$. Isso não foi classificado como
inviabilidade. Para verificar a existência de solução, reutilizou-se o
certificado calculado para o mesmo sistema com incremento limitado a
$\rho=0{,}2$. Uma trajetória constante é admissível nessa condição.

O vetor de decisões foi aplicado à matriz afim completa do problema
congelado, verificando novamente todos os coeficientes. Também se verificaram
diretamente as matrizes físicas e as normas LTI amostradas com os coeficientes
de $P$ salvos. O resultado foi aprovado, com custo
$\gamma=@@TRANSFERBOUND@@$ e resíduo absoluto @@TRANSFERRES@@.
Não se afirma que esse valor seja o ótimo do problema congelado.
A saída rejeitada da minimização foi preservada; o certificado adicional
está em \path{transferred_certificate.json} e \path{transferred_certificate.mat}.
O CSV inclui seu custo e sua origem em colunas suplementares, sem substituir
a classificação da tentativa original.

\section{Reprodução e interpretação}
Os scripts em \path{ROLMIP_opt_34/validation} e os arquivos MAT de resultados
permitem reproduzir e inspecionar cada caso. Os resumos JSON retêm os valores
brutos do solver; a tabela \path{resultados.csv} omite custos rejeitados.
A tabela \path{comparacao_campanhas.csv} compara a classificação de cada
identificador, e \path{previous_campaign.txt} identifica a campanha arquivada.
As bases são as mesmas na campanha anterior e nesta repetição; os
identificadores correspondem às mesmas matrizes.

Esta execução valida a preservação dos modelos nos casos cobertos, incluindo
\texttt{diff}, \texttt{discshift}, \texttt{simpltransf}, produtos, traço,
concatenação, homogeneização, Pólya e avaliação. Os tempos de parser
comparativos são apresentados na seção específica e no anexo; não devem ser
confundidos com os tempos isolados de montagem e resolução da validação.
A cobertura de taxa restringe-se a dois vértices e $P$ afim. Graus maiores,
mais vértices com taxa, outros solvers e exportação de código exigem testes
adicionais. As condições são suficientes e podem ser conservadoras; mesmo
quando resolvidas, seus ótimos não precisam coincidir com a norma robusta exata.
\end{document}
'''
def sci(v):return '$'+('%.3e'%v).replace('e',r'\times10^{')+'}$'
issueblock=''
if issues:
 issueblock=r'\subsection{Casos com ressalvas numéricas}\begin{center}\small\begin{tabular}{lrrrl}\toprule Domínio/$n$/$N$/$i$ & Grau & $\rho$ & Resíduo & Resultado\\\midrule'+'\n'+'\n'.join(issues)+r'\bottomrule\end{tabular}\end{center}'
retryfiles=list((out/'initial_warnings').glob('*.mat'))
replacements={'COMPARISON':'\n'.join(comparison),'ROWS':'\n'.join(rows),'CERTS':str(sum(c['passed'] for c in certs)),'CERTRES':sci(min(c['residual'] for c in certs)),'DNONZERO':str(sum(r['domain']=='c' and r['Dmax']>0 for r in inventory)),'FILES':str(len(checks)),'CONDITIONS':(Path(__file__).parent/'conditions.tex').read_text(),'FORMULA':sci(max(r['formula_error'] for r in records)),'SOLVED':sci(max(r['solved_formula_error'] for r in good)),'RESIDUAL':sci(min(r['residual'] for r in good)),'TRANSFERBOUND':num(transfer['bound']),'TRANSFERRES':sci(transfer['residual']),'ISSUESECTION':issueblock,'RETRY':('Não foi necessário repetir casos por aviso do solver.' if not retryfiles else f'{len(retryfiles)} casos foram repetidos com tolerância do solver $10^{{-7}}$ e até 300 iterações; as primeiras tentativas foram preservadas. Os critérios de aceitação não foram alterados.')}
for k,v in replacements.items():source=source.replace('@@'+k+'@@',v)
assert '@@' not in source
from report_timing import build_timing_report
timing_section,appendix,timing_summary=build_timing_report(out)
source=source.replace(r'\section{Reprodução e interpretação}',timing_section+'\n'+r'\section{Reprodução e interpretação}')
source=source.replace(r'\end{document}',appendix+'\n'+r'\end{document}')
(out/'relatorio/main.tex').write_text(source)
print(json.dumps(timing_summary['total'],indent=2))
print(counts);print('Integrity checks:',len(checks),'all passed')
