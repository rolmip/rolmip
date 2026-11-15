X = sdpvar(2,2,'symmetric');
P = rolmipvar({{[2 0],X},{[1 1],eye(2)},{[0 2],X+eye(2)}},'P',2,2);
[F,origin] = rolmip_lmi(P,'>=','P positivity');
for k = 1:numel(origin.entries)
    entry = origin.entries(k);
    fprintf('Exponents %s -> constraint %s\n', ...
        mat2str(entry.exponents{1}),mat2str(entry.constraint_index));
end
