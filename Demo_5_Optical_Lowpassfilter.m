%We initialize the system
clear all;close all;clc;
%Here, we simulate a 4f optical system with a circular aperture in the
%fourier plane and we observe low pass filtering of spatial frequencies

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com

%Define simulation propoerties
lambda = 1.0E-6;            % wavelength [m]
ps = 10.0E-6;               % Pixel Size [m]
fA = 0.01 ;                  %Focal length lens first lens [m]
fB = 0.2 ;                  %Focal length lens second lens [m]
aperturesize = 30e-6 ;      %Radius of the aperture placed in Fourier space[m]

% Import Reference frame which we will use as amplitude for input 
[FrameA] = function_graypicinput('Image1.jpg');
FrameA = 1-FrameA;
FrameA = rot90((FrameA),2);
[LX,LY] = size(FrameA);

%Create coordinates and mesh axis for fast calculation
UX = 1:LX;UX = UX*ps;UX = UX-mean(UX);
UY = 1:LY;UY = UY*ps;UY = UY-mean(UY);
[XX,YY] = ndgrid(UX,UY);

%Initialize Amplitude and phase in z = 0 
Amplitude = sqrt(FrameA);
Phase = zeros(LX,LY);

% Compute Initial complex field
Field1 = Amplitude.*exp(1i*Phase);

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
Mask = double(FXX.^2+FYY.^2<aperturesize^2);

%Apply Mask (multiply by zero the amplitude anywhere except inside aperture)
Field2=Field2.*Mask;

subplot(2,3,5)
imagesc(1000*UFX,1000*UFY,log(abs(Field2').^2)); 
axis image; 
xlabel('x,[mm]');ylabel('y [mm]');
title(['Intensity after circular aperture filter [AU] log scale']); 
colormap gray;
colorbar;


%Propagate the field through the second lens and define a new set of
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