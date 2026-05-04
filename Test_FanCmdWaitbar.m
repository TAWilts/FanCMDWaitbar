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

        function constructorRejectsInvalidBarStyle(testCase)
            testCase.verifyError(@() FanCmdWaitbar(5, 'barStyle', 'invalid'), ...
                'FanCmdWaitbar:InvalidBarStyle');
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

        function vectorStyleConstructorWorks(testCase)
            out = evalc('wb = FanCmdWaitbar(5, ''barStyle'', ''vector'', ''showTime'', false, ''title'', ''Vector''); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('Vector |'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0.00%'));
        end

        function vectorStyleNonSequentialIndexCountsMarkedItems(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''barStyle'', ''vector'', ''showTime'', false);' newline ...
                'wb.step(3);' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % In vector mode, step(3) marks one item; it must not imply 3/5.
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('20.00%'));
        end

        function vectorStyleMultipleIndicesAreCounted(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''barStyle'', ''vector'', ''showTime'', false);' newline ...
                'wb.step(1);' newline ...
                'wb.step(3);' newline ...
                'wb.step(4);' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('3/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('60.00%'));
        end

        function vectorStyleRepeatedIndexIsNotDoubleCounted(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''barStyle'', ''vector'', ''showTime'', false);' newline ...
                'wb.step(3, ''first'');' newline ...
                'wb.step(3, ''repeat'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('20.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('repeat'));
        end

        function vectorStyleCustomStepSymbolIsDisplayed(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''barStyle'', ''vector'', ''showTime'', false);' newline ...
                'wb.step(2, '''', ''x'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
            testCase.verifyTrue(contains(finalOut, 'x'));
        end

        function vectorStyleCompletesAfterAllIndicesAreMarked(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(3, ''barStyle'', ''vector'', ''showTime'', false);' newline ...
                'wb.step(3);' newline ...
                'wb.step(1);' newline ...
                'wb.step(2);' newline ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('3/3'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
            testCase.verifyEqual(out(end), newline);
        end

        function vectorStateModeIntermediateStatesDoNotCountAsFinished(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(3, ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'wb.step(1, '''', ''L'');' newline ...
                'wb.step(2, '''', ''P'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % With vectorDoneChar set, only entries with the end symbol count as complete.
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/3'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0.00%'));
            testCase.verifyTrue(contains(finalOut, 'L') || contains(finalOut, 'P'));
        end

        function vectorStateModeEndSymbolCountsAsFinished(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(3, ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'wb.step(1, '''', ''L'');' newline ...
                'wb.step(1, '''', ''S'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('1/3'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('33.33%'));
            testCase.verifyTrue(contains(finalOut, 'S'));
        end

        function vectorStateModeCompletesOnlyWhenAllEndSymbolsAreSet(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(2, ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'wb.step(1, '''', ''L'');' newline ...
                'wb.step(2, '''', ''P'');' newline ...
                'wb.step(1, '''', ''S'');' newline ...
                'wb.step(2, '''', ''S'');' newline ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/2'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
            testCase.verifyEqual(out(end), newline);
        end

        function vectorStateModeGroupedRareStateIsVisible(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(120, ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'for k = 1:120, wb.step(k, '''', ''S''); end' newline ...
                'wb = FanCmdWaitbar(120, ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'for k = 1:119, wb.step(k, '''', ''S''); end' newline ...
                'wb.step(120, '''', ''P'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            % For grouped vector bars, the rare/non-final state should remain visible.
            testCase.verifyTrue(contains(finalOut, 'P'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('119/120'));
        end

        function parforModeCanBeConstructed(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            out = evalc('wb = FanCmdWaitbar(5, ''mode'', ''parfor'', ''title'', ''Parallel''); delete(wb);');
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('Parallel |'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
        end

        function parforBarModeStepWithExplicitIndexWarns(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            wb = FanCmdWaitbar(5, 'mode', 'parfor');
            c = onCleanup(@() delete(wb)); %#ok<NASGU>

            testCase.verifyWarning(@() wb.step(1, 'topic'), ...
                'FanCmdWaitbar:stepInParfor');
        end

        function parforBarModeStepWithoutIndexDoesNotWarn(testCase)
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

        function parforVectorModeAcceptsExplicitIndexWithoutWarning(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            wb = FanCmdWaitbar(5, 'mode', 'parfor', 'barStyle', 'vector');
            c = onCleanup(@() delete(wb)); %#ok<NASGU>

            testCase.verifyWarningFree(@() wb.step(3, 'workerC'));
        end

        function parforVectorStateModeUpdatesViaDataQueue(testCase)
            testCase.assumeTrue(testCase.hasParallelToolbox(), ...
                'Parallel Computing Toolbox is required for parfor mode tests.');

            out = evalc([ ...
                'wb = FanCmdWaitbar(2, ''mode'', ''parfor'', ''barStyle'', ''vector'', ''showTime'', false, ''vectorDoneChar'', ''S'');' newline ...
                'wb.step(1, [], ''L'');' newline ...
                'wb.step(1, [], ''S'');' newline ...
                'wb.step(2, [], ''S'');' newline ...
                'pause(0.5);' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/2'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('100.00%'));
        end

        function statusShortcutDoesNotAdvanceProgress(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''showTime'', false);' newline ...
                'wb.step(2, ''beforeStatus'');' newline ...
                'wb.step(''s'', ''statusOnly'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('40.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('statusOnly'));

            testCase.verifyFalse(contains(finalOut, '3/5'));
            testCase.verifyFalse(contains(finalOut, '60.00%'));
        end

        function statusCommandDoesNotAdvanceProgress(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''showTime'', false);' newline ...
                'wb.step(2, ''beforeStatus'');' newline ...
                'wb.step("status", "longStatusAlias");' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('40.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('longStatusAlias'));

            testCase.verifyFalse(contains(finalOut, '3/5'));
            testCase.verifyFalse(contains(finalOut, '60.00%'));
        end

        function statusBeforeFirstStepDoesNotAdvanceProgress(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5, ''showTime'', false);' newline ...
                'wb.step(''s'', ''waitingBeforeStart'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('0.00%'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('waitingBeforeStart'));

            testCase.verifyFalse(contains(finalOut, '1/5'));
            testCase.verifyFalse(contains(finalOut, '20.00%'));
        end

        function statusUpdateIsExcludedFromTimeEstimation(testCase)
            out = evalc([ ...
                'wb = FanCmdWaitbar(5);' newline ...
                'wb.step(2, ''beforePause'');' newline ...
                'pause(1.2);' newline ...
                'wb.step(''s'', ''afterPauseStatusOnly'');' newline ...
                'delete(wb);' ...
                ]);
            finalOut = testCase.normalizeTerminalOutput(out);

            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('2/5'));
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('afterPauseStatusOnly'));

            % If status updates are excluded from time estimation, the elapsed time
            % should still be based on the previous real progress update.
            testCase.verifyThat(finalOut, matlab.unittest.constraints.ContainsSubstring('00:00:00<'));
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