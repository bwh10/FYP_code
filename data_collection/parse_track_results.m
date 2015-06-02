%This function parses the ground truth and actual tracker results to
%produce per frame:

%1. Object detection-hypothesis pair
%2. Number of missed objects 
%3. Number of false detections
%4. %Overlap of matched object-hypothesis pair


function [obj_hyp_pair,obj_hyp_overlap,Num_pairs,Num_missed,Num_fp,num_gt,num_hyp,gt_missed_ID,fp_missed_ID]=parse_track_results( ...
    frame_height, ...
    frame_length, ...
    frameNum, ...
    Frame_num_vec, ...
    personNum, ...
    bodyLeft, ...
    BodyRight, ...
    BodyTop,...
    BodyBottom, ...
    frameNum_track, ...
    personTrack_ID, ...
    bodyL_Track, ...
    bodyH_Track, ...
    bodyT_Track, ...
    bodyW_Track) ...
    
    %Find unique persons for current frame
    idx=find(Frame_num_vec==frameNum-1);
    unique_person_ID=personNum(idx);
    num_gt=numel(unique_person_ID); %Number of ground truth detections
    
    %Find unique persons bounding boxes
    %Ensure the ground truth bounding box do not go over the image
    %dimensions
    bodyL=max(1,bodyLeft(idx));
    bodyT=max(1,BodyTop(idx));
    bodyR=min(frame_length, BodyRight(idx));
    bodyB=min(frame_height, BodyBottom(idx));
    bbox=zeros(num_gt,4);
    bbox(:,1)=bodyL;    %Top Left x coord
    bbox(:,2)=bodyT;     %Top Left y coord
    bbox(:,3)=bodyR-bodyL; %Bounding box width
    bbox(:,4)=bodyB-bodyT; %Bounding box height
    
    %Find unique tracked persons for current frame
    idx_track=find(frameNum_track==frameNum-1);
    track_person_ID=personTrack_ID(idx_track);
    num_hyp=numel(track_person_ID); %Number of hypothesis detections
    
    %Find unique tracked persons bounding boxes
    bbox_track=zeros(num_hyp,4);
    bbox_track(:,1)=bodyL_Track(idx_track);	%Top Left x coord
    bbox_track(:,2)=bodyT_Track(idx_track);	%Top Left y coord
    bbox_track(:,3)=bodyW_Track(idx_track); %Bounding box width
    bbox_track(:,4)=bodyH_Track(idx_track); %Bounding box height
    
    %%%%%%%%%%%%%%%%%%%%%Find Object hypothesis pair ********************
    gt_assigned=zeros(num_gt,1);   %Flag to indicate whether a particular person's ground truth bbox was assigned
    actual_assigned=zeros(num_hyp,1);%Flag to indicate whether a particular person's hypothesis bbox was assigned
    storage_counter=1;              %Storage index
    for i=1:num_hyp %Iterate through the number of hypothesis detections
        
        %Narrow down the ground truth detections that has not yet been assigned
        not_gt_assigned_idx=find(gt_assigned==0);           %Index of the ground truth that has not yet been assigned
        Num_not_assigned=numel(not_gt_assigned_idx);        %Number of ground truth detections not yet assigned
        if (Num_not_assigned>0)
            gt_person_ID=unique_person_ID(not_gt_assigned_idx); %Ground truth person ID that has not yet been assigned
            bbox_gt=zeros(Num_not_assigned,4);                  %Initialise bounding box storage variable for not assigned ground truth detections
            bbox_gt(:,1)=bbox(not_gt_assigned_idx,1);
            bbox_gt(:,2)=bbox(not_gt_assigned_idx,2);
            bbox_gt(:,3)=bbox(not_gt_assigned_idx,3);
            bbox_gt(:,4)=bbox(not_gt_assigned_idx,4);

            %Get the closest ground truth bounding box
            bbox_hyp=repmat(bbox_track(i,:),[Num_not_assigned 1]); %Replicate bounding box row vector into an Num_not_assigned*4 matrix
            overlapRatio = bboxOverlapRatio(bbox_gt, bbox_hyp);
            overlapResult= overlapRatio(:,1);
            [maxOverlap, maxOverlap_idx]=max(overlapResult);

            %If the Closest bounding box overlap is valid
            if (maxOverlap>=0.5)
                actual_assigned(i)=1;                           %Raise the flag to say that that particular hypothesis bounding box has been assigned    
                gt_ID_assigned=gt_person_ID(maxOverlap_idx);    %Ground truth person ID that was assigned
                hyp_ID_assigned=track_person_ID(i);             %Tracked person ID that was assigned
                gt_assigned(unique_person_ID==gt_ID_assigned)=1;%Raise the flag to say that that particular ground truth bounding box has been assigned            

                %Put relevant variables in storage
                obj_hyp_pair(storage_counter,1)=gt_ID_assigned;
                obj_hyp_pair(storage_counter,2)=hyp_ID_assigned;
                obj_hyp_overlap(storage_counter)=maxOverlap;

                storage_counter=storage_counter+1;
            end
        end
        
    end
    
    %Return other statistics
    Num_missed=sum(gt_assigned==0); %Number of ground truth bounding boxes that are not assigned
    gt_missed_ID=unique_person_ID(gt_assigned==0); %IDs of ground truth that are missed
    fp_missed_ID=track_person_ID( actual_assigned==0); %IDs of hypothesis that are missed
    Num_fp=sum(actual_assigned==0); %Number of hypothesis bounding boxes that are not assigned
    Num_pairs=storage_counter-1;    %Number of Object-hypothesis pairs
end