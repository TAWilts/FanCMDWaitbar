# FanCmdWaitbar

A lightweight, **tqdm-inspired command-line progress bar for MATLAB**.

Available at [GitHub](https://github.com/TAWilts/FanCMDWaitbar) or at [Matlab file exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar)

`FanCmdWaitbar` provides a clean, single-line progress display in the MATLAB Command Window, including percentage, iteration count, optional timing, and dynamic topic display — without cluttering the console.
<img width="1578" height="334" alt="Aufzeichnung 2026-04-26 222541_2" src="https://github.com/user-attachments/assets/b6eed798-adeb-43df-bedc-47f8ee38173e" />


---

## ✨ Features

- ✅ Single-line progress bar (no console spam)
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
---

## ⚙️API

Constructor:

    wb = FanCmdWaitbar(endIdx, Name, Value)

Required:
- endIdx — final iteration index

Optional:
- startIdx (default: 1)
- showTime (default: true)
- title (default: '')

Step function:

    wb.step()
    wb.step(i)
    wb.step(i, currentTopic)
    wb.step([], currentTopic)

Behaviour:
- No argument → auto-increment
- i provided → set explicit progress
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

## 🤝Contributing

Feel free to open issues or pull requests for improvements.
