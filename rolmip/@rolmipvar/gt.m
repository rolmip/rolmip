function LMIs = gt(lhs, rhs)
%GT (overloaded greater than)
%
%ROLMIPopt: o YALMIP moderno nao aceita desigualdades estritas (erro).
%Como historicamente o YALMIP sempre converteu estritas em nao estritas,
%o ROLMIPopt constroi a restricao com >= e emite um aviso (desative com
%warning('off','ROLMIPopt:strict')). Para margem estrita, some um termo
%eps*eye ao polinomio.
  warning('ROLMIPopt:strict', ...
      'Desigualdade estrita convertida em nao estrita (>=).');
  LMIs = ge(lhs, rhs);
end
