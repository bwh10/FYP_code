function [ ...
    runTime ...
    frameNum_track, ...
    personNum_track, ...
    bodyL_Track, ...
    bodyT_Track, ...
    bodyW_Track, ...
    bodyH_track, ...
    assoc_cost, ...
    bbox_new ...
] = video_seq2( ...
    step_size ...
) 

%Parameters
numFrames=500;

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';

%Open output video handle
LFR_divider = 30; %Low frame rate divider

%Global variables
global part_deviation; %Keeps counts of the parts which deviates from the mode
global part_constant;  %Keeps counts of the parts which agrees with the mode

%Load detection results
load DPM_detect.mat

%Start timer
tic 

%Initialise
part_deviation=zeros(9,1); %9 parts
part_constant =zeros(9,1); %9 parts
LAB_hist_OLD=[];
bbox_old=[];
old_label=[];
frameNum_track=[];
personNum_track=[];
bodyL_Track=[];
bodyT_Track=[];
bodyW_Track=[];
bodyH_track=[];

%try
    for k = 1 : ceil(numFrames/LFR_divider)  %fill in the appropriate number
        
       %Start timer
       t=tic;

      if (k==1)
          frameNum=k;
      elseif (k==2)
          frameNum=1+LFR_divider;
      else
          frameNum=frameNum+LFR_divider;    
      end
      
      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,frameNum));
      disp(sprintf('Processing frame %d',frameNum));
      
      %Get bounding box detections for that particular frame
      bbox          = bbox_mat      (frame_Num==frameNum,:);
      bbox_parts    = bbox_mat_parts(frame_Num==frameNum,:);

      %Process input frame
      [LAB_hist_NEW,bbox_new]=pedestrian_detect_parts(this_frame,bbox,bbox_parts,1,step_size);
        %Compute Bhattacharyya coefficient of every combination and reorder them into appropriate matrix
        %for hungarian algorithm
        BC_MAT                                           =get_assoc       (LAB_hist_OLD,LAB_hist_NEW);
        [final_label, final_cost, new_label,assoc_cost]  =track_parts     (BC_MAT,old_label);

      %Store tracker results
      [ ...
            frameNum_track, ...
            personNum_track, ...
            bodyL_Track, ...
            bodyT_Track, ...
            bodyW_Track, ...
            bodyH_track, ...
            assoc_cost, ...
            bbox_new ...
        ] = store_tracker_results( ...
            frameNum, ...
            final_label, ...
            bbox_new, ...
            frameNum_track, ...
            personNum_track, ...
            bodyL_Track, ...
            bodyT_Track, ...
            bodyW_Track, ...
            bodyH_track, ...
            assoc_cost ...
        );
    
      %Set old frame for next iteration
      LAB_hist_OLD=LAB_hist_NEW;
      old_label=new_label;
      bbox_old=bbox_new;
      
      %Stop timer
      time=toc(t);
      disp(sprintf('Time taken for process frame %d: %f sec',frameNum,time));

    end
%catch err
%    disp('An error occured: ');
%    disp(err.identifier);
%    disp(err.message);
%end

%End timer
toc
runTime     = toc;
elapsedTime = toc/60;
disp(sprintf('Elapsed time is: %f mins',elapsedTime));
