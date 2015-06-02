function [ ...
    frameNum_track, ...
    personNum_track, ...
    bodyL_Track, ...
    bodyT_Track, ...
    bodyW_Track, ...
    bodyH_track, ...
    assoc_cost, ...
    bbox_new ...
] = store_tracker_results( ...
    k, ...
    new_label, ...
    bbox_new, ...
    frameNum_track, ...
    personNum_track, ...
    bodyL_Track, ...
    bodyT_Track, ...
    bodyW_Track, ...
    bodyH_track, ...
    assoc_cost ...
)
%store_tracker_results 
%   This function stores the bbox results of the tracker and outputs the
%   appropriate results for MOT evaluation
      frame_length=1920;
      frame_height=1080;
      
      %Process bounding boxes which exceeds frame dimensions
      %1. Left dimension<0 or Top dimension<0
      left_out                  = 0-bbox_new(:,1);
      top_out                   = 0-bbox_new(:,2);
      left_out_idx              = left_out>0;
      top_out_idx               = top_out>0;
      bbox_new(left_out_idx,1)  = 0;
      bbox_new(top_out_idx,2)   = 0;
      bbox_new(left_out_idx,3)  = bbox_new(left_out_idx,3)-left_out(left_out_idx); %Resize bbox
      bbox_new(top_out_idx,4)   = bbox_new(top_out_idx,4) -top_out(top_out_idx);   %Resize bbox
%       sum_res=sum(bbox_new(:,3)<0);
%       assert(sum_res==0);
%       sum_res=sum(bbox_new(:,4)<0);
%       assert(sum_res==0);      
      %2. Left dimension>frame_length or Top dimension>frame_height
      left_out                  = (bbox_new(:,1)+bbox_new(:,3))-(frame_length);
      top_out                   = (bbox_new(:,2)+bbox_new(:,4))-(frame_height);
      left_out_idx              = left_out>0;
      top_out_idx               = top_out>0;      
      bbox_new(left_out_idx,3)  = bbox_new(left_out_idx,3)-left_out(left_out_idx); %Resize bbox
      bbox_new(top_out_idx,4)   = bbox_new(top_out_idx,4)-top_out(top_out_idx); %Resize bbox
%       sum_res=sum(bbox_new(:,3)<0);
%       assert(sum_res==0);
%       sum_res=sum(bbox_new(:,4)<0);
%       assert(sum_res==0);  
      idx=bbox_new(:,3)>0;
      bbox_new=bbox_new(idx,:);
      new_label=new_label(idx);
      assoc_cost=assoc_cost(idx);
      idx=bbox_new(:,4)>0;
      bbox_new=bbox_new(idx,:);
      new_label=new_label(idx);
      assoc_cost=assoc_cost(idx);

      frameNum_track=[frameNum_track;repmat(k-1,[numel(new_label),1])];
      personNum_track=[personNum_track; new_label];
      assoc_cost=[assoc_cost; assoc_cost];     
            
      %Store bounding boxes
      bodyL_Track=[bodyL_Track; bbox_new(:,1)];
      bodyT_Track=[bodyT_Track; bbox_new(:,2)];
      bodyW_Track=[bodyW_Track; bbox_new(:,3)];
      bodyH_track=[bodyH_track; bbox_new(:,4)];
      
end

