%This script provides ground truth annotation for Oxford town centre
%dataset

function frame=annotate(this_frame,frameNum,Frame_num_vec,personNum,bodyLeft,BodyRight,BodyTop,BodyBottom)
    frame=this_frame;
    
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
    frame=insertText(frame,[bbox(:,1) bbox(:,2)],unique_person_ID,'TextColor', 'black','BoxColor','white','FontSize',18);
        
	%Insert frame number
	frame=insertText(frame,[0 0],sprintf('Frame number: %d',frameNum),'TextColor', 'black','BoxColor','white','FontSize',25);
end