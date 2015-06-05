%This script extracts out the bounding box detections from an appropriate
%detector and applies them to a sequence of frames, storing the final
%result in a .mat file that can be easily and fastly extracted out

%Parameters
numFrames=500;

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';

%Load DPM model
load VOC2010/person_final.mat;

%Parameters for detector
threshold=-0.3;

%Initialise storage
bbox_orig=[];
bbox_mat=[];
frame_Num=[];
bbox_centroid.x=[];
bbox_centroid.y=[];

%Start timer
tic 

    for k = 1 : numFrames  %fill in the appropriate number
        
       %Start timer
       t=tic;

      %Read input frame
      im = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));

      %Apply detector
      bbox    = process(im, model, threshold);
      [x,y] = size(bbox);
      
      %Save output
      bbox_orig=[bbox_orig;bbox]; %Original format [L T R B]
      bbox_mat=[bbox_mat;[bbox(:,1) bbox(:,2) bbox(:,3)-bbox(:,1) bbox(:,4)-bbox(:,2)]]; %In MATLAB convention [L T Width Height]
      bbox_centroid.x=[bbox_centroid.x;bbox(:,1)+(bbox(:,3)-bbox(:,1))./2];
      bbox_centroid.y=[bbox_centroid.y;bbox(:,2)+(bbox(:,4)-bbox(:,2))./2];
      frame_Num=[frame_Num;k.*ones(x,1)];
      
      %Stop timer
      time=toc(t);
      disp(sprintf('Time taken for process frame %d: %f sec',k,time));

    end

%End timer
toc
elapsedTime = toc/60;
disp(sprintf('Elapsed time is: %f mins',elapsedTime));

%Save detector results in .mat
save('DPM_detect.mat','bbox_orig','bbox_mat','bbox_centroid','frame_Num');