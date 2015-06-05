function bbox_out=suppress_double_detect(bbox)
    overlapThres=0.75; %Beyond this amt is considered a double detection
    [num_bbox,~]=size(bbox);
    
    idx_double_detect=[];
    
    %Get bbox index of double detections
    for i=1:num_bbox
        bbox_on_test=bbox(i,:);        
        %Dimensions of the bounding box on test
        bbox_test_w=bbox_on_test(3);
        bbox_test_h=bbox_on_test(4);
        
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
        
    end
    
    %Remove double detection indices
    idx_remain=setdiff(1:num_bbox,idx_double_detect);
    
    %Output bounding boxes with suppressed double detections
    bbox_out=bbox(idx_remain,:);
end