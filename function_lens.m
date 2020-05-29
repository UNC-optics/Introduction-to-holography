function [field2,psX,psY] = function_lens(field1,psx,psy,f,lambda)
%This functiion simulates the propagation of light through an f-f system : 
% a portion of free space of thickness f, a lens of focal length f>0, and a
% second portion of free space of thickness f.

%field1 is the input complex field defined with 
%pixel size psy [m] and psy [m]
%f [m] is the focal distance of the lens
%lambda [m] is the wavelength

%The function returns field2 : the output field in Fourier space as well as
%the New pixel size psX [m] and psY [m]  

% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com


field2=ifftshift(fft2(fftshift(field1)));
[NX,NY] = size(field1);
psX = f*lambda/(NX*psx);
psY = f*lambda/(NY*psy);
end