%%This function:
%1. Computes the Bhattacharyya coefficient for every combination of
%pedestrians from old and new frame
%2. Reorders them into an appropriate matrix for the hungarian assignment
%algorithm

%BC_MAT:
%Columns: Old hist
%Rows: New hist
function [ BC_MAT ] = assoc_cost(old_hist,new_hist)

    if ((length(old_hist)==0)||(length(new_hist)==0)) %Either one of the frames has no ppl
        [~,BC_MAT]=size(new_hist); %No assignment to do return number of ppl in new frame * -1
        BC_MAT=BC_MAT*-1;
        if (BC_MAT==0)
           BC_MAT=NaN; 
        end
    else

        [~,x_old]=size(old_hist);
        [~,x_new]=size(new_hist);

        %Initialise BC_MAT
        BC_MAT=zeros(x_new,x_old);

        %Compute Bhattacharyya coefficient for every pair of old and new
        for i=1:x_new
            for j=1:x_old
                BC_coeff=BC(old_hist(:,j),new_hist(:,i)); %N.B.: Can be greater than 1 due to rounding errors
                if(BC_coeff>1.0) %Saturate to 1
                    BC_coeff=1.0;
                end
                BC_MAT(i,j)=1-BC_coeff;
            end
        end
    
    end
end

