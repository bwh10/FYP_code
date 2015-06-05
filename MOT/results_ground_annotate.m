%This script annotates the Oxford dataset with ground truth data and actual
%tracking result

%Parameters
numFrames=1;
load 'oxford_ground_truth.mat';
load 'tracker_result.mat'

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='ground_track_oxford.avi';

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = 30; %Set output framerate 
open(outputVideo);

%Start timer
tic 

%try
    for k = 1 : numFrames   %fill in the appropriate number

      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));

      %Annotate new frame
      frame_NEW=annotate_both(this_frame,k,FrameNum,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personNum_track,bodyL_Track,bodyH_track,bodyT_Track,bodyW_Track);
      
      %Calculate performance metric
      [obj_hyp_pair,obj_hyp_overlap,Num_pairs,Num_missed,Num_fp,num_gt,num_hyp,gt_missed_ID,fp_missed_ID]=parse_track_results(k,FrameNum,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personNum_track,bodyL_Track,bodyH_track,bodyT_Track,bodyW_Track);
      %[MOTP,MOTA,miss_ratio,fp_ratio,IDsw_ratio, Accum_ID_SW_OUT]= calculate_metric(numFrames,k,FrameNum,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personNum_track,bodyL_Track,bodyH_track,bodyT_Track,bodyW_Track);
      
      %Write output frame
      writeVideo(outputVideo,frame_NEW);

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