function [GraphAreaAv, GraphAreaSD, MathArea] = HysteresisLoopAreaCalc(dataFile, LostStiffness)
%% Import the data
% 'RHH154Posterior_cart-on-boneSub3.dat'
Data = importdata(dataFile);
%Data = Data(:,2:3);
%Data = sortrows(Data,1);
DataForces = Data(:,2)';
DataDisplacement = Data(:,3)';
minForce = min(DataForces);
maxForce = max(DataForces);
initCheck = false;
RegionAroundLimits = 0.002;

%% Split data into individual Loops
Loops = {};
LoopCounter = 1; Counter2 = 1; initCounter = 1;
loopSize = size(DataForces,2);

while(max(DataForces) > 0.1)
    [a,b] = max(DataForces);
    DataForces(:,b) = [];
    DataDisplacement(:,b) = [];
end

% check if the data starts from a local minimum or not.
minCheckCount = 0;
if(DataForces(10) < DataForces(1))
    %init decrease found
    while(minCheckCount == 0 && Counter2 <= loopSize)
            if(abs(DataForces(Counter2) - minForce) < RegionAroundLimits)
                minCheckCount = 1;
            end
            Counter2 = Counter2 + 1;
    end        
end

%remove incorrect values from the loop
%identify the loops based on a peak find function
%flip to find the local minimums

% check if the inital data is starting from a local minimum.
while(Counter2 <= loopSize)
    maxValueFound = 0;
    
    if(abs(DataForces(Counter2) - maxForce) < RegionAroundLimits)
        % Find the limit of the current top arc
        Counter2Save = Counter2;
        while(abs(maxForce - DataForces(Counter2)) <= RegionAroundLimits)
            Counter2 = Counter2 + 1;
        end
        Counter2 = Counter2Save + floor((Counter2 - Counter2Save) / 2);
        Loops{LoopCounter, 1} = [DataForces(1,initCounter:Counter2); DataDisplacement(1,initCounter:Counter2)];
        Counter2 = Counter2 + 1; MaxCounter = Counter2; maxValueFound = 1;
        % find the limit of the current bottom arc
        finalValueFound = 0;
        while(finalValueFound == 0 && Counter2 <= loopSize)
            if(abs(DataForces(Counter2) - minForce) < RegionAroundLimits)
                Counter2Save = Counter2;
                while(abs(minForce - DataForces(Counter2)) <= RegionAroundLimits)
                    Counter2 = Counter2 + 1;
                end
                Counter2 = Counter2Save + floor((Counter2 - Counter2Save) / 2);
                Loops{LoopCounter, 2} = [DataForces(1,MaxCounter:Counter2); DataDisplacement(1,MaxCounter:Counter2)];
                finalValueFound = 1;
            end
            Counter2 = Counter2 + 1;
        end
        % Check for incomplete Final bottom loop
        if(finalValueFound == 0)
            Loops{LoopCounter, 2} = [DataForces(1,MaxCounter:Counter2 - 1); DataDisplacement(1,MaxCounter:Counter2 - 1)];
        end
        % Set values ready for next loop
        LoopCounter = LoopCounter + 1; initCounter = Counter2;
    else
        Counter2 = Counter2 + 1;
    end
    
    %Check for incomplete final top Loop
    if(maxValueFound == 0)
        Loops{LoopCounter, 1} = [DataForces(1,initCounter:Counter2 - 1); DataDisplacement(1,initCounter:Counter2 - 1)];
    end
end

%% Calculate the average values at each point and create the line of best fit.
% Finally have the individual Loops, Calculate the area for each loop and
% plot the deviation.
Areas = [];
for i = 1 : size(Loops,1)
    if size(Loops{i,2},1) ~= 0
        % upper loop
        fitCurveUp = polyfit(Loops{i,1}(1,:), Loops{i,1}(2,:), 5);
        x1 = linspace(minForce,maxForce); y1 = polyval(fitCurveUp, x1);
        minVal = min(y1) - 100; y1 = y1 + abs(minVal); areaUp = trapz(x1, y1);
        % lower loop
        fitCurveLow = polyfit(Loops{i,2}(1,:), Loops{i,2}(2,:), 5);
        y1 = polyval(fitCurveLow, x1); minVal = min(y1) - 100;
        y1 = y1 + abs(minVal); areaDown = trapz(x1, y1);
        Areas(i) = areaUp - areaDown;
    end
end

% Graph area calculation
GraphAreaAv = mean(Areas);
GraphAreaSD = std(Areas);
MathArea = 0.5 * LostStiffness * (2 * pi * 8)^2;
if(GraphAreaAv < 0)
    GraphAreaAv =  0;
    GraphAreaSD = 0; 
    MathArea = 0;
end
