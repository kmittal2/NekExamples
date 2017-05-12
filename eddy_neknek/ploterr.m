clear all
close all
clc

load('nekdtp3.out')
nekdt = nekdtp3;
n=1;
for i=1:size(nekdt,1)/2;
   xerr(i,:) = nekdt(n,:);
   yerr(i,:) = nekdt(n+1,:);
   n=n+2;
end

figure;
loglog(xerr(:,3),xerr(:,4),'r','Linewidth',2);hold on
loglog(xerr(:,3),yerr(:,4),'r*-','Linewidth',2);
loglog(xerr(:,3),5*xerr(:,3).^1,'b','Linewidth',2);
xlabel('dt');
ylabel('error')
legend('Plan 3 - X - 0','Plan 3 - Y - 0','Dt^1','Location','NorthWest')
saveas(gca,'plan3.png')

xerr = [];yerr = [];
load('nekdtp4.out')
nekdt = nekdtp4;
n=1;
for i=1:size(nekdt,1)/2;
   xerr(i,:) = nekdt(n,:);
   yerr(i,:) = nekdt(n+1,:);
   n=n+2;
end
loglog(xerr(:,3),xerr(:,4),'r','Linewidth',2);hold on
loglog(yerr(:,3),yerr(:,4),'r*-','Linewidth',2);
loglog(xerr(:,3),40*xerr(:,3).^2,'b','Linewidth',2);
legend('Plan 3 - X - 0 iterations','Plan 3 - Y - 0 iterations','Dt^1', ...
       'Plan 3 - X - 3 iterations','Plan 3 - Y - 3 iterations','Dt^2', ...
    'Location','NorthWest')
