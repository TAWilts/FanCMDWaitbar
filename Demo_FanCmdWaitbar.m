% Checkout the [Matlab File Exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar) 
% or [GitHub](https://github.com/tawilts/FanCmdWaitbar) for more information and updates. 
%
% Author: T. A. Wilts
% License: MIT
clc
clear all

topic = ["cleaning dishes","listening to protovibe","cycling","watching TV","beeing fancy"];

fprintf('Simple\n')
iter = 20;
wb = FanCmdWaitbar(iter,'startIdx',1,'title','Training');
for k = 1:20
  pause(0.2)
  wb.step([], topic(floor((k-1)/4)+1));
end
wb.step("s", "done!");


fprintf('Multistep \n')

iter = 3;
wb = FanCmdWaitbar(iter,'startIdx',1,'title','Training');
for k = 1:iter
  wb.step(k, "thinking about "+topic(k));
  pause(0.3)
  wb.step(k, "do "+topic(k));
  pause(0.3)
  wb.step(k, "regretting "+topic(k));
  pause(0.3)
end
wb.step("s", "done!");

fprintf('Nested \n')

iter = 2;
wb = FanCmdWaitbar(iter*3,'startIdx',1,'title','Training');
for k = 1:iter
  wb.step([], "thinking about "+topic(k));
  doSomething()
  wb.step([], "do "+topic(k));
  doSomething()
  wb.step([], "regretting "+topic(k));
  doSomething()
end
wb.step("s", "done!");

fprintf('Status \n')

iter = 5;
wb = FanCmdWaitbar(iter,'startIdx',1,'title','Training');
for k = 1:iter
  wb.step("s", "thinking about "+topic(k)); % or "status"
  pause(0.8)
  wb.step("s", "do "+topic(k));
  pause(0.8)
  wb.step("s", "regretting "+topic(k));
  pause(0.8)
  wb.step([], "done with "+topic(k));
end
wb.step("s", "done!");


function doSomething()
    wb = FanCmdWaitbar(10,showTime=false);
    for i = 1:10
      pause(0.1)
      wb.step();
    end
    wb.clc()
end



fprintf('Vector style: some worker \n')
N = 10;
NVec = randperm(N);
wb = FanCmdWaitbar(N, title="Send the minions",barStyle="vector");
for k = NVec
    pause(randi(5)*0.1)
    wb.step(k,sprintf('minion %d died', k))
end

fprintf('Vector style: many worker  \n')
N = 100;
NVec = randperm(N);
wb = FanCmdWaitbar(N, title="Send the minions",barStyle="vector");
for k = NVec
    pause(randi(5)*0.02)
    wb.step(k,sprintf('minion %d died', k))
end

fprintf('Vector style parfor with states \n')
N = 50;
wb = FanCmdWaitbar(N, title="Converting Images",mode="parfor",barStyle="vector",vectorDoneChar='S');
parfor k = 1:N
    pause(randi(20) * 0.05)
    wb.step(k,[],'L')
    pause(randi(20) * 0.05)
    wb.step(k,[],'P')
    pause(randi(20) * 0.05)
    wb.step(k,sprintf('img %d processed', k),'S')
end

