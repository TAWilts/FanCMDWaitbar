# FanCmdWaitbar

A lightweight, **tqdm-inspired command-line progress bar for MATLAB**. Especially convenient for projects with e.g. lots of figures that bury the usual graphic ```waitbar()```, nested processes, ```parfor```-loops, CLI standalone applications, or matlab in ```-nodesktop``` mode.

Available at [GitHub](https://github.com/TAWilts/FanCMDWaitbar) or at [Matlab file exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar)

`FanCmdWaitbar` provides a clean, single-line progress display in the MATLAB Command Window, including percentage, iteration count, optional timing, and dynamic topic display — without cluttering the console.
<img width="1866" height="360" alt="Aufzeichnung 2026-04-28 011429" src="https://github.com/user-attachments/assets/7ac810ed-014c-488b-88af-ee6e46c39236" />



---

## ✨ Features

- ✅ Single-line progress bar (no console spam)
- ✅ Supports parfor loops
- ✅ Automatic or manual progress updates
- ✅ Optional elapsed & remaining time estimation
- ✅ Dynamic topic display (e.g. current file, epoch, etc.)
- ✅ Adaptive width (uses full Command Window width)
- ✅ Graceful handling of long text (auto truncation)
- ✅ Clean termination with newline
- ✅ No dependencies

---

## 📦 Installation

Simply copy the file into your MATLAB path:

```matlab
addpath('path/to/FanCmdWaitbar')

```
## 🚀Quick Start

Minimal example (auto-increment):

    wb = FanCmdWaitbar(100);

    for k = 1:100
        pause(0.05)
        wb.step();
    end

With title and topic:

    wb = FanCmdWaitbar(50, 'title', 'Processing');

    for k = 1:50
        pause(0.05)
        wb.step(k, sprintf('file_%03d.png', k));
    end

With custom start index:

    wb = FanCmdWaitbar(20, 'startIdx', 5, 'title', 'Training');

    for k = 5:20
        wb.step(k, sprintf('epoch item %d', k));
    end

Disable timing:

    wb = FanCmdWaitbar(100, 'showTime', false);

Nested waitbars:

    wb = FanCmdWaitbar(200,'startIdx',1,'title','Training');
    for k = 1:200
        wb.step(k, sprintf('epoch item %d', k));
        wb2 = FanCmdWaitbar(10,'title','Batch');
        for b = 1:10
            pause(0.2)
            wb2.step()
        end
        wb2.clc()
    end
    
Parfor loops:

    N = 100;
    wb = FanCmdWaitbar(N, title="Send the minions",mode="parfor");
    parfor k = 1:N
        pause(randi(20) * 0.1)
        wb.step([],sprintf('minion %d', k))
    end
---
### Vector-style progress for non-sequential work

For non-sequential processes, `barStyle="vector"` marks individual indices instead of assuming that progress is strictly ordered.

```matlab
wb = FanCmdWaitbar(5, 'barStyle', 'vector', 'showTime', false);

wb.step(1)              % marks item 1 as done
wb.step(3)              % marks item 3 as done
wb.step(4, '', 'x')     % marks item 4 with custom symbol x
```

This is useful when tasks finish out of order.

---

### Vector-style progress with many items

If there are more logical items than visible command-window columns, multiple items are grouped into one displayed character.

```matlab
N = 100;
order = randperm(N);

wb = FanCmdWaitbar(N, ...
    'title', 'Send the minions', ...
    'barStyle', 'vector');

for k = order
    pause(randi(5) * 0.02)
    wb.step(k, sprintf('minion %d finished', k))
end
```

---

### Vector-style state display

The third argument of `step()` can be used as a state symbol.

If `vectorDoneChar` is changed, only this character counts as completed. Other symbols remain visible as intermediate states.

```matlab
N = 100;

wb = FanCmdWaitbar(N, ...
    'title', 'Converting Images', ...
    'barStyle', 'vector', ...
    'vectorDoneChar', 'S');

for k = randperm(N)
    wb.step(k, [], 'L')                         % loading
    pause(0.05)

    wb.step(k, [], 'P')                         % processing
    pause(0.05)

    wb.step(k, sprintf('img %d saved', k), 'S') % saved / finished
end
```

---

### Vector-style `parfor` progress with states

Vector style is especially useful for `parfor`, because iterations finish out of order.

```matlab
N = 100;

wb = FanCmdWaitbar(N, ...
    'title', 'Converting Images', ...
    'mode', 'parfor', ...
    'barStyle', 'vector', ...
    'vectorDoneChar', 'S');

parfor k = 1:N
    pause(randi(10) * 0.05)
    wb.step(k, [], 'L')

    pause(randi(10) * 0.05)
    wb.step(k, [], 'P')

    pause(randi(20) * 0.05)
    wb.step(k, sprintf('img %d processed', k), 'S')
end
```

When displayed items are grouped and `vectorDoneChar` is custom, the least frequent state in each group is shown. This helps identify the state that a group is likely waiting on.
## ⚙️API

Constructor:

    wb = FanCmdWaitbar(endIdx, Name, Value)

Required:
- endIdx — final iteration index

Optional:
- startIdx (default: 1)
- showTime (default: true)
- title (default: '')
- mode ('default'/'parfor')

Step function:

    wb.step()
    wb.step(i)
    wb.step(i, currentTopic)
    wb.step([], currentTopic)

Behaviour:
- No argument → auto-increment
- i provided → set explicit progress, skip in parfor-mode
- currentTopic → displayed on the right side
- Stops automatically when endIdx is reached

---

## ⏱Time Estimation

When enabled, the bar shows:

    elapsed < remaining, Total ~ estimated_total

Estimation is based on:

    T_total ≈ (elapsed / completed_steps) * total_steps

---

## 🖥Example Output

    Processing |[===========>        ]  42.00%  21/50  00:00:02<00:00:03, Total~00:00:05 | file_021.png

---

## ⚠️Notes

- The progress bar assumes exclusive control over the Command Window line
- Additional fprintf/disp calls may break formatting
- Width detection uses matlab.desktop.commandwindow.size
- Best used in standard desktop MATLAB (not headless)

---

## 🧪Testing

Run:

    runTests_FanCmdWaitbar

---

## 📄License

MIT License

---
## Cite as

If you use this tool in your research or projects, please cite it as:

Thomas Wilts, *FanCmdWaitbar: A lightweight command-line progress bar for MATLAB*, GitHub repository, 2026.  
Available at: https://github.com/YOUR_USERNAME/FanCmdWaitbar

### BibTeX

```bibtex
@misc{wilts2026fancmdwaitbar,
  author       = {Thomas Wilts},
  title        = {FanCmdWaitbar: A lightweight command-line progress bar for MATLAB},
  year         = {2026},
  howpublished = {\url{https://github.com/YOUR_USERNAME/FanCmdWaitbar}},
  note         = {GitHub repository}
}
```
## 🤝Contributing

Feel free to open issues or pull requests for improvements.
