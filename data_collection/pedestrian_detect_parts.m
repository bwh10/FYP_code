%%This function:
%1. Suppresses double detections (optional - turned on by default)
%2. Extracts pedestrians parts detected according to DPM bounding boxes
%3. Converts them into LAB colourspace
%4. Computes 4D LAB colour multidimensional histogram for each pedestrian
%5. Reorders them into 1 dimension and stores it into array LAB_hist

function [LAB_hist,bbox]=pedestrian_detect_parts (im,bbox,bbox_part,double_suppress,step_size)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check input arguments%%%%%%%%%%%%%%%%%%%%%%%
    if (nargin==3)
        double_suppress=1; %Turn on double suppression by default
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Suppress double detections%%%%%%%%%%%%%%%%%%%%%%%
    if (double_suppress==1)
        [bbox,bbox_part] = suppress_double_detect_wparts(bbox,bbox_part);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%Extract LAB colour space from bounding box%%
    %Get number of detected ppl
    [num_ppl,~]  =size(bbox);
    [~,num_parts]=size(bbox_part);
    num_parts=num_parts/4;
    
    if (num_ppl>0)
        %Initialise array containing LAB colour space multidimensional histogram of detected ppl
        %ordered in 1 dimension
        array_size=ceil(101/step_size)*ceil(201/step_size)*ceil(201/step_size);
        LAB_hist=zeros(array_size,num_ppl,num_parts+1); %(hist,ppl index, part index)

        %Extract LAB 4D multidimensional histogram for individual ppl and parts and store in array
        for i=1:num_ppl 
            hist = im2hist(im,bbox(i,:),step_size);
            hist = [hist;zeros(array_size-numel(hist),1)]; %Zero pad so can fit into LAB_hist storage
            LAB_hist(:,i,end)=hist(:); %Store overall bbox histogram
            for j=1:num_parts
                part_num=j*4;
                bbox_parts    = [bbox_part(i,part_num-4+1),bbox_part(i,part_num-4+2),bbox_part(i,part_num-4+3),bbox_part(i,part_num-4+4)];
                hist = im2hist(im,bbox_parts,step_size);
                hist = [hist;zeros(array_size-numel(hist),1)]; %Zero pad so can fit into LAB_hist storage
                LAB_hist(:,i,j)=hist(:); %Store bbox part histogram
            end
        end
    else
        LAB_hist=[];
    end
end