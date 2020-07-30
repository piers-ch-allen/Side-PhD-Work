function [GraphAreaAv, GraphAreaSD, MathArea] = HysteresisCalc2(dataFile, LostStiffness)
%% Import the data
Data = importdata(dataFile);
if(size(Data,1) <= 1)
    Data = importDat(dataFile);
end
DataAxis = Data(:,1)';
DataDisplacement = Data(:,2)';
DataForces = Data(:,3)';

DataDisplacement = DataDisplacement - min(DataDisplacement);
% Remove any incorrect values.
while(max(DataDisplacement) > 0.1)
    [~,b] = max(DataDisplacement);
    DataForces(:,b) = [];
    DataDisplacement(:,b) = [];
    DataAxis(:,b) = [];
end
clearvars a b

%% Identify turning points within the data
% Smooth the graph and find the maixmal turning points
SmoothedData = smooth(DataAxis(1,:),DataForces(1,:),0.05,'loess');
[~,maxLoc] = findpeaks(SmoothedData);
% Find the minmal turning points
[~,minLoc] = findpeaks(-SmoothedData);

%% Calculate peaks and troughs of data and readjust to only include correct span of data.
% Check if initial loop starts from minimum and remove up to first min.
firstMin = minLoc(1,1) - 1;
DataAxis(:,1:firstMin) = [];
DataDisplacement(:,1:firstMin) = [];
DataForces(:,1:firstMin) = [];
% remove a max if it occurs first.
if (maxLoc(1,1) < firstMin)
    maxLoc(1,:) = [];
end
%adjust rest of values to account for changes increments
maxLoc = maxLoc - firstMin;
minLoc = minLoc - firstMin;

% remove excess data after final trough
lastMin = minLoc(size(minLoc,1),1) + 1;
totalSize = size(DataAxis,2);
DataDisplacement(:,lastMin:totalSize) = [];
DataForces(:,lastMin:totalSize) = [];
if (maxLoc(size(maxLoc,1),1) > lastMin)
    maxLoc(size(maxLoc,1),:) = [];
end

%% Define the Loops to calculate the areas.% Define the loops
numLoops = size(maxLoc);
Loops = {numLoops, 2}; minCounter = 1;
minForce = min(DataForces);
DataForces = DataForces + abs(minForce);
minDisp = min(DataDisplacement);
DataDisplacement = DataDisplacement - minDisp;
maxDisp = max(DataDisplacement);

for maxCounter = 1:numLoops
    Loops{maxCounter,1} = [DataDisplacement(minLoc(maxCounter,1):maxLoc(minCounter,1));...
        DataForces(minLoc(maxCounter,1):maxLoc(minCounter,1))];
    minCounter = minCounter + 1;
    Loops{maxCounter,2} = [DataDisplacement(maxLoc(maxCounter,1):minLoc(minCounter,1));...
        DataForces(maxLoc(maxCounter,1):minLoc(minCounter,1))];
end
clearvars nu mLoops minCounter maxCounter totalSize minLoc maxLoc firstMin lastMin...
            lastMax SmoothedData DataAxis DataDisplacement DataForces

%% Calculate the areas of the loops.
Areas = ones(1,size(Loops, 1));
for i = 1 : size(Loops,1)
    if size(Loops{i,2},1) ~= 0
        % upper loop
        curveFit = polyfit(Loops{i,1}(1,:), Loops{i,1}(2,:), 3);
        x1 = linspace(0,maxDisp); y1 = polyval(curveFit, x1);
        % restrict upper loop to y values above 0
        yCount = 1;
        while (y1(yCount) <= 0)
            yCount = yCount + 1;
        end
        % remove invalid values and calculate the area.
        x1(:,1:yCount-1) = []; y1(:,1:yCount-1) = [];
        
        % lower loop
        curveFit = polyfit(Loops{i,2}(1,:), Loops{i,2}(2,:), 3);
        y2 = polyval(curveFit, x1);
        Areas(i) = trapz(x1, y1) - trapz(x1, y2);
        
        clearvars x1 y1 y2 curveFit yCount
    end
end

%% Final are calculations
GraphAreaAv = mean(Areas);
GraphAreaSD = std(Areas);
MathArea = 0.5 * LostStiffness * (2 * pi * 8)^2;
if(GraphAreaAv < 0)
    GraphAreaAv =  0;
    GraphAreaSD = 0; 
    MathArea = 0;
end
clearvars i maxDisp minDisp minForce LostStiffness 