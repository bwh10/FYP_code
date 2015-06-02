function [ BC_MAT ] = get_assoc(old_hist,new_hist)
%%This function calculates the association cost for the Hungarian algorithm:
%1. Computes the Bhattacharyya coefficient for every combination of
%pedestrians from old and new frame for every pedestrain parts
%2. Reorders them into an appropriate matrix for the hungarian assignment
%algorithm

%BC_MAT:
%Columns: Old hist
%Rows: New hist

    if ((isempty(old_hist))||(isempty(new_hist))) %Either one of the frames has no ppl
        [~,Num_ppl,Num_parts]=size(new_hist); %No assignment to do return number of ppl in new frame * -1
        BC_MAT(1,1)=Num_ppl*-1;
        BC_MAT(1,2)=Num_parts;
        if (Num_ppl==0)
           BC_MAT=NaN; 
        end
    else

        [~,num_ppl_old,num_parts_old]=size(old_hist);
        [~,num_ppl_new,num_parts_new]=size(new_hist);
        
        assert(num_parts_old==num_parts_new); %Number of body parts must be the same across frames

        %Initialise BC_MAT
        BC_MAT=zeros(num_ppl_new,num_ppl_old,num_parts_new);

        %Compute Bhattacharyya coefficient for every pair of old and new
        %and for every body part including overall body part
        for i=1:num_ppl_new
            for j=1:num_ppl_old
                for k=1:num_parts_new
                    if ((sum(old_hist(:,j,k))<0) || (sum(new_hist(:,i,k))<0))
                        BC_coeff=1.0; %one of the detected parts lies outside frame boundary, hence, give it max association cost
                    else
                        BC_coeff=BC(old_hist(:,j,k),new_hist(:,i,k)); %N.B.: Can be greater than 1 due to rounding errors
                    end
                    
                    if(BC_coeff>1.0) %Saturate to 1
                        BC_coeff=1.0;
                    end
                    BC_MAT(i,j,k)=1-BC_coeff; %Get dissimilarity measure
                end
            end
        end
    
    end
end
