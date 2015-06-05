%This script calculates the MOT performance criteria and displays them

clear all
%Parameters
numFrames=500;
load 'oxford_ground_truth.mat';
load 'tracker_bipartite_linear_predictor.mat'
%load 'tracker_result_dsup_safe_assoc_overlap.mat'
%load 'tracker_result_double_suppressed.mat'
%load 'tracker_result.mat'

frame_height = 1080; %Num of rows
frame_length = 1920; %Num of pixels in 1 row

%Start timer
tic 

%try
    for k = 1 : numFrames   %fill in the appropriate number
      disp(sprintf('Processing frame %d',k));
      
      %Calculate performance metric
      [MOTP,MOTA,miss_ratio,fp_ratio,IDsw_ratio, Accum_ID_SW_OUT]= calculate_metric(frame_height,frame_length,numFrames,k,FrameNum,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personNum_track,bodyL_Track,bodyH_track,bodyT_Track,bodyW_Track);
      

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

%Display statistics
disp('MOTP:');
MOTP
disp('MOTA:');
MOTA
disp('Miss Ratio:');
miss_ratio
disp('False Positive Ratio:');
fp_ratio
disp('ID Switch ratio:');
IDsw_ratio
disp('Number of ID switches');
Accum_ID_SW_OUT
