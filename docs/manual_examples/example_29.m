P1 = diag([4 1]);
R = [1 -sqrt(3); sqrt(3) 1]/2;
P2 = R*P1*R';
P3 = R*P2*R';
[area,info] = rolmip_volume({P1,P2,P3},'plot',1,'drawVertices',1, ...
    'NumDirections',720);
xlabel('x1','Interpreter','none');
ylabel('x2','Interpreter','none');
fprintf('Area = %.4f\n',area);
