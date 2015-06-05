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

function frame=ins_label2(im,bbox,labels,assoc_cost,color_cells,frameNum)

    [~,numColor]=size(color_cells);   
    [numBox z]=size(bbox);
    [ImX ImY]=size(im);
    
    frame=im;
    
    assoc_cost
    
    %Insert bounding boxes and label text
     for i=1:numBox
         
        color_idx=rem(labels(i),numColor);
        if(color_idx==0)
            color_idx=numColor;
        end
        
        labelColor=[color_cells(1,color_idx),color_cells(2,color_idx) ,color_cells(3,color_idx)];
        %Draw bounding box
        frame=insertShape(frame,'rectangle',[bbox(i,1),bbox(i,2),bbox(i,3)-bbox(i,1),bbox(i,4)-bbox(i,2)],'Color',labelColor,'LineWidth',3);
        %Insert label
        frame=insertText(frame,[bbox(i,1) bbox(i,2)],sprintf('%d',labels(i)),'TextColor', labelColor,'BoxColor',[255 255 255],'FontSize',18);
        %Insert association cost
        frame=insertText(frame,[bbox(i,1) bbox(i,4)],sprintf('%1.10e',assoc_cost(i)),'TextColor', labelColor,'BoxColor',[255 255 255],'FontSize',18);
     end
    
    %Insert frame number
    frame=insertText(frame,[0 0],sprintf('Frame number: %d',frameNum),'TextColor', 'black','BoxColor','white','FontSize',25);
end

