wb = FanCmdWaitbar(50,'startIdx',1,'title','Training');
topic = ["cleaning dishes","listening to protovibe","cycling","watching TV","beeing fancy"];
for k = 1:50
  pause(0.2)
  wb.step(k, topic(floor((k-1)/10)+1));
end

wb = FanCmdWaitbar(5*3,'startIdx',1,'title','Training');
for k = 1:5
  wb.step([], "thinking about "+topic(k));
  pause(1)
  wb.step([], "do "+topic(k));
  pause(1)
  wb.step([], "regretting "+topic(k));
  pause(1)
end