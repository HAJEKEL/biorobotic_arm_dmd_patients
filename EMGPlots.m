%Ik integreer het signaal nog een keer op het eind, omdat integreren een
%hoop van de noise nog kan verwijderen. Denk maar aan wat R"omer zei over
%dat een signaal differentieren slecht is (want dan wordt de noise
%versterkt), maar een signaal integreren juist noise kan dempen.

%Als 2 signalen in hetzelfde plotje zitten zijn ze van dezelfde meting,
%anders is het een andere meting (uScope kon niet meer dan 2 variabelen
%handlen). Maar telkens zijn het 2 spieraanspanningen.

%The EMG-processing chain is als volgt.
%Raw/2^(16) --> High passed --> Rectified --> Low passed --> Integrated -->
%Normalized integrated

clear, clc
A = importdata('raw.csv')


t1 = A.data(:,1);
y1 = A.data(:,2);
t1 = t1-t1(1);

b = [0.9655939685724159, -1.562363860482067, 0.9655939685724159];
a =  [1, -1.562363860482067, 0.9311879371448318];
ugh = filter(b,a,y1);

b = [ 0.9911536  -1.98230719  0.9911536 ]; 
a = [ 1.         -1.98222893  0.98238545];
y2 = filter(b,a,ugh);
y3 = abs(y2);

a0 = 0.07606843425477747
a1 = 0.15213686850955493
a2 = 0.07606843425477747
b1 = -1.2889242337808442
b2 = 0.5931979707999537
b = [a0,a1,a2] ;
a = [1,b1,b2];
%b = [0.14532388 0.29064777 0.14532388] ;
%a = [ 1.         -0.67102909  0.25232463];

y4 = filter(b,a,y3);

%INPUT
M = 20
A = []
SUM = []
counter = 1
for i = 1:length(y4)/M
    for j = 1:M
        A(i,j) = y4(counter);
        counter = counter+1;
    end
    
end
SUM = sum(A,2);
SUM = SUM/M;
for i = 1:length(y4)/M
    integrated(i*M:i*M+M) = SUM(i);
end
y5 = integrated(M+1:end);
y6 = y5/max(y5);
figure(1),clf(1)
subplot(2,2,1), hold on, grid on
plot(t1,y1)
plot(t1,y2)
xlim([t1(1),t1(end)])
legend('Raw signal / 2^{16} (bits)','High passed signal')
title('A: Raw vs High passed signal (with 50 Hz Notchfilter)')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off
subplot(2,2,2), hold on, grid on
plot(t1,y3)
plot(t1,y4)
xlim([t1(1),t1(end)])
legend('Rectified signal','Low passed signal')
title('B: Rectified vs Low-passed signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off
axes('position',[.65 .175 .25 .25])
box on, hold on % put box around new pair of axes
indexOfInterest = ( t1>1.7 & t1<2 ); % range of t near perturbation
plot(t1(indexOfInterest),y3(indexOfInterest)) % plot on new axes
plot(t1(indexOfInterest),y4(indexOfInterest))
axis tight
hold off
subplot(2,2,3), hold on, grid on
plot(t1,y5)
xlim([t1(1),t1(end)])
legend('Integrated signal')
title('C: Integrated signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off
subplot(2,2,4), hold on, grid on
plot(t1,y6)
xlim([t1(1),t1(end)])
legend('Normalized integrated signal')
title('D: Normalized integrated signal')
xlabel('time [s]')
ylabel('magnitude [%] (w.r.t. max flex)')
hold off

figure(2),clf(2), hold on, grid on
plot(t1,y3)
plot(t1,y4)
xlim([t1(1),t1(end)])
legend('Rectified signal','Low passed signal')
title('Rectified vs Low-passed signal')
xlabel('time [s]')
ylabel('magnitude [-]')
hold off
axes('position',[.65 .175 .25 .25])
box on, hold on % put box around new pair of axes
indexOfInterest = ( t1>1.7 & t1<2 ); % range of t near perturbation
plot(t1(indexOfInterest),y3(indexOfInterest)) % plot on new axes
plot(t1(indexOfInterest),y4(indexOfInterest))
axis tight
hold off


