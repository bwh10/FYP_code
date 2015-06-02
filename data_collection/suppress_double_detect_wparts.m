function [bbox_out,bbox_out_parts]=suppress_double_detect_wparts(bbox,bbox_parts)
    overlapThres=0.75; %Beyond this amt is considered a double detection
    [num_bbox,~]=size(bbox);
    
    idx_double_detect=[];
    
    %Get bbox index of double detections
    for i=1:num_bbox
        bbox_on_test=bbox(i,:);        
        %Dimensions of the bounding box on test
        bbox_test_w  =bbox_on_test(3);
        bbox_test_h  =bbox_on_test(4);
        bbox_test_a  =bbox_test_w*bbox_test_h;
        
        %Compute overlap with other bounding boxes
        overlapRatio=bboxOverlapRatio(bbox_on_test, bbox,'Min');
        
        %Get idx of bounding box overlap
        idx_overlap=find(overlapRatio>overlapThres);
        idx_overlap=setdiff(idx_overlap,i); %Do not include oneself in the overlap
        
        %Throw away idx of the overlap that is bigger than our test
        %dimensions
        overlap_w = bbox(idx_overlap,3);
        overlap_h = bbox(idx_overlap,4);
        idx_      = (overlap_w>bbox_test_w); 
        idx_double_detect=[idx_double_detect idx_overlap(idx_)];

%         %Throw away idx of the overlap that has area not equal to median of
%         %all possible overlap bounding boxes
%         overlap_w = bbox(idx_overlap,3);
%         overlap_h = bbox(idx_overlap,4);
%         overlap_a = overlap_w.*overlap_h;
%         median_a  = ceil(median(overlap_a)); %Biased towards the bigger area
%         idx_      = overlap_a==median_a;     %index to keep i.e. keep the bbox with the median area
%         idx_      = ~idx_;                   %Index to throw
%         idx_double_detect=[idx_double_detect idx_overlap(idx_)];
        
    end
    
    %Remove double detection indices
    idx_remain=setdiff(1:num_bbox,idx_double_detect);
    
    %Output bounding boxes with suppressed double detections
    bbox_out        =bbox(idx_remain,:);
    bbox_out_parts  =bbox_parts(idx_remain,:);
end