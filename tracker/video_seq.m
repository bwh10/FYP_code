%Parameters
numFrames=500;

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='town_centre_track_500f_dsup_safe_assoc.avi';

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = 30; %Set output framerate 
open(outputVideo);

%Load DPM model
load VOC2010/person_final.mat;

%Start timer
tic 

%Initialise
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
    for k = 1 : numFrames  %fill in the appropriate number
        
       %Start timer
       t=tic;

      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));

      %Process input frame
      [LAB_hist_NEW,bbox_new]=pedestrian_detect(this_frame,model,-0.3,1);
        %Compute Bhattacharyya coefficient of every combination and reorder them into appropriate matrix
        %for hungarian algorithm
        BC_MAT=BC_matrix(LAB_hist_OLD,LAB_hist_NEW);
        [new_label,assoc_cost]=track3(BC_MAT,old_label,bbox_old,bbox_new);

      %Annotate new frame
      frame_NEW=ins_label3(this_frame,bbox_new,new_label,assoc_cost,k);
      
      %Store tracker results
      frameNum_track=[frameNum_track;repmat(k-1,[numel(new_label),1])];
      personNum_track=[personNum_track; new_label];
      bodyL_Track=[bodyL_Track; bbox_new(:,1)];
      bodyT_Track=[bodyT_Track; bbox_new(:,2)];
      bodyW_Track=[bodyW_Track; bbox_new(:,3)-bbox_new(:,1)];
      bodyH_track=[bodyH_track; bbox_new(:,4)-bbox_new(:,2)];

      %Set old frame for next iteration
      LAB_hist_OLD=LAB_hist_NEW;
      old_label=new_label;
      bbox_old=bbox_new;

      %Write output frame
      writeVideo(outputVideo,frame_NEW);
      
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
save('tracker_result_dsup_safe_assoc.mat','frameNum_track','personNum_track','bodyL_Track','bodyT_Track','bodyW_Track','bodyH_track');