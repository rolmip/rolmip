function S = round(X)
%ROUND (overloaded)
%
% Update: Cristiano M. Agulhari
% 2021, Apr, 29
%
% Apply round on every data
 
  if length(X.data) == 1
      S = round(X.data(1).value);
  else
      S = X;
      for cont=1:length(S.data)
          S.data(cont).value = round(S.data(cont).value);
      end
  end
return 