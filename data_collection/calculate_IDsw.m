function [ Num_ID_SW ] = calculate_IDsw( obj_hyp_pair, obj_hyp_pair2 )
%This function calculates the number of ID switches based on the current
%obj-hyp pair and the next frames obj-hyp pair

OH_mismatch=[]; %Container to store the object-hypothesis pair mismatch
Num_ID_SW=0; %Number of ID switches at current frame initialisation
    %Caluclate numer of ID switches (o,h) pairing does not match for a
    %given object
    for i=1:numel(obj_hyp_pair2(:,1))
        if (numel(find(obj_hyp_pair(:,1)==obj_hyp_pair2(i,1)))>0) %Check whether can find ground truth label in previous frame
            idx_match=obj_hyp_pair(:,1)==obj_hyp_pair2(i,1); %Match ground truth between 2 frames 
            if (obj_hyp_pair(idx_match,2)~=obj_hyp_pair2(i,2)) %Ground truth - hypothesis pairing different between 2 frames, indicating ID switch has occured
               Num_ID_SW=Num_ID_SW+1; 
               OH_mismatch=[OH_mismatch;obj_hyp_pair(idx_match,:)];
            end
        end
    end
    
    %Caluclate numer of ID switches (o,h) pairing does not match for a
    %given Hypothesis
    %Caluclate numer of ID switches (o,h) pairing does not match for a
    %given hypothesis
    for i=1:numel(obj_hyp_pair2(:,2))
        if (numel(find(obj_hyp_pair(:,2)==obj_hyp_pair2(i,2)))>0) %Check whether can find hypothesis label in previous frame
            idx_match=obj_hyp_pair(:,2)==obj_hyp_pair2(i,2); %Match hypothesis label between 2 frames 
            
            %Ground truth - hypothesis pairing different between 2 frames, indicating ID switch has occured
            %OH pairing not found in previous search
            if (obj_hyp_pair(idx_match,1)~=obj_hyp_pair2(i,1))  
               if (isempty(OH_mismatch) || (numel(intersect(OH_mismatch(:,1),obj_hyp_pair(idx_match,1)))==0))
                Num_ID_SW=Num_ID_SW+1; 
               end
            end
        end
    end

end

