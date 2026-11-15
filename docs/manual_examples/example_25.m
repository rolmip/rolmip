function out = example_25
% Example 25. Generate LaTeX for a polynomial expression.
oldMode = rolmipopt('codegen');
restoreMode = onCleanup(@() rolmipopt('codegen',oldMode));
rolmipopt('codegen','on');
Ai = rolmipvar(2,2,'A','full',[2 2],[1 1]);
Pi = rolmipvar(2,2,'P','sym',2,1);
poly = Ai'*Pi + Pi*Ai;
names = {'\alpha','\beta'};
out.explicit = texify(poly,'explicit',Ai,Pi,names);
out.grouped = texify(poly,'explicit',Ai,Pi,'\alpha');
out.implicit = texify(poly,'implicit',Ai,Pi);
out.polynomial = texify(poly,'polynomial',Ai,Pi,names);
end
