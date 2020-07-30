function [GraphAreaAv, GraphAreaSD, MathArea] = HysteresisCalc(dataFile, LostStiffness)
%% Import the data
Data = importdata(dataFile);
type = 1;
if(size(Data,1) <= 1)
    Data = importDat(dataFile);
    type = 2;
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

%Calculate avergae distance between axis locations
AxisDis = zeros(1,size(DataAxis, 2));
for i = 2 : size(DataAxis, 2)
    AxisDis(1,i-1) = DataAxis(1,i) - DataAxis(1,i-1);
end
disMean = mean(AxisDis);
N = 0; a = disMean;
while a < 1
    a = a * 10;
    N = N + 1;
end
disMean = round(disMean, N);

% Check the axis
loopWeakness = 0;
for i = 1:(size(DataAxis, 2)-1)
    dif = round(DataAxis(1,i+1) - DataAxis(1,i), N);
    if(dif > disMean && type == 2)
        loopWeakness = i+1;
    end
end
if(loopWeakness ~= 0)
    DataForces(:,1:loopWeakness) = [];
    DataDisplacement(:,1:loopWeakness) = [];
    DataAxis(:,1:loopWeakness) = [];
end

if(size(DataAxis,2) > 1)

    %% Identify turning points within the data
    % Smooth the graph and find the maixmal turning points
    SmoothedData = smooth(DataAxis(1,:),DataForces(1,:),0.05,'loess');
    [~,maxLoc] = findpeaks(SmoothedData);
    % Find the minmal turning points
    [~,minLoc] = findpeaks(-SmoothedData);

    %% Calculate peaks and troughs of data and readjust to only include correct span of data.
    if(type == 2)
        if(DataDisplacement(minLoc(1,1)) > DataDisplacement(maxLoc(1,1)))
            a = minLoc;
            minLoc = maxLoc;
            maxLoc = a;
        end
        
        % Check for a min that is out of bounds.
        TF = isoutlier(DataDisplacement(1,minLoc),'median');
        count = 1; zer = [];
        for i = 1:size(TF,2)
            if(TF(1,i) == 0 || (i ~= 1 && i ~= size(TF,2)))
                zer(count, 1) = i; count = count + 1;
            end
        end
        minLoc = minLoc(zer,1);

%         % Check for a max that is out of bounds.
%         TF = isoutlier(DataDisplacement(1,maxLoc),'median');
%         count = 1; zer = [];
%         for i = 1:size(TF,2)
%             if(TF(1,i) == 0 || (i ~= 1 && i ~= size(TF,2)))
%                 zer(count, 1) = i; count = count + 1;
%             end
%         end
%         maxLoc = maxLoc(zer,1);
    end

    % Check if initial loop starts from minimum and remove up to first min.
    firstMin = minLoc(1,1) - 1;
    DataAxis(:,1:firstMin) = [];
    DataDisplacement(:,1:firstMin) = [];
    DataForces(:,1:firstMin) = [];

    % remove a max if it occurs first.
    while (maxLoc(1,1) < firstMin)
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
    DataAxis(:,lastMin:totalSize) = [];
    bools = 1;
    while (bools)
        if (maxLoc(size(maxLoc,1),1) > lastMin)
            maxLoc(size(maxLoc,1),:) = [];
        else
            bools = 0;
        end
    end
    

    %% Define the Loops to calculate the areas.% Define the loops
    numLoops = size(maxLoc);
    Loops = {numLoops, 2}; minCounter = 1;
    minForce = abs(min(DataForces));
    DataForces = DataForces + minForce;
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
        end
    end

    %% Final are calculations
    GraphAreaAv = mean(Areas);
    GraphAreaSD = std(Areas);
    MathArea = 0.5 * LostStiffness * (2 * pi * 8)^2;
    % if(GraphAreaAv < 0)
    %     GraphAreaAv =  0;
    %     GraphAreaSD = 0; 
    %     MathArea = 0;
    % end
else
    GraphAreaAv =  0;
    GraphAreaSD = 0; 
    MathArea = 0;
end

plot(x1,y1,'red'); hold on;
for i = 2:size(x1,2)
    if(mod(i,2) == 0)
        v1 = [x1(1,i-1) 0; x1(1,i-1) y1(1,i-1); x1(1,i) y1(1,i); x1(1,i) 0];
        f1 = [1,2,3,4];
%         x = [x1(1,i-1),x1(1,i-1),x1(1,i),x1(1,i)];
%         y = [0,y1(1,i-1),y1(1,i-1),0];
        patch('Faces',f1,'Vertices',v1,'FaceColor','red','FaceAlpha',.3);
        hold on;
    end
end
plot(x1,y2,"blue"); hold on;
for i = 2:size(x1,2)
    if(mod(i,2) ~= 0)
        v1 = [x1(1,i-1) 0; x1(1,i-1) y2(1,i-1); x1(1,i) y2(1,i); x1(1,i) 0];
        f1 = [1,2,3,4];
        patch('Faces',f1,'Vertices',v1,'FaceColor','blue','FaceAlpha',.3);
        hold on;
        
%         x = [x1(1,i-1),x1(1,i-1),x1(1,i),x1(1,i)];
%         y = [0,y2(1,i-1),y2(1,i-1),0];
%         patch(x,y,'blue');
%         hold on;
    end
end




