function [ hist ] = im2hist( im,bbox,step_size )
%Converts a section of an image to a lexicographically ordered 4D histogram 
%   1. im is actual image
%   2. bbox is the section of image to extract
%   3. step_size defines the granuality of the histogram
%   4. hist is the output lexicographically ordered 4D histogram

%Extract RGB person
im_crop=imcrop(im,bbox);
[x_size,y_size,~]=size(im_crop);

if ((x_size>0) && (y_size>0)) %Detected part is within frame boundary
    %Convert to LAB colourspace
    imLAB=rgb2lab(im_crop);
    %Prepare data for histogram computation via lexicographic ordering
    imLAB=reshape(imLAB(:),[numel(imLAB(:))/3,3]);
    %Compute 4D LAB colour histogram
    [hist ~] = histcn(imLAB,0:step_size:100,-100:step_size:100,-100:step_size:100);
    %Lexicographically order 4D histogram to 2D
    hist=hist(:);
else %Detected part is outside frame boundary
    hist=-1; %No histogram
end
end

