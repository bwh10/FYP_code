%This script draws the tracker's result .mat file to the actual video
%sequence

clear all;

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='town_centre_track_500_dsup_safeassoc_bbox_stabilised_30dim_5centroid.avi';

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = 30; %Set output framerate 
open(outputVideo);

%Load tracker results
load track_bbox_stabilised.mat %Stabilised bounding box tracker results
%load tracker_result_dsup_safe_assoc.mat %Unstabilised bounding box tracker results

%Start timer
tic 

%frameNum_track(end)+1
    for k = 1 : frameNum_track(end)+1  %fill in the appropriate number

      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));
      
      bbox=[];
      %Get results for that particular frame
      idx=(frameNum_track==(k-1));
      bbox(:,1)=bodyL_Track(idx);
      bbox(:,2)=bodyT_Track(idx);   
      bbox(:,3)=bodyW_Track(idx);
      bbox(:,4)=bodyH_track(idx);  
      new_label=personNum_track(idx);
      assoc_cost=3.*ones(1,numel(new_label));

      %Annotate new frame
      frame_NEW=ins_label3(this_frame,bbox,new_label,assoc_cost,k);

      %Write output frame
      writeVideo(outputVideo,frame_NEW);

    end
    
%End timer
toc

%Clean up
close(outputVideo)
