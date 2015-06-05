%This script takes the tracking result and stabilises the bounding box
%detection by taking the moving average of the bounding box sizes. This is
%not incorporated into the tracking framework as it would affect the MOT
%metrics calculation. This is solely for aesthetics purposes. 

clear all

%Load tracking result
load tracker_result_dsup_safe_assoc.mat

%Moving average span
MA_span_bbox_dim = 30;
MA_span_centroid = 5;

%Get unique person IDs
unique_person_ID = unique(personNum_track);

for i=1:numel(unique_person_ID)
    person_ID=unique_person_ID(i);
    idx=(personNum_track==person_ID); 
    %Get bbox original parameters for that particular person
    bodyH=bodyH_track(idx); %bbox height
    bodyW=bodyW_Track(idx); %bbox width
    bodyT=bodyT_Track(idx); %bbox Top coordinates
    bodyL=bodyL_Track(idx); %bbox Left coordinates
    %Get centroid coordinates of bounding box
    bodyC_y=bodyT+bodyH./2;
    bodyC_x=bodyL+bodyW./2;
    
    %Get stabilised centroid coordinates
    bodyC_y=MA(bodyC_y,MA_span_centroid,1);
    bodyC_x=MA(bodyC_x,MA_span_centroid,1);      
    %Get stabilised bbox dimensions
    bodyH=MA(bodyH,MA_span_bbox_dim,0);
    bodyW=MA(bodyW,MA_span_bbox_dim,0); 
    
    %Get new Top and Left coordinates
    bodyT=bodyC_y-bodyH./2;
    bodyL=bodyC_x-bodyW./2;
    %Save results back to original matrix
    bodyH_track(idx)=bodyH; %bbox height
    bodyW_Track(idx)=bodyW; %bbox width
    bodyT_Track(idx)=bodyT; %bbox Top coordinates
    bodyL_Track(idx)=bodyL; %bbox Left coordinates    
end

save('track_bbox_stabilised.mat','frameNum_track','personNum_track','bodyL_Track','bodyT_Track','bodyW_Track','bodyH_track');