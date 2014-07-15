function outputseq=create_animation_stack(sequence,bleed)
% CREATE_ANIMATION_STACK Register, crop, and overlay a sequence of images
%   
%   RES = CREATE_ANIMATION_STACK(SEQ, BLEED) will register the cell array
%   of RGB images SEQ so that all images after the first will be registered
%   with, cropped to the field of view of, and overlaid on top the first
%   image in the array. In order to make the overlay more seamless, the
%   boundary where the overlaid image and the first image meet is blurred
%   in a region BLEED pixels wide. The output RES is a new cell array
%   containing the resulting sequence of images, in which the first element
%   is the same image as the first image in the argument sequence. Be
%   warned that this function takes several seconds per image, and
%   therefore may take a long time to return. Note also that best results
%   are achieved if all regions of each image which do not overlap the
%   field of view of the first image are cropped away in advance.
%
%   See also IMREGSURF
%allocate RGB output sequence
outputseq = cell(length(sequence));
outputseq{1}=sequence{1};

%create structural element for cutting off a border of width bleed
se=strel('square',bleed);

%create gaussian blur to let previous image bleed into next
G = fspecial('gaussian',[bleed bleed],floor(bleed/3));

first=double(outputseq{1});
%display the first image while we wait for the next to process
%imshow(sequence{1});
%pause(0.1);

for i=2:length(sequence)
    %register this image with the first one
    warped=imregSURF(sequence{i},sequence{1});
    
    %create the cropping/bleeding filter
    ind=repmat(imfilter(double(imdilate((sum(warped,3)==0),se)),G,'replicate'),[1,1,3]);
    
    %crop the new image
    crop=double(warped).*(1-ind);
    
    %cut out the border from the previous image
    border=first.*ind;
    %border=double(outputseq{i-1}).*ind;
    
    %overlay the images
    outputseq{i}=uint8(crop+border);
    
    %display the results while we wait for the next to process
    %imshow(outputseq{i});
    %pause(0.1);
end
