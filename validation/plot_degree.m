function plot_degree
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-degree-benchmark');s=jsondecode(fileread(fullfile(out,'summary.json')));
f=figure('Visible','off','Color','w','Position',[100 100 1100 400]);tiledlayout(1,2,'Padding','compact');
nexttile;semilogy([s.degrees.degree],1000*[s.degrees.github_mean_s],'-o','LineWidth',1.6);hold on;semilogy([s.degrees.degree],1000*[s.degrees.opt_mean_s],'-s','LineWidth',1.6);grid on;xlim([-.1 4.1]);ylim([7 300]);xticks(0:4);xlabel('Grau de P');ylabel('Tempo médio por caso (ms, escala log)');legend('GitHub','Opt 3.4','Location','northwest');title('Média das medianas, 64 casos por grau');
nexttile;hold on;
for N=2:5
 g=s.by_vertices([s.by_vertices.N]==N);plot([g.degree],[g.ratio],'-o','LineWidth',1.6,'DisplayName',sprintf('%d vértices',N));
end
grid on;xlim([-.1 4.1]);ylim([1.5 2.9]);xticks(0:4);xlabel('Grau de P');ylabel('Razão GitHub / Opt');legend('Location','northwest');title('Razão entre somas das medianas');
exportgraphics(f,fullfile(out,'relatorio','degree_scaling.pdf'),'ContentType','vector');exportgraphics(f,fullfile(out,'relatorio','degree_scaling.png'),'Resolution',180);close(f);
end
