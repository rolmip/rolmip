function plot_operations
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));out=fullfile(root,'output','opt34-operation-benchmark');s=jsondecode(fileread(fullfile(out,'summary.json')));
names={'multiply','homogenize','constraints','yalmip_only'};labels={'Multiplicação','Homogeneização','Restrições ROLMIP','YALMIP direto'};
f=figure('Visible','off','Color','w','Position',[100 100 1100 480]);tiledlayout(1,2,'Padding','compact');
nexttile;hold on;for k=1:4,r=s.by_degree(strcmp({s.by_degree.operation},names{k}));plot([r.degree],[r.ratio],'-o','LineWidth',1.5,'DisplayName',labels{k});end
yline(1,':','HandleVisibility','off');grid on;xlim([-.1 4.1]);xticks(0:4);xlabel('Grau de P');set(gca,'YScale','log');ylim([.8 13]);ylabel('Razão GitHub / Opt (log)');legend('Location','southoutside','NumColumns',2);title('Razão entre somas das medianas');
nexttile;v=[[s.operations.github_mean_ms]',[s.operations.opt_mean_ms]'];bar(v);set(gca,'YScale','log');ylim([.1 30]);xticks(1:4);xticklabels(labels);xtickangle(20);ylabel('Tempo médio por operação (ms, log)');legend('GitHub','Opt 3.4','Location','northwest');grid on;title('Média das medianas por caso');
exportgraphics(f,fullfile(out,'relatorio','operations.pdf'),'ContentType','vector');exportgraphics(f,fullfile(out,'relatorio','operations.png'),'Resolution',180);close(f);
end
