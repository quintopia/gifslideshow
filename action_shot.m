function output = action_shot(sequence,bleed)
% ACTION_SHOT Overlay a sequence of images with emphasis on selected parts of each image
%   
%   OUTPUT = ACTION_SHOT(SEQ, BLEED) interactively combines the RGB images 
%   in the cell array SEQ into a single image, using the ROIPOLY interface.
%   All images in this sequence must have the same dimensions.
%   For best results, these images should be registered and color-matched
%   using create_animation_stack(). In addition, for the highest quality
%   output, the selected regions in each image should be disjoint, though
%   the results will at least be somewhat sane even where they overlap.
%   BLEED is the width in pixels of the border around the selected polygons
%   which will be copied, faded, into the final image. Think of it as the
%   amount of anti-aliasing to be performed. The OUTPUT will be an RGB
%   image with the same dimensions as the inputs.
%   
%   See also CREATE_ANIMATION_STACK, ROIPOLY
output = zeros(size(sequence{1}));
compselect = zeros(size(sequence{1}));

%create structural element for cutting off a border of width bleed
se=strel('square',bleed);

%create gaussian blur to let previous image bleed into next
G = fspecial('gaussian',[bleed bleed],floor(bleed/3));

for i=1:length(sequence)
    roi = [];
    while isempty(roi)
        roi = roipoly(sequence{i});
    end
    roi = repmat(imfilter(double(imdilate(roi,se)),G,'replicate'),[1,1,3]);
    select = roi.*double(sequence{i});
    compselect = max(compselect,roi);
    
    colorselect = double(repmat(sum(select,3)>sum(output,3),[1,1,3]));
    output = colorselect.*select+(1-colorselect).*output;
end
    output = uint8(output+(1-compselect).*double(sequence{1}));