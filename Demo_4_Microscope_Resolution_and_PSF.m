%We initialize the system
clear all;close all;clc;
% This simulation computes the PSF of a microscope, defined as a 4-f system
% with aperture limit

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com

%Define simulation propoerties
lambda = 1.0E-6;            % wavelength [m]
ps = 0.05E-6;               % Pixel Size [m]
%Here we make a 10X microscope
fB = 0.200 ;                  %Focal length lens second lens (tube lens)[m]
NA = 0.8;                     %Numerical aperture of our objective
M = 20;                       %Magnificaiton of the objective
fA = fB/M ;                   %Focal length lens first lens (Objective) [m]
n = 1;                        %Refractive index of immersion medium
LX = 500;
LY = 500;
LZ = 100;
apertureradius = fA*tan(asin(NA/n)); %The NA of the Objective defines a circular aperture size

% Import Reference frame which we will use as amplitude for input
FrameA = zeros(LX,LY);
FrameA(floor(LX/2), floor(LY/2)) = 1; %Define an infinitely small point object

%Create coordinates and mesh axis for fast calculation
UX = 1:LX;UX = UX*ps;UX = UX-mean(UX);
UY = 1:LY;UY = UY*ps;UY = UY-mean(UY);
[XX,YY] = ndgrid(UX,UY);

%Initialize Amplitude and phase in z = 0
Phase = zeros(LX,LY);

% Compute Initial complex field
Field1 = sqrt(FrameA).*exp(1i*Phase);

% display input field
f = figure(1);
subplot(2,3,1)
imagesc(1000*UX,1000*UY,abs(Field1').^2);
axis image;
xlabel('x,[mm]'); ylabel('y [mm]');
title('Intensity at z=0 [AU]'); colorbar;
subplot(2,3,4)
imagesc(1000*UX,1000*UY,angle(Field1'));
axis image;
xlabel('y,[mm]'); ylabel('x [mm]');
title('phase at z = 0 [AU]'); colorbar

%Here, we compute the first propagated field to Fourier space, rediefine a
%new system of coordinates, and the corresponding axes
[Field2,psFX,psFY] = function_lens(Field1,ps,ps,fA,lambda);
UFX = 1:LX;UFX = UFX*psFX;UFX = UFX-mean(UFX);
UFY = 1:LY;UFY = UFY*psFY;UFY = UFY-mean(UFY);
[FXX,FYY] = ndgrid(UFX,UFY);

%Display propagated field
f = figure(1);
subplot(2,3,2)
imagesc(1000*UFX,1000*UFY,log(abs(Field2').^2));
axis image;
xlabel('x,[mm]');ylabel('y [mm]');
title(['Intensity after first lens [AU] log scale']);
colormap gray;
colorbar;

%Build a Low pass filter called Mask, which has ones within a circular
%aperture of radius aperturesize, and zeros elsewhere
Mask = double(FXX.^2+FYY.^2<apertureradius^2);

%Apply Mask (multiply by zero the amplitude anywhere except inside aperture)
Field2=Field2.*Mask;

subplot(2,3,5)
imagesc(1000*UFX,1000*UFY,log(abs(Field2').^2));
axis image;
xlabel('x,[mm]');ylabel('y [mm]');
title(['Intensity after objective back aperture mask [AU] log scale']);
colormap gray;
colorbar;


%Propagate the field through the tube lens and define a new set of
%coordinates
[Field3,psX3,psY3] = function_lens(Field2,psFX,psFY,fB,lambda);
UX3 = 1:LX;UX3 = UX3*psX3;UX3 = UX3-mean(UX3);
UY3 = 1:LY;UY3 = UY3*psY3;UY3 = UY3-mean(UY3);
[XX3,YY3] = ndgrid(UX3,UY3);

f = figure(1);
subplot(2,3,3)
imagesc(1000*UX3,1000*UY3,abs(Field3').^2);
axis image;
xlabel('x,[mm]');ylabel('y [mm]');
title(['Intensity after second lens [AU]']);
colorbar;
subplot(2,3,6)
imagesc(1000*UX3,1000*UY3,angle(Field3'));
axis image;
xlabel('x,[mm]');ylabel('y [mm]');
title(['phase after second lens  [AU]']);
colorbar

%Resize Field3 to keep relevant center
Field3 = Field3(200:300,200:300);
[LX,LY] = size(Field3);
peakintensity = max(abs(Field3(:)))^2;

%%%% Let's compute the PSF by propagating the wave in the image plane a mm
%%%% above and below

Depths = linspace(-1e-3,1e-3, LZ);
stack = zeros(LX,LY,LZ);
for j = 1:LZ
    field = function_propagate(Field3,lambda,Depths(j),psX3,psY3);
    stack(:,:,j) = abs(field).^2;
    g = figure(2);
    subplot(2,2,1)
    imagesc(1000*UX3,1000*UY3,abs(field').^2);
    caxis([0 peakintensity])
    xlabel('x,[mm]');ylabel('y [mm]');
    title(['Intensity at z = ' int2str(1e6*Depths(j)) ' um']);
    axis image;
    drawnow
end
subplot(2,2,2)
imagesc(1000*Depths,1000*UY3,squeeze(max(stack,[],1)));
caxis([0 peakintensity])
xlabel('z,[mm]');ylabel('y [mm]');
title(['PSF YZ projection']);
axis image;
subplot(2,2,3)
imagesc(1000*UX3,1000*Depths,squeeze(max(stack,[],2))');
caxis([0 peakintensity])
xlabel('x,[mm]');ylabel('z [mm]');
title(['PSF XZ Projection']);
axis image;
subplot(2,2,4)
imagesc(1000*UX3,1000*UY3,squeeze(max(stack,[],3))');
caxis([0 peakintensity])
xlabel('x,[mm]');ylabel('y [mm]');
title(['PSF XY Projection']);
axis image;


