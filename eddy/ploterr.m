clear all
close all
clc

load('nekdt.out')
n=1;
for i=1:size(nekdt,1)/2;
   xerr(i,:) = nekdt(n,:);
   yerr(i,:) = nekdt(n+1,:);
   n=n+2;
end

figure;
loglog(xerr(:,3),xerr(:,4),'r','Linewidth',2);hold on
loglog(xerr(:,3),xerr(:,3).^3,'b','Linewidth',2);
xlabel('dt');
ylabel('X error')
legend('Nek error','Dt^3','Location','NorthWest')

load('nekdtkento.out')
n=1;
for i=1:size(nekdtkento,1)/2;
   xerrk(i,:) = nekdtkento(n,:);
   yerrk(i,:) = nekdtkento(n+1,:);
   n=n+2;
end
figure
loglog(xerrk(:,3),xerrk(:,4),'k','Linewidth',2);hold on
loglog(xerrk(:,3),10*xerrk(:,3).^1.5,'b','Linewidth',2);

legend('Kento - Plan 5','Dt^2','Location','NorthWest')