function [Data] = function_graypicinput(pathimage)
%This function imports a jpg file at destination pathimage (e.g 'c:\image.jpg')
%turns it into a grey level image
% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com


Data = imread(pathimage);
Data = double(Data);
Data = mean(Data,3);

%Subtract background
Data = Data-min(Data(:));
Data = Data / max(Data(:));

%Invert greyscale (negative)
Data = 1-Data;

%Normalizes the image data
Data = Data/sum(Data(:));

%Flip the frame 90degree
Data = Data';
end

