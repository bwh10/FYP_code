classdef tracks < handle
    %TRACKS Summary of this class goes here
    %   This class stores the previous tracks (coordinate, bounding boxes)
    %   and has the necessary methods to operate on them. 
    
    properties
        frameNum            %Current frame number
        frameLength=1920
        frameHeight=1080
        bbox_current        %Current bounding boxes active
        current_labels      %Current labels associated to bounding boxes
        assoc_cost          %Current hungarian algorithm association cost
        predict_count       %How far are away in the prediction of bbox_current
        prev_coord          %Previous stored coordinates of the tracks used for prediction
        prev_coord_count    %The number of previous coordinates stored
        true_coord_count    %The number of detected coordinates stored
        pred_coord_count    %The number of predicted coordinates stored
        prev_coord_compo    %Composition ratio of previous coordinates: # of predicted coordinates/# of acutal coordinate
        predict_line        %y=mx+c interpolated line
        prev_coord_length=60%Max number of previous coordinates to store
        overlapThreshold=0.1%Less than this amount is not safe
        pred_length=60      %How long to keep predictions in terms of frames
        min_coord=15        %Minimum number of past coordinates to perform interpolation
        max_pred_ratio=3    %Maximum number of predicted coordinate to true coordinate ratio allowed for interpolation to happen
        max_ID              %Keep track of how many unique ppl have been detected
    end
    
    methods
        function [new_labels,assoc_cost]=initialise (this, bbox_new)
            [bbox_sizex,bbox_sizey]=size(bbox_new);
            new_labels              =(1:bbox_sizex)';
            this.current_labels     =new_labels;
            this.bbox_current       =bbox_new;
            this.predict_count      =zeros(bbox_sizex,1);
            this.assoc_cost         =2.*ones(bbox_sizex,1);
            this.prev_coord_count   =ones(bbox_sizex,1);
            this.true_coord_count   =ones(bbox_sizex,1);
            this.pred_coord_count   =zeros(bbox_sizex,1);
            this.prev_coord_compo   =zeros(bbox_sizex,1);
            assoc_cost=this.assoc_cost;
            for i=1:bbox_sizex
                this.prev_coord{i}.x=bbox_new(i,1)+bbox_new(i,3)/2;
                this.prev_coord{i}.y=bbox_new(i,2)+bbox_new(i,4)/2;
                this.prev_coord{i}.predict=0;   %This coordinate is not predicted
                this.predict_line(i).grad_x=0;  %The interpolated gradient for x coordinate
                this.predict_line(i).int_x=0;   %The interpolated y-intercept for x coordinate
                this.predict_line(i).grad_y=0;  %The interpolated gradient for y coordinate
                this.predict_line(i).int_y=0;   %The interpolated y-intercept for y coordinate
            end
            this.max_ID=bbox_sizex;
        end
        
        %This function does an association between the new bbox detection
        %and currently stored bounding boxes
        function [new_labels,assoc_cost]=assoc(this,bbox_new) %Note: new_label is labels assigned to bbox_new detections!
             [bbox_sizex,bbox_sizey]=size(bbox_new);
            %Perform association
            %Get similarity measure
            bbox_overlap=bboxOverlapRatio(bbox_new,this.bbox_current); %Row index is old, Column index is new
            %Get dissimilarity level
            bbox_apart=1-bbox_overlap;
            %Apply Hungarian algorithm for min cost assignment
            [assignment,~]=munkres(bbox_apart);
            assoc_cost=zeros(bbox_sizex,1);
            for i=1:bbox_sizex
               if (assignment(i)~=0) %Valid association
                    assoc_cost(i)=bbox_apart(i,assignment(i));
               else
                   assoc_cost(i)=2; %Not assigned
               end
            end
            
             %Valid associations to old labels
            new_labels=zeros(bbox_sizex,1);
            new_labels(assignment>0)=this.current_labels(assignment(assignment>0));
            
             %Check for safe association
            for i=1:bbox_sizex
                if (new_labels(i)~=0) %Valid association
                    if ((1-assoc_cost(i))<=this.overlapThreshold) %Unsafe association
                        new_labels(i)=0; %Reset labels
                        assoc_cost(i)=2; %Reset association cost
                    end
                end
            end           
        end
        
        %This function deals with the cleanup of variables which tracks the prediction statuses of detections 
        function prediction_var_cleanup(this, new_labels,assoc_cost)
            %Reset prediction counts for old labels that have associations
            %to new detections
            [intersect_res,idx_rst,idx_fam]=intersect(this.current_labels,new_labels);
            this.predict_count(idx_rst)         =0;
            [this.predict_line(idx_rst).grad_x] =deal(0);
            [this.predict_line(idx_rst).int_x]  =deal(0);
            [this.predict_line(idx_rst).grad_y] =deal(0);
            [this.predict_line(idx_rst).int_y]  =deal(0);
            this.assoc_cost(idx_rst)            =assoc_cost(idx_fam);
            
            %Increment prediction counter for current labels not being
            %detected in new frame
            idx_inc=setdiff(1:numel(this.current_labels),idx_rst);
            this.predict_count(idx_inc)=this.predict_count(idx_inc)+1;
            
            %Throw away any predictions that have: 
            %1. overstep the prediction count
            %2. do not have enough previous coordinates to make a
            % worthwhile prediction
            %3. Have too much previous predicted coordinates as compared to
            %actual detected coordinates for accurate predictions to be
            %made
            idx_predict_overflow    =find(this.predict_count>this.pred_length);
            idx_predict_low_coord   =intersect(find(this.predict_count==1),find(this.prev_coord_count<this.min_coord));
            idx_predict_ratio_bad   =intersect(find(this.predict_count>0),find(this.prev_coord_compo>this.max_pred_ratio));
            idx_throw               =union(idx_predict_overflow,idx_predict_low_coord);
            idx_throw               =union(idx_throw,idx_predict_ratio_bad);
            
            this.bbox_current       (idx_throw,:)=[];
            this.current_labels     (idx_throw)=[];
            this.predict_count      (idx_throw)=[];
            this.true_coord_count   (idx_throw)=[];
            this.pred_coord_count   (idx_throw)=[];
            this.prev_coord         (idx_throw)=[];
            this.prev_coord_count   (idx_throw)=[];
            this.predict_line       (idx_throw)=[];
            this.assoc_cost         (idx_throw)=[];

        end
        
        %This function adds to the prev_coord array and updates the other appropriate supporting variables respectively 
        function update_prev_coord(this,idx,coord_new)
            %Prune of old past coordinates
                if (this.prev_coord_count(idx)>this.prev_coord_length)
                    this.prev_coord_count(idx)=this.prev_coord_count(idx)-1;
                    if (this.prev_coord{idx}.predict(1)==0)
                        this.true_coord_count(idx)=this.true_coord_count(idx)-1;
                    else
                        this.pred_coord_count(idx)=this.pred_coord_count(idx)-1;
                    end
                    
                    if (this.true_coord_count(idx)==0)
                        this.prev_coord_compo(idx)=10000; %A very large number so we do not have a divide by 0 problem
                    else
                        this.prev_coord_compo(idx)=this.pred_coord_count(idx)/ this.true_coord_count(idx);
                    end
                    %Throw away 1st element of prev coord
                    this.prev_coord{idx}.x      (1) =[];
                    this.prev_coord{idx}.y      (1) =[];
                    this.prev_coord{idx}.predict(1) =[];
                end
                 %Push to prev_coord_store
                this.prev_coord{idx}.x      =[this.prev_coord{idx}.x;coord_new.x];
                this.prev_coord{idx}.y      =[this.prev_coord{idx}.y;coord_new.y];
                this.prev_coord{idx}.predict=[this.prev_coord{idx}.predict;coord_new.predict];
                this.prev_coord_count(idx)=this.prev_coord_count(idx)+1;  
                if (coord_new.predict==0)
                    this.true_coord_count(idx)=this.true_coord_count(idx)+1;
                else
                    this.pred_coord_count(idx)=this.pred_coord_count(idx)+1;
                end
                
                if (this.true_coord_count(idx)==0)
                    this.prev_coord_compo(idx)=10000; %A very large number so we do not have a divide by 0 problem
                else
                    this.prev_coord_compo(idx)=this.pred_coord_count(idx)/ this.true_coord_count(idx);
                end
        end
        
        function add_to_track(this,new_labels,bbox_new)
            [intersect_res,idx_rst,idx_fam]=intersect(this.current_labels,new_labels);
            
            %Add familiar detections to track
            this.bbox_current(idx_rst,:)=bbox_new(idx_fam,:);
            centroid_x=bbox_new(idx_fam,1)+bbox_new(idx_fam,3)./2;
            centroid_y=bbox_new(idx_fam,2)+bbox_new(idx_fam,4)./2;   
            for i=1:numel(idx_fam)
                idx=idx_rst(i);
                centroid.x      =centroid_x(i);
                centroid.y      =centroid_y(i);
                centroid.predict=0;
                update_prev_coord(this,idx,centroid);
            end
            
            %Add new detections to track
            num_to_add=numel(find(new_labels==0));
            centroid_x=bbox_new(new_labels==0,1)+bbox_new(new_labels==0,3)./2;
            centroid_y=bbox_new(new_labels==0,2)+bbox_new(new_labels==0,4)./2;  
            count=1;
            for i=(numel(this.current_labels)+1):(numel(this.current_labels)+num_to_add)
                this.prev_coord{i}.x        =centroid_x(count);
                this.prev_coord{i}.y        =centroid_y(count);
                this.prev_coord{i}.predict  =0;                
                this.prev_coord_count(i)    =1;    
                this.true_coord_count(i)    =1;
                this.pred_coord_count(i)    =1;
                this.prev_coord_compo(i)    =0;
                this.predict_line(i).grad_x =0;  %The interpolated gradient for x coordinate
                this.predict_line(i).int_x  =0;   %The interpolated y-intercept for x coordinate
                this.predict_line(i).grad_y =0;  %The interpolated gradient for y coordinate
                this.predict_line(i).int_y  =0;   %The interpolated y-intercept for y coordinate
                count=count+1;
            end
            this.assoc_cost=[this.assoc_cost;2.*ones(num_to_add,1)];
            this.bbox_current=[this.bbox_current;bbox_new(new_labels==0,:)];
            labels_to_add=[(this.max_ID+1):(this.max_ID+num_to_add)]';
            this.max_ID=this.max_ID+num_to_add;
            this.current_labels=[this.current_labels;labels_to_add];
            this.predict_count=[this.predict_count;zeros(num_to_add,1)];
        end
        
       %This function predicts the lost detections time step at this
        %current frame
        function predict(this)
            idx_predict=find(this.predict_count>0); 
            %Do prediction
            for i=1:numel(idx_predict)
                idx=idx_predict(i);
                num_recorded_coord=this.prev_coord_count(idx);
                if ((this.predict_count(idx)>1)&&(num_recorded_coord>this.min_coord)) %We already have the line equation
                    predicted_coord.x=this.predict_line(idx).grad_x*this.frameNum+this.predict_line(idx).int_x;
                    predicted_coord.y=this.predict_line(idx).grad_y*this.frameNum+this.predict_line(idx).int_y;
                    predicted_coord.predict=1;
                elseif ((this.predict_count(idx)==1)&&(num_recorded_coord>=this.min_coord))  %We do not have the line equation
                    %Get interpolated gradient and y intercepts for x and y
                    %coordinates
                    time=[(this.frameNum-num_recorded_coord):(this.frameNum-1)]';
                    x=[this.prev_coord{idx}.x];
                    y=[this.prev_coord{idx}.y];
                    coeffs_x = polyfit(time, x, 1);
                    this.predict_line(idx).grad_x = coeffs_x(1);
                    this.predict_line(idx).int_x = coeffs_x(2);
                    coeffs_y = polyfit(time, y, 1);
                    this.predict_line(idx).grad_y = coeffs_y(1);
                    this.predict_line(idx).int_y= coeffs_y(2);
                    %Get prediction of coordinates
                    predicted_coord.x= coeffs_x(1)*this.frameNum+coeffs_x(2);
                    predicted_coord.y= coeffs_y(1)*this.frameNum+coeffs_y(2);
                    predicted_coord.predict=1;
                else
                    %Cannot get line interpolation formula as we do not
                    %have enough past data
                end
                
                %Put into prev coord record
                update_prev_coord(this,idx,predicted_coord);
                %Update bbox_current using last known bbox dimensions
                this.bbox_current(idx,1)=this.prev_coord{idx}.x(end) - this.bbox_current(idx,3)/2;  %Left
                this.bbox_current(idx,2)=this.prev_coord{idx}.y(end) - this.bbox_current(idx,4)/2;  %Top
                
                %Check predicted coordinates dimensions
                bbox_length=this.bbox_current(idx,1)+this.bbox_current(idx,3);
                bbox_height=this.bbox_current(idx,2)+this.bbox_current(idx,4);
                %Prediction goes beyond frame dimensions
                if ((bbox_length>1.03*this.frameLength) || (bbox_height>1.03*this.frameHeight) || (this.bbox_current(idx,1)<-0.03*this.frameLength) || (this.bbox_current(idx,2)<-0.03*this.frameHeight)) 
                    %Stop the prediction for the next frame
                    this.predict_count(idx)=this.pred_length+1;
                end
                
                %Update assoc cost to reflect that this is a prediction
                this.assoc_cost(idx)=3.0;
            end
            
        end
        
        function [new_labels_out,bbox_out,assoc_cost_out,is_predict] = output(this)
            bbox_out            = this.bbox_current;
            new_labels_out      = this.current_labels;
            is_predict          = this.predict_count>0;
            assoc_cost_out      = this.assoc_cost;
        end
        
        function [new_labels_out,bbox_out,assoc_cost,is_predict]=add (this,bbox_new)
            %Associate new detections to current detections
            [new_labels,assoc_cost]=assoc(this,bbox_new);
            %bbox_out=bbox_new;
            %is_predict=0;   
            
            %Cleanup appropriate internal variable handles
            prediction_var_cleanup(this, new_labels,assoc_cost);
            add_to_track(this,new_labels,bbox_new);
            
            %Perform prediction on next timestep
            predict(this);
            
            %Output labels and bbox
            [new_labels_out,bbox_out,assoc_cost,is_predict]=output(this);
        end
        
        function [new_labels, bbox_out, assoc_cost,is_predict]=track (this, frameNum, bbox_new)
            this.frameNum=frameNum;
            if (frameNum == 1)
                [new_labels,assoc_cost]=initialise(this,bbox_new);
                bbox_out=bbox_new;
                is_predict=zeros(numel(new_labels),1);
            else
                [new_labels,bbox_out,assoc_cost,is_predict]=add(this,bbox_new);
            end
        end
    end
    
end

