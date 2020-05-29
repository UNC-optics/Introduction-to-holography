clear all;close all;clc; %Initialize matlab with a reset
%This simulation illustrates the ability of function_propagate to simulate
%the propagation of complex fields.

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com

%Define simulation propoerties
lambda = 1.0E-6;                                % wavelength [m]
ps = 10.0E-6;                                   % Pixel Size [m] (we use the same along either axis)
LX = 300;                                       % Number of data points along X axis
LY = 300;                                       % Number of data points along Y axis
propagationdistances = linspace(0, 0.010, 20);   % In meters, the propagation distances you wish to compute

%Create coordinates and millimeter mesh axis for fast calculation
UX = 1:LX;UX = UX*ps;UX = 1000*(UX-mean(UX));
UY = 1:LY;UY = UY*ps;UY = 1000*(UY-mean(UY));
[XX,YY] = ndgrid(UX,UY);

%Import a test image
[Image] = function_graypicinput('Image1.jpg');
Image = imresize(Image,[LX,LY]); %Resize image data to specified parameters
Image = -Image;

%Create a complex field by setting amplitude and phase
Amplitude = sqrt(Image);
%select one of the options below for phase
Phase = zeros(LX,LY);
%Phase = 2*pi*rand(LX,LY);

ComplexField = Amplitude.*exp(1i*Phase);

%Display Amplitude and Phase at z = 0
f = figure(1);
subplot(2,3,1)
imagesc(UY,UX,abs(ComplexField).^2); colormap gray; axis image;
xlabel('X [mm]'); ylabel('Y [mm]'); title('Intensity at z=0');
subplot(2,3,2)
imagesc(UY,UX,abs(ComplexField)); colormap gray; axis image;
xlabel('X [mm]'); ylabel('Y [mm]'); title('Amplitude at z=0');
subplot(2,3,3)
imagesc(UY,UX,angle(ComplexField)); colormap gray; axis image;
xlabel('X [mm]'); ylabel('Y [mm]'); title('Phase at z=0');


for j = 1:numel(propagationdistances)
    % Propagate the field
    NewField = function_propagate(ComplexField,lambda,propagationdistances(j),ps, ps);
    
    %Display propagated field
    subplot(2,3,4)
    imagesc(UY,UX,abs(NewField).^2); colormap gray; axis image;
    xlabel('X [mm]'); ylabel('Y [mm]'); title(['Propagated Intensity z = ' num2str(propagationdistances(j)) ' m']);
    subplot(2,3,5)
    imagesc(UY,UX,abs(NewField)); colormap gray; axis image;
    xlabel('X [mm]'); ylabel('Y [mm]'); title(['Amplitude at z = ' num2str(propagationdistances(j)) ' m']);
    subplot(2,3,6)
    imagesc(UY,UX,angle(NewField)); colormap gray; axis image;
    xlabel('X [mm]'); ylabel('Y [mm]'); title(['Phase at z = ' num2str(propagationdistances(j)) ' m']);
    drawnow
end