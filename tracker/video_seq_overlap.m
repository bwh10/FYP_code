%This script performs tracking via overlap of bbox of 2 consecutive frames

%Parameters
numFrames=500;

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='town_centre_test3.avi';

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = 15; %Set output framerate 
open(outputVideo);

%Load detection results
load DPM_detect.mat

%Start timer
tic 

%Initialise
global ped_track;
ped_track=tracks;
bbox_old=[];
old_label=[];
frameNum_track=[];
personNum_track=[];
bodyL_Track=[];
bodyT_Track=[];
bodyW_Track=[];
bodyH_track=[];
assoc_cost=[];

%try
    for k = 1 : numFrames  %fill in the appropriate number
        
       %Start timer
       t=tic;

      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));
      
      %Get bounding box detections for that particular frame
      bbox_new = bbox_mat(frame_Num==k,:);

      %Process input frame
      bbox_new = suppress_double_detect(bbox_new);
      [new_label,bbox_new,assoc_cost,is_predict]=ped_track.track(k,bbox_new);
      
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
        );
       %Annotate new frame
      %frame_NEW=ins_label3(this_frame,bbox_new,new_label,assoc_cost,k);
      
      %Set old frame for next iteration
      %old_label=new_label;
      %bbox_old=bbox_new;

      %Write output frame
      %writeVideo(outputVideo,frame_NEW);
      %if (k==numFrames)
      %  imshow(frame_NEW);
      %end
      
      %Stop timer
      time=toc(t);
      disp(sprintf('Time taken for process frame %d: %f sec',k,time));

    end
%catch err
%    disp('An error occured: ');
%    disp(err.identifier);
%    disp(err.message);
%end

%End timer
toc
elapsedTime = toc/60;
disp(sprintf('Elapsed time is: %f mins',elapsedTime));

%Clean up
close(outputVideo)

%Save tracker results in .mat
save('tracker_bipartite_linear_predictor.mat','assoc_cost','frameNum_track','personNum_track','bodyL_Track','bodyT_Track','bodyW_Track','bodyH_track');