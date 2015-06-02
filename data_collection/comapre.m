%This scripts compares the result of the RunTime and IDsw between normal
%hungarian and hungarian by parts

clear all;
clc;
close all;

load hungarian_parts_result.mat
load hungarian_result.mat

Num_frames=17;

RunTime     = RunTime./Num_frames;
RunTime_p   = RunTime_p./Num_frames;
step_size   = 1:40;
step_size_p = 2:40;
improvement = ((Accum_ID_SW_store(2:end) - IDsw_p)./Accum_ID_SW_store(2:end)).*100;

figure
hold on
grid on
grid minor
plot(step_size,RunTime,'*-');
plot(step_size_p,RunTime_p,'*-');
title('Run Time vs Histogram step size');
xlabel('Histogram step size');
ylabel('Average Run Time per frame(s)');
legend('Hungarian','Hungarian with parts')
hold off

figure
hold on
grid on
grid minor
plot(step_size,Accum_ID_SW_store,'*-');
plot(step_size_p,IDsw_p,'*-');
plot(step_size_p,improvement,'*-','Color','k');
title('Number of ID switches vs Histogram step size');
xlabel('Histogram step size');
ylabel('Number of ID switches OR Percentage improvement');;
legend('Hungarian','Hungarian with parts','Percentage improvement')
hold off
