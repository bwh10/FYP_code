%This function draws a bounding box over the image with labels
%bbox coordinate system
% --------------------->x
% |
% |
% |
% |
% |            Image
% |
% |
% |
% v
% y

function frame=ins_label3(im,bbox,labels,assoc_cost,frameNum)

    colorCells={[255 0 0], [0 0 255], [0 255 0], [0 0 0], [255 255 0], [255 0 255], [0 255 255]}; %Color assignment wraps around after 7 assignments
    [numBox z]=size(bbox);
    [ImX ImY]=size(im);
    
    frame=im;
    
    %Insert bounding boxes and label text
     for i=1:numBox 
       % if i==11
        color_idx=rem(labels(i),length(colorCells));
        if(color_idx==0)
            color_idx=length(colorCells);
        end    
        labelColor=cell2mat(colorCells(color_idx));
        
        %Draw bounding box
        frame=insertShape(frame,'rectangle',bbox(i,:),'Color',labelColor,'LineWidth',3);
        %Insert label
        frame=insertText(frame,[bbox(i,1) bbox(i,2)],sprintf('%d',labels(i)),'TextColor', labelColor,'BoxColor',[255 255 255],'FontSize',18);
        %Insert association cost
        if (assoc_cost(i)==2)
            assoc_cost_label='NEW';
        elseif (assoc_cost(i)==3)
            assoc_cost_label='PREDICTED';
        else
            assoc_cost_label=sprintf('%1.5e',assoc_cost(i));           
        end
        if ((bbox(i,2)+bbox(i,4))<(ImX-10))
            %Insert in bottom of bounding box
            frame=insertText(frame,[bbox(i,1) bbox(i,2)+bbox(i,4)],assoc_cost_label,'TextColor', labelColor,'BoxColor',[255 255 255],'FontSize',18);
        else
            %Insert in top of bounding box
            frame=insertText(frame,[bbox(i,1) bbox(i,2)],assoc_cost_label,'TextColor', labelColor,'BoxColor',[255 255 255],'FontSize',18,'AnchorPoint','LeftBottom');
        end
        %end
     end
    
    %Insert frame number
    frame=insertText(frame,[0 0],sprintf('Frame number: %d',frameNum),'TextColor', 'black','BoxColor','white','FontSize',25);
end

