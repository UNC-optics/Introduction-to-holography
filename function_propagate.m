function [field2] = function_propagate(field1,lambda,z,psx, psy)
% This function simulates the paraxial propagation of a complex 2D field 
% field1 is the x,y complex field (amplitude .* exp(i*phase)) at z=0,
% sampled on a grid of pixel size psx psy
% psx is the pizel size along x axis
% psy is the pizel size along y axis
% lambda the wavelength 
% z is the desired propagation distance 
% Function returns field2, thecomplex field at distance z

% adapted from previous work by Laura Waller, MIT, lwaller@alum.mit.edu
% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com

[M,N]=size(field1);
if mod(M,2) == 1
UY = 1:M; UY = UY-mean(UY)-1;
else
UY = 1:M; UY = UY-mean(UY)-0.5;   
end
if mod(N,2) == 1
UX = 1:N; UX = UX-mean(UX)-1;
else
UX = 1:N; UX = UX-mean(UX)-0.5;    
end
[x,y] = meshgrid(UX,UY);
kx=x/psx/N;     
ky=y/psy/M;     
H=exp(-1i*pi*lambda*z.*(kx.^2+ky.^2));
H = fftshift(H);
objFT=(fft2(field1));
field2=(ifft2(objFT.*H));
end