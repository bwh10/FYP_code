%This function performs tracking based on the bbox overlap between 2
%consecutive frames

function [new_labels,cost_assoc]=track_overlap(bbox_new, bbox_old,old_labels)
    %Declare global accumulative variables
    global max_ID; 
    global track_hist; 
    overlapThreshold=0; %Less than this amount is not safe
    
    [bbox_sizex,bbox_sizey]=size(bbox_new);
    
    if (isempty(bbox_old)) %We are in the first frame 
        track_hist=trajectory;
        new_labels=1:bbox_sizex;
        new_labels=new_labels';
        cost_assoc=zeros(bbox_sizex,1);
        max_ID=max(new_labels);
        track_hist.initialise(new_labels,bbox_new);
    else %We are not in the first frame
        %Get similarity measure
        bbox_overlap=bboxOverlapRatio(bbox_new,bbox_old); %Row index is old, Column index is new
        %Get dissimilarity level
        bbox_apart=1-bbox_overlap;
        %Apply Hungarian algorithm for min cost assignment
        [assignment,~]=munkres(bbox_apart);
        cost_assoc=zeros(bbox_sizex,1);
        for i=1:bbox_sizex
           if (assignment(i)~=0) %Valid association
                cost_assoc(i)=bbox_apart(i,assignment(i));
           else
               assoc_cost(i)=2; %Not assigned
           end
        end
        
        %Valid associations to old labels
        new_labels=zeros(bbox_sizex,1);
        new_labels(assignment>0)=old_labels(assignment(assignment>0));
        
        %Check for safe association
        for i=1:bbox_sizex
           if (new_labels(i)~=0) %Valid association
               if ((1-cost_assoc(i))<=overlapThreshold)
                  new_labels(i)=0; 
               end
           end
        end
        
        %Save new trajectory and perform any trajectory predictions 
        track_hist.add(new_labels,bbox_new);
        
         %Handle Null associations by introducing new labels that has not
        %been assinged to avoid confusion
        if (max_ID<max(old_labels))
            max_ID=max(old_labels);
        end
        new_labels(new_labels==0)=[max_ID+1:max_ID+sum(new_labels==0)];
        
    end
end