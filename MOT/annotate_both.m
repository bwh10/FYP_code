%This script provides ground truth and tracker annotation for Oxford town centre
%dataset

function frame=annotate_both(this_frame,frameNum,Frame_num_vec,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom,frameNum_track,personTrack_ID,bodyL_Track,bodyH_Track,bodyT_Track,bodyW_Track)
    frame=this_frame;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%Annotate ground truth%%%%%%%%%%%%%%%%%%%%
    
    %Find unique persons for current frame
    idx=find(Frame_num_vec==frameNum-1);
    unique_person_ID=personNum(idx);    
    
    %Find unique persons bounding boxes
    bbox=zeros(numel(unique_person_ID),4);
    bbox(:,1)=bodyLeft(idx);    %Top Left x coord
    bbox(:,2)=BodyTop(idx);     %Top Left y coord
    bbox(:,3)=BodyRight(idx)-bodyLeft(idx); %Bounding box width
    bbox(:,4)=BodyBottom(idx)-BodyTop(idx); %Bounding box height

    %Draw bounding box
    frame=insertShape(frame,'rectangle',bbox,'Color','red','LineWidth',3);
    
    %Annotate unique person ID
    frame=insertText(frame,[bbox(:,1) bbox(:,2)],unique_person_ID,'TextColor', 'red','BoxColor','white','FontSize',18);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%Annotate tracker%%%%%%%%%%%%%%%%%%%%
    bbox=[];
    idx=[];
    %Find unique persons for current frame
    idx=find(frameNum_track==frameNum-1);
    unique_person_ID=personTrack_ID(idx);
    
     %Find unique persons bounding boxes
    bbox(:,1)=bodyL_Track(idx);	%Top Left x coord
    bbox(:,2)=bodyT_Track(idx);	%Top Left y coord
    bbox(:,3)=bodyW_Track(idx); %Bounding box width
    bbox(:,4)=bodyH_Track(idx); %Bounding box height
    
    %Draw bounding box
    frame=insertShape(frame,'rectangle',bbox,'Color','blue','LineWidth',3);
    
    %Annotate unique person ID
    frame=insertText(frame,[bbox(:,1)+bbox(:,3) bbox(:,2)+bbox(:,4)],unique_person_ID,'TextColor', 'blue','BoxColor','white','FontSize',18,'AnchorPoint','RightBottom');
	
    %Insert frame number
	frame=insertText(frame,[0 0],sprintf('Frame number: %d',frameNum),'TextColor', 'black','BoxColor','white','FontSize',25);
end