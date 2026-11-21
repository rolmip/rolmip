function LMIs = lt(lhs, rhs)
%LT (overloaded less than)
%
%ROLMIPopt: o YALMIP moderno nao aceita desigualdades estritas (erro).
%A restricao e construida com <= e um aviso e emitido (desative com
%warning('off','ROLMIPopt:strict')). Para margem estrita, some um termo
%eps*eye ao polinomio.
  warning('ROLMIPopt:strict', ...
      'Desigualdade estrita convertida em nao estrita (<=).');
  LMIs = le(lhs, rhs);
end
