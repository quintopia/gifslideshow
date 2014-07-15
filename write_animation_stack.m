function write_animation_stack(sequence, filename, dissolve, delay, loop)
% WRITE_ANIMATION_STACK Create a gif slideshow from a sequence of images.
%   
%   WRITE_ANIMATION_STACK(SEQ, FILENAME, DISSOLVE, DELAY, LOOP) writes the
%   sequence of images in the cell array SEQ to a .gif file at FILENAME. If
%   DISSOLVE is greater than zero, it blends consecutive images from the
%   sequence using a number of blending frames equal to DISSOLVE. Each
%   image from the original sequence will be displayed for DELAY seconds in
%   the resulting gif (and each transition frame will be displayed for 0.1
%   seconds). Finally, if LOOP is true, the image will loop indefinitely (and
%   the last frame will be blended back into the first frame).
%   
%   See also: IMWRITE

    if ~exist('loop','var')
        loop = 0;
    end
    for i=1:length(sequence)
        disp(['Writing Frame ',num2str(i)])
        if i==1
            [frame, map] = rgb2ind(sequence{i},256);
            imwrite(frame,map,filename,'gif','LoopCount',loop,'DelayTime',delay);
        else
            frame = rgb2ind(sequence{i},map);
            imwrite(frame,map,filename,'gif','WriteMode','append','DelayTime',delay);
        end
        if i<length(sequence) | loop>0
            for j=1:dissolve
                scale=j/dissolve;
                frame = rgb2ind(uint8(double(sequence{i})*(1-scale)+double(sequence{mod(i,length(sequence))+1})*scale),map);
                imwrite(frame,map,filename,'gif','WriteMode','append','DelayTime',0.1);
            end
        end
    end
            