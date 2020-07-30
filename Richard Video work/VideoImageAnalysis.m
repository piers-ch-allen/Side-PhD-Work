function resultSet = VideoImageAnalysis(videoFile)
video = VideoReader(videoFile);
numFrames = floor(video.Duration) - 1;
v = readFrame(video);

%grab the mask
mask = imread('mask_image.jpg');
Mask = im2uint8((rgb2gray(mask) < 254));

%choose the feature points
Base = rgb2gray(v);
figure; imshow(Base);
[xi,yi] = getpts();
fixedPoints = [xi,yi];
close;

%Mask properties
xMask = [44.0000000000000;124.000000000000;126.000000000000;508.000000000000;516;581];
yMask = [1.99999999999994;122;407.000000000000;405.000000000000;104;0.999999999999943];
movPoints = [xMask,yMask];

%find the transform
tform = fitgeotrans(movPoints,fixedPoints,'pwl');
MaskRegis = imwarp(Mask,tform,'OutputView',imref2d(size(Base)));
MaskIm = im2uint8(MaskRegis)/255;

%Collect all the stills from the video, 1 a second
imageDataSet = cell(300,1);
for i = 1:numFrames
    im = rgb2gray(readFrame(video)).*MaskIm;
    video.CurrentTime = i + 1;
    for j = 1:size(im, 1)
        for k = 1:size(im, 2)
            if (im(j,k) == 0)
                im(j,k) = 255;
            end
        end
    end
    imageDataSet{i,1} = histeq(im);
end

%Analyse each still for the horizontal plane height
resultSet = zeros(2,numFrames); 
for i = 1:numFrames
    %restrict the view of the frame
    currFrame = imageDataSet{i,1};
    sizIm = size(currFrame, 2);
    newIm = histeq(currFrame(1:380,(sizIm/2 - sizIm/4):(sizIm/2 + sizIm/4)));
    
    %manipulate the image
    newImSmoothed = imgaussfilt(newIm,[1 8]);
    newImFilled = imfill(imbinarize(newImSmoothed),'holes');
    
    %identify largest white location and find the avergae height of the liquid at that time point. 
    newImBig = bwareafilt(newImFilled,1);
    for j = 1:size(newImBig, 2)
        for k =1:size(newImBig, 1)
            if (newImBig(k,j) == 1)
                newImBig(k+1:size(newImBig, 1), j) = zeros(size(newImBig, 1) - k,1);
                break;
            end
        end
    end
    [~,loc] = max(newImBig);
    
    %remove the outliers in the data
    locOut = isoutlier(loc);
    sizeL = size(loc,2);
    for c = 0:sizeL-1
        d = sizeL - c;
        if(locOut(1,d) == 1)
            loc(:,d) = [];
        end
    end
    loc = size(newImBig, 1) - loc;
    
    %Save the data
    resultSet(1,i) = i; 
    resultSet(2,i) = ceil(mean(loc)); 
    resultSet(3,i) = std(loc);
end
    
%Remove the data after flask is removed and any outlier values
% for i = 1:numFrames
%     if(resultSet(2,i) > 370)
%         break;
%     end
% end
if(numFrames > 200)
    resultSet(:,200:numFrames) = [];
end
locOut = zeros(1,size(resultSet,2));
for i = 1:size(resultSet,2)
    if(i == 1 || i == 2 || i == size(resultSet,2) - 1 || i == size(resultSet,2))
        if(resultSet(3,i) > 15)
            locOut(1,i) = 1;
        end
    else
        temp = resultSet(2,i-2:i+2);
        tempVal = isoutlier(temp);
        if(tempVal(1,3) == 1)
            locOut(1,i) = 1;
        end
    end
end
sizeL = size(resultSet,2);
for c = 0:sizeL-1
    d = sizeL - c;
    if(locOut(1,d) == 1)
        resultSet(:,d) = [];
    end
end
