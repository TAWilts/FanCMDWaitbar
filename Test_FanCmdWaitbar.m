classdef Test_FanCmdWaitbar < matlab.unittest.TestCase
    % Unit tests for FanCmdWaitbar
    %
    % Run with:
    %   results = runtests('FanCmdWaitbarTest.m');
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
    end

    methods (Static, Access = private)
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