function results = runTests_FanCmdWaitbar()
% runFanCmdWaitbarTests
% Runs the unit tests for FanCmdWaitbar and prints a compact summary.
%
% Usage:
%   results = runFanCmdWaitbarTests();
%
% Optional:
%   table(results)

    fprintf('Running FanCmdWaitbar tests...\n');

    results = runtests('FanCmdWaitbarTest.m');

    nTotal  = numel(results);
    nPassed = sum([results.Passed]);
    nFailed = sum([results.Failed]);
    nIncomp = sum([results.Incomplete]);

    fprintf('\n');
    fprintf('==============================\n');
    fprintf('FanCmdWaitbar test summary\n');
    fprintf('==============================\n');
    fprintf('Total      : %d\n', nTotal);
    fprintf('Passed     : %d\n', nPassed);
    fprintf('Failed     : %d\n', nFailed);
    fprintf('Incomplete : %d\n', nIncomp);
    fprintf('==============================\n');

    if nFailed > 0 || nIncomp > 0
        fprintf('\nDetailed issues:\n');
        for k = 1:nTotal
            if results(k).Failed || results(k).Incomplete
                fprintf('\n- %s\n', results(k).Name);
                fprintf('  Outcome: %s\n', char(results(k).Outcome));

                if ~isempty(results(k).Details)
                    try
                        fprintf('  Details: %s\n', results(k).Details.DiagnosticRecord.DiagnosticText);
                    catch
                        fprintf('  Details available in results(%d).Details\n', k);
                    end
                end
            end
        end
    else
        fprintf('\nAll tests passed.\n');
    end

    fprintf('\nPer-test overview:\n');
    disp(table(results))
end