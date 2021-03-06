%This function calculates:
% 1. MOTA
% 2. MOTP
% 3. Number of ID switches 
% 4. Sub MOTA metrics

function [MOTP,MOTA,miss_ratio,fp_ratio,IDsw_ratio, Accum_ID_SW_OUT]= calculate_metric( ...
    frame_height, ...
    frame_length, ...
    TotalFrames, ...
    frameNum,...
    Frame_num_vec,...
    personNum,...
    bodyLeft,...
    BodyRight,...
    BodyTop,...
    BodyBottom,...
    frameNum_track,...
    personTrack_ID,...
    bodyL_Track,...
    bodyH_Track,...
    bodyT_Track,...
    bodyW_Track)...

  [obj_hyp_pair,obj_hyp_overlap,Num_pairs,Num_missed,Num_fp,num_gt,num_hyp,gt_missed_ID,fp_missed_ID]=parse_track_results(frame_height,frame_length,frameNum,Frame_num_vec,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personTrack_ID,bodyL_Track,bodyH_Track,bodyT_Track,bodyW_Track);
  Num_ID_SW=0;
  if (frameNum<TotalFrames)
    %Get next frame
    idx=find(frameNum_track==(frameNum-1));
    idx=idx(end)+1;
    next_frame_Num=frameNum_track(idx)+1;
    %Get next frame obj-hyp pair
    [obj_hyp_pair2,~]=parse_track_results(frame_height,frame_length,next_frame_Num,Frame_num_vec,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personTrack_ID,bodyL_Track,bodyH_Track,bodyT_Track,bodyW_Track);   
    %Calculate the number of ID switches
     Num_ID_SW  = calculate_IDsw( obj_hyp_pair, obj_hyp_pair2 );
  end
    
  %Declare global accumulative variables
  global Accum_NumPairs Accum_overlap; %MOTP
  global Accum_miss Accum_hyp Accum_fp Accum_ID_SW; %MOTA
  
  %Initialise global accumulative variables
  if (frameNum==1)
      Accum_NumPairs=0;
      Accum_overlap =0;
      Accum_miss    =0;
      Accum_hyp     =0;
      Accum_fp      =0;
      Accum_ID_SW   =0;
  end
  
   %%%%%%%%%%%%%%%%%%%%%%Accumulate metric variables%%%%%%%%%%%%%%%%%
   %1. Calculate MOTA
   Accum_NumPairs=Accum_NumPairs+Num_pairs;
   Accum_overlap=Accum_overlap+sum(obj_hyp_overlap);
   if (Accum_NumPairs~=0)
       MOTP=Accum_overlap/Accum_NumPairs;
   else
       MOTP=0;
   end
   %2. Calculate MOTA and its sub metrics
   Accum_hyp=Accum_hyp+num_hyp;
   Accum_miss=Accum_miss+Num_missed;
   Accum_fp=Accum_fp+Num_fp;
   Accum_ID_SW=Accum_ID_SW+Num_ID_SW;
   Accum_ID_SW_OUT=Accum_ID_SW;
   
   miss_ratio   =Accum_miss/Accum_hyp;
   fp_ratio     =Accum_fp/Accum_hyp;
   IDsw_ratio   =Accum_ID_SW_OUT/Accum_hyp;
   
   MOTA = 1-(miss_ratio+fp_ratio+IDsw_ratio);
end