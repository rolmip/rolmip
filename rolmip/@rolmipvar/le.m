function LMIs = le(lhs, rhs)
%LE Construct coefficient inequalities; optionally collect diagnostics.
  collecting=rolmip_check_session('active');
  id=[];
  try
    LMIs = [];
    h = homogenize(lhs, rhs);
    if collecting
        id=rolmip_check_session('pair',h{1},h{2},'<=');
    end
    for i = 1:length(h{1}.data)
        LMIs = LMIs + (h{1}.data(i).value <= h{2}.data(i).value);
    end
  catch err
    if collecting,rolmip_check_session('failure',err,'<=',id);end
    rethrow(err);
  end
end
