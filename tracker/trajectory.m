classdef trajectory < handle
    %TRAJECTORY Summary of this class goes here
    %   This class stores the trajectory history of past detections
    
    properties
       history                  %Trajectory history. It is a key-value map object with the keys being the detection label number
       frame_rate=30            %In terms of frames per second
       pred_length=30           %How long should predictor run? Default is 1 second
       pred_key=[]              %List of key values that have predictor running
    end
    
    methods
        function initialise(this,labels,bbox)
            num_detections=numel(labels);
            for i=1:num_detections
                centroid.x=bbox(i,1)+bbox(i,3)/2;
                centroid.y=bbox(i,2)+bbox(i,4)/2;
                centroid.length=bbox(i,3);
                centroid.height=bbox(i,4);
                centroid.pred_count=0;  %How many steps have we been predicting
                centroid.grad=0;        %Gradient of the interpolation
                centroid.y_int=0;       %Gradient of the y intercept
                if (i==1)
                    this.history = containers.Map(labels(1),centroid);
                else
                    this.history(labels(i)) = centroid;
                end
            end
        end
        
        function add(this,new_label,bbox_new)
              idx_unassigned=add_to_current(this,new_label,bbox_new);
        end
        
        %1. Adds trajectories of new labels that have associations to old labels
        %2. Returns index of new labels that have no associations to old
        %labels
        function idx_unassigned=add_to_current(this,new_label,bbox_new) 
            num_detections=numel(new_label);
            idx_unassigned=[];
            for i=1:num_detections
                if (this.history.isKey(new_label(i))==1)
                    centroid    = this.history(new_label(i));
                    %Add trajectory
                    centroid.x  = [centroid.x bbox_new(i,1)+bbox_new(i,3)/2];
                    centroid.y  = [centroid.y bbox_new(i,2)+bbox_new(i,4)/2];
                    centroid.length=bbox_new(i,3);
                    centroid.height=bbox_new(i,4);     
                    this.history(new_label(i)) = centroid;
                else
                    idx_unassigned = [idx_unassigned i];
                end
            end
        end
        
        %This function assigns any new labels to the closest predicted
        %trajectory of previous detections that have been lost
        %Returns indices of new_labels that cannot be matrched with a
        %predicted trajectory
        function idx_left=assign_predictor(this,idx_unassigned,new_label,bbox_new)
            num_unassigned=numel(idx_unassigned);
            num_pred=numel(this.pred_key); %How many predictors are currently running
            idx_left=idx_unassigned;
            
            if (num_pred>0)

            end
        end

    end
    
end

