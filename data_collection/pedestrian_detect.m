%%This function:
%1. Suppresses double detections (optional - turned on by default)
%2. Extracts pedestrians detected according to DPM bounding boxes
%3. Converts them into LAB colourspace
%4. Computes 4D LAB colour multidimensional histogram for each pedestrian
%5. Reorders them into 1 dimension and stores it into array LAB_hist

function [LAB_hist,bbox]=pedestrian_detect (im,bbox,double_suppress,step_size)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check input arguments%%%%%%%%%%%%%%%%%%%%%%%
    if (nargin==3)
        double_suppress=1; %Turn on double suppression by default
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Suppress double detections%%%%%%%%%%%%%%%%%%%%%%%
    %t_dsup=tic;
    if (double_suppress==1)
        bbox = suppress_double_detect(bbox);
    end
    %toc(t_dsup)
    %%%%%%%%%%%%%%%%%%%%%%%%%%Extract LAB colour space from bounding box%%
    %t_hist=tic;
    %Get number of detected ppl
    [num_ppl,~]=size(bbox);
    
    if (num_ppl>0)
        %Initialise array containing LAB colour space multidimensional histogram of detected ppl
        %ordered in 1 dimension
        array_size=ceil(101/step_size)*ceil(201/step_size)*ceil(201/step_size);
        LAB_hist=zeros(array_size,num_ppl); %Variable step size

        %Extract LAB 4D multidimensional histogram for individual ppl and store in array
        for i=1:num_ppl 
            %Extract RGB person
            im_crop=imcrop(im,bbox(i,:));
            %Convert to LAB colourspace
            imLAB=rgb2lab(im_crop);
            %Prepare data for histogram computation via lexicographic ordering
            imLAB=reshape(imLAB(:),[numel(imLAB(:))/3,3]);
            %Compute 4D LAB colour histogram
            [count ~] = histcn(imLAB,0:step_size:101,-101:step_size:100,-101:step_size:100);
            %Store 4D histogram reordered to 1 dimension
            count=count(:);
            count=[count;zeros(array_size-numel(count),1)]; %Zero pad so can fit into LAB_hist storage
            LAB_hist(:,i)=count(:);
        end
    else
        LAB_hist=[];
    end
    %toc(t_hist)

end