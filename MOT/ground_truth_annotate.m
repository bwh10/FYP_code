%This script annotates the Oxford dataset with ground truth data

%Parameters
numFrames=500;
load 'oxford_ground_truth.mat';

%File IO Parameters
FolderIn='/home/bryan/FYP/P_tracker/vid_sequence/frame_seq/';
workingDir='/home/bryan/FYP/P_tracker/vid_sequence';
FileOutName='ground_truth_oxford.avi';

%Open output video handle
outputVideo = VideoWriter(fullfile(workingDir,FileOutName));
outputVideo.FrameRate = 30; %Set output framerate 
open(outputVideo);

%Start timer
tic 

try
    for k = 1 : 1   %fill in the appropriate number

      %Read input frame
      this_frame = imread(sprintf('%s%d.jpg',FolderIn,k));
      disp(sprintf('Processing frame %d',k));

      %Annotate new frame
      frame_NEW=annotate(this_frame,k,FrameNum,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom);

      %Write output frame
      %writeVideo(outputVideo,frame_NEW);
      
      imshow(frame_NEW);

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