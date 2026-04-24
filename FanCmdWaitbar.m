classdef FanCmdWaitbar < handle
    % FanCmdWaitbar
    % Simple and fancy tqdm-like command line progress bar for MATLAB.
    %
    % Example 1: automatic increment
    %   wb = FanCmdWaitbar(100);
    %   for k = 1:100
    %       pause(0.05)
    %       wb.step();
    %   end
    %
    % Example 2: explicit index
    %   wb = FanCmdWaitbar(200,'startIdx',1,'title','Training');
    %   for k = 1:200
    %       pause(0.02)
    %       wb.step(k, sprintf('epoch item %d', k));
    %   end
    %
    % Example 3: nested waitbars
    %   wb = FanCmdWaitbar(200,'startIdx',1,'title','Training');
    %   for k = 1:200
    %       wb.step(k, sprintf('epoch item %d', k));
    %       wb2 = FanCmdWaitbar(10,'title','Batch');
    %       for b = 1:10
    %           pause(0.2)
    %           wb2.step()
    %       end
    %       wb2.clc()
    %   end
    %
    % parameters:
    %   'endIdx'    : required
    %
    % optional parameters:
    %   'startIdx'  : default 1  
    %   'showTime'  : default true
    %   'title'     : default ''
    %
    % step(): increment progress
    %  parameters:
    %   step()
    %   step(i)
    %   step(i, currentTopic)
    %   step([], currentTopic)   % auto-increment + topic
    %
    % clc(): clears the last line
    %
    % Notes:
    % - Uses a single command-window line and overwrites it.
    % - Finishes with a newline once progress reaches endIdx.
    %
    % Checkout the [Matlab File Exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar) 
    % or [GitHub](https://github.com/tawilts/FanCmdWaitbar) for more information and updates. 
    %
    % Author: T. A. Wilts
    % License: MIT

    properties (Access = private)
        startIdx (1,1) double = 1
        endIdx   (1,1) double

        showTime (1,1) logical = true
        title    (1,:) char = ''
        
        currentIdx (1,1) double
        startTime datetime

        lastPrintLength (1,1) double = 0
        finished (1,1) logical = false
        clearAfterFinish (1,1) logical = false

        barFillChar  (1,:) char = '='
        barHeadChar  (1,:) char = '>'
        barEmptyChar (1,:) char = ' '
    end

    methods
        function obj = FanCmdWaitbar(endIdx,varargin)
            % Constructor with name-value arguments

            p = inputParser;
            addParameter(p, 'startIdx', 1, @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'showTime', true, @(x) islogical(x) || isnumeric(x));
            addParameter(p, 'title', '', @(x) ischar(x) || isstring(x));
            parse(p, varargin{:});

            if isempty(endIdx)
                error('FanCmdWaitbar:MissingEndIdx', ...
                    'You must provide ''endIdx''.');
            end

            obj.startIdx   = p.Results.startIdx;
            obj.endIdx     = endIdx;
            obj.showTime   = logical(p.Results.showTime);
            obj.title      = char(string(p.Results.title));

            if obj.endIdx < obj.startIdx
                error('FanCmdWaitbar:InvalidRange', ...
                    '''endIdx'' must be >= ''startIdx''.');
            end

            obj.currentIdx = obj.startIdx - 1;
            obj.startTime  = datetime('now');

            obj.render('');
        end

        function step(obj, i, currentTopic)
            % step()                  -> auto increment by 1
            % step(i)                 -> set current progress
            % step(i, currentTopic)   -> set progress + topic
            % step([], currentTopic)  -> auto increment + topic

            if obj.finished
                return
            end

            if nargin < 2 || isempty(i)
                obj.currentIdx = obj.currentIdx + 1;
            else
                validateattributes(i, {'numeric'}, {'scalar','finite'});
                obj.currentIdx = i;
            end

            if nargin < 3 || isempty(currentTopic)
                currentTopic = '';
            else
                currentTopic = char(string(currentTopic));
            end

            if obj.currentIdx < obj.startIdx
                obj.currentIdx = obj.startIdx;
            end

            if obj.currentIdx >= obj.endIdx
                obj.currentIdx = obj.endIdx;
                obj.render(currentTopic);
                fprintf('\n');
                obj.lastPrintLength = obj.lastPrintLength +1;
                obj.finished = true;
            else
                obj.render(currentTopic);
            end

        end

        function delete(obj)
            % Make sure the cursor ends on a clean line
            if ~obj.finished && obj.lastPrintLength > 0
                fprintf('\n');
            end
            
        end
        function clc(obj)
            fprintf(repmat('\b', 1, obj.lastPrintLength));
            obj.lastPrintLength = 0;
        end
    end

    methods (Access = private)
        function render(obj, currentTopic)
            elapsedSeconds = seconds(datetime('now') - obj.startTime);

            totalSteps = obj.endIdx - obj.startIdx + 1;
            doneSteps  = max(0, obj.currentIdx - obj.startIdx + 1);
            doneSteps  = min(doneSteps, totalSteps);

            if totalSteps <= 0
                frac = 1;
            else
                frac = doneSteps / totalSteps;
            end

            percent = 100 * frac;

            idxStr = sprintf(' %d/%d', doneSteps, totalSteps);

            if obj.showTime && doneSteps > 0
                estTotal = elapsedSeconds / doneSteps * totalSteps;
                remaining = max(estTotal - elapsedSeconds, 0);

                timeStr = sprintf(' %s<%s, Total~%s', ...
                    obj.formatTime(elapsedSeconds), ...
                    obj.formatTime(remaining), ...
                    obj.formatTime(estTotal));
            elseif obj.showTime
                timeStr = sprintf(' %s<%s, Total~%s', ...
                    obj.formatTime(0), ...
                    '--:--:--', ...
                    '--:--:--');
            else
                timeStr = '';
            end

            titleStr = strtrim(obj.title);
            if ~isempty(titleStr)
                titleStr = [titleStr ' | '];
            end


            suffixParts = [char(sprintf('%6.2f%%%%', percent)),idxStr,timeStr];

            suffix = [suffixParts, ' | '];

            if ~isempty(currentTopic)
                topicPrefix = ' | ';
            else
                topicPrefix = '';
            end

            cmdWidth = obj.getCommandWindowWidth();

            % Reserve at least a minimum bar width
            minBarWidth = 10;

            % Determine topic width dynamically after bar/suffix placement
            fixedWithoutBar = length(titleStr) + 2 + length(suffix); 
            % 2 for the two '|' around the bar

            availableForBarAndTopic = cmdWidth - fixedWithoutBar;

            if availableForBarAndTopic < minBarWidth + 1
                barWidth = minBarWidth;
                topicStr = '';
            else
                % Use most of the remaining width for the bar,
                % leave some optional room for the topic
                if isempty(currentTopic)
                    barWidth = availableForBarAndTopic-2;
                    topicStr = '';
                else
                    % Keep at least ~25 chars for topic if possible
                    desiredTopic = min(35, max(10, floor(0.25 * cmdWidth)));
                    barWidth = max(minBarWidth, availableForBarAndTopic - length(topicPrefix) - desiredTopic);
                    maxTopicWidth = max(0, cmdWidth - (fixedWithoutBar + barWidth + length(topicPrefix)));
                    topicStr = obj.truncateText(currentTopic, maxTopicWidth);
                    if isempty(topicStr)
                        topicPrefix = '';
                    end
                end
            end

            bar = obj.makeBar(frac, barWidth);

            line = sprintf('%s|%s| %s%s%s', ...
                titleStr, bar, suffix, topicPrefix, topicStr);

            % In case line still became too long, hard-truncate
            if length(line) > cmdWidth
                line = obj.truncateText(line, cmdWidth);
            end


            % Overwrite previous line completely
            if obj.lastPrintLength > 0
                obj.clc();
            end

            fprintf('%s\n', line);
            obj.lastPrintLength = length(line)+1;
        end

        function bar = makeBar(obj, frac, width)
            width = max(1, floor(width));

            filled = floor(frac * width);

            if frac >= 1
                bar = [repmat(obj.barFillChar, 1, width)];
                return
            end

            if filled <= 0
                bar = [obj.barHeadChar repmat(obj.barEmptyChar, 1, width-1)];
            elseif filled >= width
                bar = repmat(obj.barFillChar, 1, width);
            else
                bar = [ ...
                    repmat(obj.barFillChar, 1, max(filled-1,0)), ...
                    obj.barHeadChar, ...
                    repmat(obj.barEmptyChar, 1, width-filled) ...
                ];
            end
        end

        function w = getCommandWindowWidth(~)
            % Fallback-safe command window width
            w = 120;
            try
                sz = matlab.desktop.commandwindow.size;
                % Usually [cols rows]
                w = max(sz);
            catch
                % keep fallback
            end

            % avoid pathological tiny widths
            w = max(w - 1, 60);
        end

        function s = formatTime(~, secs)
            if ~isfinite(secs) || secs < 0
                s = '--:--:--';
                return
            end

            secs = round(secs);
            h = floor(secs / 3600);
            m = floor(mod(secs, 3600) / 60);
            s2 = mod(secs, 60);

            s = sprintf('%02d:%02d:%02d', h, m, s2);
        end

        function txt = truncateText(~, txt, maxLen)
            txt = char(string(txt));

            if maxLen <= 0
                txt = '';
                return
            end

            if length(txt) <= maxLen
                return
            end

            if maxLen <= 3
                txt = txt(1:maxLen);
            else
                txt = [txt(1:maxLen-3) '...'];
            end
        end
    end
end