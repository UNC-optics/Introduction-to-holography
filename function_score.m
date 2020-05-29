function [score] = function_score(IntensityA,IntensityB)
%Score indicating how well Intensity A and B are matching L2 Norm
% Nicolas Pegard, pegard@unc.edu, www.nicolaspegard.com


%normalize the two input intensity profiles
IntensityA=IntensityA/sum(IntensityA);
IntensityB=IntensityB/sum(IntensityB);

%Calculate the error image with an L2 norm
errorimage = (IntensityA-IntensityB).^2;

%Mean value over the whole image
score = sqrt(sum(errorimage(:)));
end

