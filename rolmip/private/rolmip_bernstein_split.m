function [left,right] = rolmip_bernstein_split(coefficients)
% de Casteljau subdivision at the midpoint. One coefficient per column.
left = coefficients;
right = coefficients;
count = size(coefficients,2);
for j = 2:count
    coefficients = coefficients(:,1:end-1)/2 + coefficients(:,2:end)/2;
    left(:,j) = coefficients(:,1);
    right(:,count-j+1) = coefficients(:,end);
end
end
