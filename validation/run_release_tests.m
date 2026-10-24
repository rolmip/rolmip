function run_release_tests
%RUN_RELEASE_TESTS Final checks, with only this ROLMIP on the MATLAB path.
% Add YALMIP and SeDuMi beforehand. Both are required to avoid silent skips
% of the generated-file solve. Run in a fresh MATLAB session, not during export.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'rolmip'));
assert(~isempty(which('sdpvar')), 'YALMIP must be on the MATLAB path.');
assert(~isempty(which('sedumi')), 'SeDuMi must be on the MATLAB path.');
fprintf('MATLAB: %s\n',version);
fprintf('YALMIP: %s\n',yalmip('version'));
rolmipopt_test;
rolmipopt_regression_test;
rolmipopt_memory_test;
test_parser_timer;
fprintf('FINAL_RELEASE_CHECK_PASSED\n');
end
