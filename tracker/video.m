
%Parameters
FileInName='TownCentre.avi';
NumberOfFrames=5; %Manually set how many frames to extract
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='town_centre_track.avi';

%Read input video file and its associated properties
obj =VideoReader(fullfile(workingDir,FileInName));
numFrames = obj.NumberOfFrames
frameRate = obj.FrameRate

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = frameRate; %Set output framerate equal to input frame rate
open(outputVideo);

%Load DPM model
load VOC2010/person_final.mat;

%Load color labels
load color_spectrum.mat; %Color labels are in color_spectra2 variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R1 R2 R3 R4 R5 R6 ...
% G1 G2 G3 G4 G5 G6 ...
% B1 B2 B3 B4 B5 B6 ...

%Start timer
tic 

%Initialise
LAB_hist_OLD=[];
bbox_old=[];
old_label=[];

try
    for k = 1 : 2   %fill in the appropriate number

      %Read input frame
      this_frame = read(obj, k);
      disp(sprintf('Processing frame %d',k));

      %Process input frame
      [LAB_hist_NEW,bbox_new]=pedestrian_detect(this_frame,model,-0.5);
        %Compute Bhattacharyya coefficient of every combination and reorder them into appropriate matrix
        %for hungarian algorithm
        BC_MAT=BC_matrix(LAB_hist_OLD,LAB_hist_NEW);
        new_label=track(BC_MAT,old_label);

      %Annotate new frame
      frame_NEW=ins_label2(this_frame,bbox_new,new_label,color_spectra2,k);

      %Set old frame for next iteration
      LAB_hist_OLD=LAB_hist_NEW;
      old_label=new_label;

      %Write output frame
      %writeVideo(outputVideo,frame_NEW);
      figure
      imshow(frame_NEW)

    end
catch err
    disp('An error occured: ');
    disp(err.identifier);
    disp(err.message);
end

%End timer
toc
elapsedTime = toc/60;
disp(sprintf('Elapsed time is: %f mins',elapsedTime));

%Clean up
close(outputVideo)