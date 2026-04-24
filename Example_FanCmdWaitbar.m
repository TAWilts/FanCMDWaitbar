% Checkout the [Matlab File Exchange](https://de.mathworks.com/matlabcentral/fileexchange/183723-fancmdwaitbar) 
% or [GitHub](https://github.com/tawilts/FanCmdWaitbar) for more information and updates. 
%
% Author: T. A. Wilts
% License: MIT
clc
clear all

topic = ["cleaning dishes","listening to protovibe","cycling","watching TV","beeing fancy"];

fprintf('Simple \n')
wb = FanCmdWaitbar(50,'startIdx',1,'title','Training');
for k = 1:50
  pause(0.2)
  wb.step([], topic(floor((k-1)/10)+1));
end

fprintf('Multistep \n')

iter = 5;
wb = FanCmdWaitbar(iter,'startIdx',1,'title','Training');
for k = 1:iter
  wb.step(k, "thinking about "+topic(k));
  pause(1)
  wb.step(k, "do "+topic(k));
  pause(1)
  wb.step(k, "regretting "+topic(k));
  pause(1)
end

fprintf('Nested \n')

iter = 4;
wb = FanCmdWaitbar(iter*3+1,'startIdx',1,'title','Training');
for k = 1:iter
  wb.step([], "thinking about "+topic(k));
  doSomething()
  wb.step([], "do "+topic(k));
  doSomething()
  wb.step([], "regretting "+topic(k));
  doSomething()
end
wb.step([], "done!");



function doSomething()
    wb = FanCmdWaitbar(10,showTime=false);
    for i = 1:10
      pause(0.2)
      wb.step();
    end
    wb.clc()
end