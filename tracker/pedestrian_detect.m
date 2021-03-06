%%This function:
%1. Suppresses double detections (optional - turned on by default)
%2. Extracts pedestrians detected according to DPM bounding boxes
%3. Converts them into LAB colourspace
%4. Computes 4D LAB colour multidimensional histogram for each pedestrian
%5. Reorders them into 1 dimension and stores it into array LAB_hist

function [LAB_hist,bbox]=pedestrian_detect (im,bbox,double_suppress)
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
        LAB_hist=zeros(4080501,num_ppl); %Step size 1
        %LAB_hist=zeros(35937,num_ppl); %Step size 32

        %Extract LAB 4D multidimensional histogram for individual ppl and store in array
        for i=1:num_ppl 
            %Extract RGB person
            im_crop=imcrop(im,bbox(i,:));
            %Convert to LAB colourspace
            imLAB=rgb2lab(im_crop);
            %Prepare data for histogram computation via lexicographic ordering
            imLAB=reshape(imLAB(:),[numel(imLAB(:))/3,3]);
            %Compute 4D LAB colour histogram
            [count ~] = histcn(imLAB,0:101,-101:100,-101:100);
            %[count edges mid loc] = histcn(imLAB);
            %Store 4D histogram reordered to 1 dimension
            LAB_hist(:,i)=count(:);
        end
    else
        LAB_hist=[];
    end
    %toc(t_hist)

end