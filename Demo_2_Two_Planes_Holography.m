%Initialization step
clear all;close all;clc;
% This simulation is a simple implementation of the gerchberg saxton
% algorithm to identify what phase should be applied to the amplitude Frame A in order to create a field that matches the image specified by Frame B at a certain propagation distance

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com


%Simulation propoerties
NCycles = 50;                % Number of iterations of the GS algorithm
lambda = 1.0E-6;             % wavelength [m]
ps = 10.0E-6;                % Pixel Size [m] / mag
propagationdistance = 20E-3; % Desired propagation distance
NZ = 100;                    % Number of points along Z axis to visualize results


% Import Two frames image1 and image2
[FrameA] = function_graypicinput('Image2.jpg');
[FrameB] = function_graypicinput('Image1.jpg');
Error = zeros(1,NCycles);

%Create coordinates and mesh axis for fast calculation
[LX,LY] = size(FrameA);
UX = 1:LX;UX = UX*ps;UX = UX-mean(UX);
UY = 1:LY;UY = UY*ps;UY = UY-mean(UY);
[XX,YY] = ndgrid(UX,UY);


%Initialize Amplitude and phase in z = 0
Amplitude = sqrt(FrameA);
Phase = 2*pi*rand(LX,LY);
% Compute Initial complex field
Field1 = Amplitude.*exp(1i*Phase);

%Run simulation : in NCycle Steps :
for j = 1:NCycles
    f = figure(1);
    subplot(2,3,1)
    imagesc(1000*UX,1000*UY,abs(Field1').^2);
    axis image;
    xlabel('x,[mm]'); ylabel('y [mm]');
    title('Intensity at z=0 [AU]'); colorbar;
    subplot(2,3,2)
    imagesc(1000*UX,1000*UY,angle(Field1'));
    axis image;
    xlabel('y,[mm]'); ylabel('x [mm]');
    title('phase at z = 0 [AU]'); colorbar
    
    % Start by calculating propagated field at a distance z
    [Field2] = function_propagate(Field1,lambda,propagationdistance,ps,ps);
    
    %Display propagated field
    f = figure(1);
    subplot(2,3,4)
    imagesc(1000*UX,1000*UY,abs(Field2').^2);
    axis image;
    xlabel('x,[mm]');ylabel('y [mm]');
    title(['Intensity at z = ' num2str(1000*propagationdistance) 'mm [AU]']);
    colorbar;
    subplot(2,3,5)
    imagesc(1000*UX,1000*UY,angle(Field2'));
    axis image;
    xlabel('x,[mm]');ylabel('y [mm]');
    title(['phase at z = ' num2str(1000*propagationdistance) 'mm [AU]']);
    colorbar
    subplot(2,3,3)
    plot(Error)
    drawnow
    
    %Measure the reconstruction error
    Error(j) = function_score(FrameB,abs(Field2.^2));
    
    %Enforce the amplitude in Field 2, keep the phase
    Phase = angle(Field2);
    NewAmplitude = sqrt(FrameB);
    Field2 = NewAmplitude.*exp(1i*Phase);
    
    %Propagate back to the original plane in z = 0
    [Field1] = function_propagate(Field2,lambda,-propagationdistance,ps, ps);
    
    %Enforce the amplitude in Field 1, keep the phase
    Phase = angle(Field1);
    NewAmplitude = sqrt(FrameA);
    Field1 = NewAmplitude.*exp(1i*Phase);
end


%In this next part, we simply visualize the propagation of the optimized
%field "Field1"
%Define simulation environment : propagation axis
z = linspace(0,propagationdistance, NZ); % Define the axis of depths to use [m]

%Run simulation : in NZ steps :
for j = 1:NZ
    % Start by calculating propagated field at a distance z
    [FieldProp] = function_propagate(Field1,lambda,z(j),ps,ps);
    
    %Display propagated field
    g = figure(2);
    subplot(1,2,1)
    imagesc(1000*UX,1000*UY,abs(FieldProp').^2);
    axis image;
    xlabel('x,[mm]');ylabel('y [mm]');
    title(['Intensity at z = ' num2str(1000*z(j)) 'mm [AU]']);
    caxis([0 10e-5])
    colorbar;
    subplot(1,2,2)
    imagesc(1000*UX,1000*UY,angle(FieldProp'));
    axis image;
    xlabel('x,[mm]');ylabel('y [mm]');
    title(['phase at z = ' num2str(1000*z(j)) 'mm [AU]']);
    colorbar
    drawnow
    
end
