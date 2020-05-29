%Initialization step
clear all;close all;clc;

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com

%Simulation propoerties
NCycles = 10;               % Number of GS cycles
lambda = 1.0E-6;            % wavelength [m]
ps = 10.0E-6;               % Pixel Size [m]
propagationdistance = 0.02; % Desired propagation distance 
focallength = 0.1;          %Focal length of lens after the SLM
laserbeamsize = 0.01;       %Laser beam size (mm)


% Import Two frames image1 and image2
[FrameA] = function_graypicinput('Image1.jpg');
Error = zeros(1,NCycles);

%Create coordinates and mesh axis for fast calculation
[LX,LY] = size(FrameA);
UX = 1:LX;UX = UX*ps;UX = UX-mean(UX);
UY = 1:LY;UY = UY*ps;UY = UY-mean(UY);
[XX,YY] = ndgrid(UX,UY);

%Initialize Amplitude and phase in z = 0 
Amplitude = sqrt(FrameA);
Phase = 2*pi*zeros(LX,LY);

% Compute Initial complex field
Field1 = Amplitude.*exp(1i*Phase);

%Define reference Fourier space field (at SLM)
[Field2,psX,psY] = function_lens(Field1,ps,ps,focallength,lambda);
UKX = 1:LX;UKX = UKX*psX;UKX = UKX-mean(UKX);
UKY = 1:LY;UKY = UKY*psY;UKY = UKY-mean(UKY);
[KXX,KYY] = ndgrid(UKX,UKY);

%Define laser amplitude profile
Laseramplitudeprofile = exp(-(KXX.^2+KYY.^2)/laserbeamsize^2);

%Run simulation : in NCycle Steps : 
f = figure('Position', [10 10 1500 1000]);
for j = 1:NCycles

% Start by calculating propagated field in Fourier Space
[Field2,psX,psY] = function_lens(Field1,ps,ps,focallength,lambda);

%Display propagated field
subplot(2,3,4)
imagesc(1000*UKX,1000*UKY,abs(Laseramplitudeprofile).^2); 
axis image; 
xlabel('x,[mm]');ylabel('y [mm]');
title(['Laser Intensity on SLM mm [AU]']); 
colorbar;
subplot(2,3,5)
imagesc(1000*UKX,1000*UKY,abs(Field2').^2); 
axis image; 
xlabel('x,[mm]');ylabel('y [mm]');
title(['Guessed Intensity on SLM mm [AU]']); 
colorbar;
subplot(2,3,6)
imagesc(1000*UKX,1000*UKY,angle(Field2')); 
axis image; 
xlabel('x,[mm]');ylabel('y [mm]');
title(['Hologram : phase on SLM, mm [AU]']);
colorbar
subplot(2,3,3)
plot((Error(2:end)))
xlabel('Number of GS Iterations');
ylabel('Residual error in image [AU]');
drawnow


% Enforce the amplitude in Field 2 to match Laser illumination profile on
% SLM
SLMPhase = angle(Field2);
NewAmplitude = Laseramplitudeprofile;
Field2 = NewAmplitude.*exp(1i*SLMPhase);

% propagate back through lens to the image plane
[Field1,ps,ps] = function_lens(Field2,psX,psY,focallength,lambda);
%Backpropagation through a lens is like propagating through the same lens
%with a flip
Field1 = fliplr(flipud(Field1));

%Display new amplitufe
subplot(2,3,2)
imagesc(1000*UX,1000*UY,abs(Field1').^2); 
axis image; 
xlabel('x,[mm]'); ylabel('y [mm]');
title('Intensity at z=0 [AU]'); colorbar;
subplot(2,3,1)
imagesc(1000*UX,1000*UY,abs(FrameA')); 
axis image; 
xlabel('y,[mm]'); ylabel('x [mm]');
title('Target Intensity [AU]'); colorbar

%Evaluate the success 
Error(j) = function_score(FrameA,abs(Field1.^2));

% Enforce the amplitude in Field 1 to match desired illumination
Phase = angle(Field1);
NewAmplitude = sqrt(FrameA);
Field1 = NewAmplitude.*exp(1i*Phase);
end

%Our hologram is now computed to SLMPhase; 


