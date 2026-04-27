classdef Test_FanCmdWaitbar < matlab.unittest.TestCase
    % Unit tests for FanCmdWaitbar
    %
    % Run with:
    %   results = runtests('Test_FanCmdWaitbar.m');
    %   table(results)
    %
    % Checkout the [Matlab File Exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar) 
    % or [GitHub](https://github.com/tawilts/FanCmdWaitbar) for more information and updates. 
    %
    % Author: T. A. Wilts
    % License: MIT

    methods (Test)
        function constructorRequiresEndIdx(testCase)
            testCase.verifyError(@() FanCmdWaitbar([]), ...
                'FanCmdWaitbar:MissingEndIdx');
        end

        function constructorRejectsInvalidRange(testCase)
            testCase.verifyError(@() FanCmdWaitbar(4, 'startIdx', 5), ...
                'FanCmdWaitbar:InvalidRange');
        end

        function constructorRejectsInvalidMode(testCase)
            testCase.verifyError(@() FanCmdWaitbar(5, 'mode', 'invalidMode'), ...
                'FanCmdWaitbar:InvalidMode');
        end

        function constructorAcceptsDefaultMode(testCase)
            out = evalc('wb = FanCmdWaitbar(5, ''mode'', ''default''); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0.00%'));
        end

        function constructorPrintsInitialState(testCase)
            out = evalc('wb = FanCmdWaitbar(5); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('00:00:00<--:--:--'));
        end

        function constructorPrintsTitle(testCase)
            out = evalc('wb = FanCmdWaitbar(5, ''title'', ''Loading''); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('Loading |'));
        end

        function showTimeFalseOmitsTimeString(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(3, ''showTime'', false);' newline ...
                'wb.step();' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyFalse(contains(finalOut, 'Total~'));
            testCase.verifyFalse(contains(finalOut, '<'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/3'));
        end

        function autoIncrementCompletes(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(3);' newline ...
                'wb.step();' newline ...
                'wb.step();' newline ...
                'wb.step();' newline ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('3/3'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
            testCase.verifyEqual(out(end), newline);
        end

        function explicitIndexWorks(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10);' newline ...
                'wb.step(4);' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('4/10'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('40.00%'));
        end

        function stepWithTopicWorks(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10);' newline ...
                'wb.step(2, ''topicA'');' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/10'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('topicA'));
        end

        function autoIncrementWithTopicWorks(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(4);' newline ...
                'wb.step([], ''abc'');' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/4'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('abc'));
        end

        function stepClampsBelowStartIdx(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(8, ''startIdx'', 5);' newline ...
                'wb.step(1);' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % start=5, end=8 => totalSteps = 4
            % step(1) is clamped to startIdx => doneSteps = 1
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/4'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('25.00%'));
        end

        function repeatedOrLowerExplicitIndexDoesNotCrash(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10);' newline ...
                'wb.step(5, ''first'');' newline ...
                'pause(0.01);' newline ...
                'wb.step(5, ''repeat'');' newline ...
                'wb.step(4, ''lower'');' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % The class should allow repeated/lower explicit indices and keep rendering.
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('4/10'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('lower'));
        end

        function stepAtEndFinishes(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5);' newline ...
                'wb.step(5, ''done'');' newline ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('5/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('done'));
            testCase.verifyEqual(out(end), newline);
        end

        function stepAboveEndClampsAndFinishes(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5);' newline ...
                'wb.step(99);' newline ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('5/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
            testCase.verifyEqual(out(end), newline);
        end

        function stepAfterFinishDoesNothing(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(2);' newline ...
                'wb.step(2);' newline ...
                'wb.step(2, ''SHOULD_NOT_APPEAR'');' newline ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/2'));
            testCase.verifyFalse(contains(finalOut, 'SHOULD_NOT_APPEAR'));
        end

        function deleteBeforeFinishAddsNewline(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10);' newline ...
                'wb.step(2);' newline ...
                'delete(wb);' ...
            ]);

            testCase.verifyEqual(out(end), newline);
        end

        function clcClearsCurrentProgressLine(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10, ''title'', ''ClearTest'');' newline ...
                'wb.step(3, ''visibleBeforeClear'');' newline ...
                'wb.clc();' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % clc() backspaces over the last printed line and resets the stored length.
            testCase.verifyFalse(contains(finalOut, 'visibleBeforeClear'));
            testCase.verifyFalse(contains(finalOut, 'ClearTest'));
        end

        function clcCanBeCalledMultipleTimes(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(10);' newline ...
                'wb.clc();' newline ...
                'wb.clc();' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyEqual(string(finalOut), "");
        end

        function longTopicDoesNotCrash(testCase)
            longTopic = repmat('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 1, 8);
            cmd = sprintf([ ...
                'wb = FanCmdWaitbar(5, ''title'', ''Demo'');' newline ...
                'wb.step(2, ''%s'');' newline ...
                'delete(wb);' ], longTopic);

            out = evalc(cmd);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('Demo |'));
            testCase.verifyNotEmpty(finalOut);
        end

        function stringInputsAreAccepted(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, title="StringTitle", mode="default");' newline ...
                'wb.step(2, "StringTopic");' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('StringTitle |'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('StringTopic'));
        end

        function nonFiniteIndexIsRejected(testCase)
            wb = FanCmdWaitbar(5);
            c = onCleanup(@() delete(wb)); %#ok<NASGU>

            didError = false;
            try
                wb.step(NaN);
            catch
                didError = true;
            end

            testCase.verifyTrue(didError);
        end

        function parforModeCanBeConstructed(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            out = evalc('wb = FanCmdWaitbar(5, ''mode'', ''parfor'', ''title'', ''Parallel''); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('Parallel |'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
        end

        function parforModeStepWithExplicitIndexWarns(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            wb = FanCmdWaitbar(5, 'mode', 'parfor');
            c = onCleanup(@() delete(wb)); %#ok<NASGU>

            testCase.verifyWarning(@() wb.step(1, 'topic'), ...
                'FanCmdWaitbar:stepInParfor');
        end

        function parforModeStepWithoutIndexDoesNotWarn(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            wb = FanCmdWaitbar(5, 'mode', 'parfor');
            c = onCleanup(@() delete(wb)); %#ok<NASGU>

            testCase.verifyWarningFree(@() wb.step([], 'topic'));
        end

        function parforModeUpdatesViaDataQueue(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            out = evalc([ ...
                'wb = FanCmdWaitbar(3, ''mode'', ''parfor'', ''title'', ''Parallel'');' newline ...
                'wb.step([], ''workerA'');' newline ...
                'wb.step([], ''workerB'');' newline ...
                'wb.step([], ''workerC'');' newline ...
                'pause(0.5);' newline ...
                'delete(wb);' ...
            ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % DataQueue callbacks are asynchronous. The pause above gives MATLAB
            % time to execute afterEach callbacks on the client.
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('3/3'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
        end
    end

    methods (Static, Access = private)
        function tf = hasParallelToolbox()
            tf = exist('parallel.pool.DataQueue', 'class') == 8 && ...
                 license('test', 'Distrib_Computing_Toolbox');
        end

        function out = normalizeTerminalOutput(raw)
            % Simulate terminal handling of backspace characters so that
            % overwritten progress-bar output can be asserted reliably.

            bs = char(8);
            buf = '';

            for k = 1:numel(raw)
                ch = raw(k);
                if ch == bs
                    if ~isempty(buf)
                        buf(end) = [];
                    end
                else
                    buf(end+1) = ch; %#ok<AGROW>
                end
            end

            out = buf;
        end
    end
end