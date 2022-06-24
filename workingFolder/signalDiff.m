
input1 = test(2, 1).results.stat_summary(2).yci;  % Non-canc
input2 = test(2, 1).results.stat_summary(1).yci;  % Canc

clear binaryDiff
for time = 1:length(input1)
    
    binaryDiff(1,time) = input1(2,time) < input2(1,time);
    
end

diffTimes = find(binaryDiff == 1)-500;
diffTimes = diffTimes(diffTimes > -250 & diffTimes < 500);
min(diffTimes)