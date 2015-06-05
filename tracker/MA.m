%This function calculates the moving average of a vector
%1. If the length of the vector is less than the MA span, then just take
%the average
%2. For the end of the vector, the average is just replicated
%3. Output and input are both column vectors
%4. For flag == 1, we smooth out the trajectory centroids so that it is not
%so jerky

function output=MA(input,span,flag)
    size = numel(input);
    if (iscolumn(input))
        if (size<=span)
            if (flag==0) %Smooth bbox dimension
                %All bbox dimensions are equalised
                output = sum(input)./size;
                output = output.*ones(size,1);
            else %Smooth centroid trajectories
                output = input;
            end
        else
            if (flag ==0) %Smooth bbox dimension
                MA_vector=(1/span).*ones(span,1);
                output=conv(input,MA_vector);
                output=output(span:end); %Remove the first few elements
                output=output(1:end-span+1); %Remove the trailing edges
                output=[output;output(end).*ones(span-1,1)];
            else %Smooth centroid trajectories
                MA_vector=(1/span).*ones(span,1);
                output=conv(input,MA_vector);
                output=output(span:end); %Remove the first few elements
                output=output(1:end-span+1); %Remove the trailing edges
                output=[output;input(end-span+2:end)]; %Replace trailing edge with non-MAed centroids               
            end
        end
    else
        disp('Error: input vector into MA function must be a column vector!');
        output=0;
    end

end