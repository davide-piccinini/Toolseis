function [power,frequency]=get_pdf(NET,STA,CHA,YEAR,TYP,PLT);

% [power,frequency]=get_pdf(NET,STA,CHA,YEAR,TYP,PLT);
% TYP should be: 5,10,25,75,90,95,median,mode,mean,min,max
% according to: 
% http://webservices.ingv.it/swagger-ui/dist/?url=http%3A%2F%2Fwebservices.ingv.it%2Fingvws%2Fsqlx%2F1%2Fswagger.json#/exPDFstat/get_exPDFstat_1_
% IF TYP== '*' extract 90% 10% median and mean
% power is in dB
% frequency in Hz



STR='https://webservices.ingv.it/ingvws/sqlx/exPDFstat/1/?year=YYYY&mode=pdf&pdflist_number=1&net=NN&sta=SSSS&cha=CCC&loc=--&type=F&stat_type=ZZZZ&format=text';
STR=strrep(STR,'YYYY',num2str(YEAR));
STR=strrep(STR,'NN',NET);
STR=strrep(STR,'SSSS',STA);
STR=strrep(STR,'CCC',CHA);
%keyboard
if strcmp(TYP,'*')==0
    STR=strrep(STR,'ZZZZ',TYP);
    [frequency,power]=get_response(STR);        
else
    STR10=strrep(STR,'ZZZZ','10');
    [frequency(:,1),power(:,1)]=get_response(STR10);
    if isempty(power)
        fprintf('Check channel name\n')
        return
    end

    STR90=strrep(STR,'ZZZZ','90');
    [frequency(:,2),power(:,2)]=get_response(STR90);
    STRMEDIAN=strrep(STR,'ZZZZ','median');
    [frequency(:,3),power(:,3)]=get_response(STRMEDIAN);
    STRMEAN=strrep(STR,'ZZZZ','mean');
    [frequency(:,4),power(:,4)]=get_response(STRMEAN);
    STRMODE=strrep(STR,'ZZZZ','mode');
    [frequency(:,5),power(:,5)]=get_response(STRMODE);
end
    
    
%STR


if PLT==1 & isempty(frequency)==0 & strcmp(TYP,'*')==0
    figure; 
    semilogx(frequency,power,'LineWidth',2)
    hold on
    [LNM,HNM]=Peterson;
    semilogx(LNM(:,1),LNM(:,2),'k','LineWidth',2);
    semilogx(HNM(:,1),HNM(:,2),'k','LineWidth',2);

    %avg rete IV
    [f,a,s]=avg_iv_net;
    semilogx(f,a-s,'-.','Color',[.7 .7 .7],'LineWidth',1);
    semilogx(f,a+s,'-.','Color',[.7 .7 .7],'LineWidth',1);


    ylim([-200 -50]);
    xlim([0.01 50]);
    grid
    ylabel('Power [dB]')
    xlabel('Frequency [Hz]')
    title([NET ' - ' STA ' - ' CHA ' - ' num2str(YEAR) ' - ' TYP ]);
end
if PLT==1 & isempty(frequency)==0 & strcmp(TYP,'*')==1
    figure; 
    semilogx(frequency,power,'LineWidth',2)
    hold on
    [LNM,HNM]=Peterson;
    semilogx(LNM(:,1),LNM(:,2),'k','LineWidth',2);
    semilogx(HNM(:,1),HNM(:,2),'k','LineWidth',2);
    ylim([-200 -50]);
    xlim([0.01 50]);
    grid
    ylabel('Power [dB]')
    xlabel('Frequency [Hz]')
    title([NET ' - ' STA ' - ' CHA ' - ' num2str(YEAR) ' - ' TYP ]);
    legend('10^t^h perc','90^t^h perc','median','mean','mode','LNM','HNM')
end

% keyboard

function [freq,pow]=get_response(STR);
import matlab.net.*
import matlab.net.http.*

uri = URI(STR);
r = RequestMessage;
resp = send(r,uri);
status = resp.StatusCode;

DATA=resp.Body.Data;
[freq,pow]=strread(DATA,'%f %d','delimiter','|','headerlines',9);
if numel(freq) > 1
    frequency=freq;
    power=pow;
else
    frequency=[];
    power    =[];
    fprintf('NO DATA \n')
    return
end






function  [LNM,HNM]=Peterson;

% Velocity[dB] vs Frequence [Hz] LNM & HNM according to OBSPY PPSD

LNM=[0.010384687751343512 -185.20833333333331;
0.014313231808831992 -187.29166666666666;
0.022093386751530785 -187.29166666666666;
0.03222528161450805 -184.6875;
0.04612479258533457 -177.39583333333331;
0.06478514122711529 -162.29166666666666;
0.08437805460463764 -165.93749999999997;
0.10190528814219361 -163.33333333333331;
0.1696321617735579 -148.22916666666666;
0.20103824693326672 -140.9375;
0.23825892629932371 -140.9375;
0.4197114523817274 -148.75;
0.8125237525193885 -163.33333333333331;
1.254182266379492 -169.06249999999997;
2.474244553588842 -166.45833333333331;
6.1218861109640486 -166.45833333333331;
10.384687751343506 -168.02083333333331];


HNM=[0.010190528814219361  -131.30208333333331;
0.04974177875376837  -138.33333333333331;
0.06478514122711529  -120.10416666666666;
0.1278078052382315  -113.33333333333333;
0.1602942828346739  -100.83333333333333;
0.22093386751530797  -96.66666666666666;
0.2668268370847133  -97.96875;
1.254182266379492  -119.58333333333331;
3.1622776601683795  -110.20833333333333;
4.612479258533459  -97.18749999999999;
10.190528814219372  -91.45833333333331];



function [f,avg,std]=avg_iv_net;
f=[    0.0059
    0.0064
    0.0070
    0.0076
    0.0083
    0.0091
    0.0099
    0.0108
    0.0118
    0.0128
    0.0140
    0.0153
    0.0166
    0.0181
    0.0198
    0.0216
    0.0235
    0.0257
    0.0280
    0.0305
    0.0333
    0.0363
    0.0396
    0.0432
    0.0471
    0.0513
    0.0560
    0.0610
    0.0666
    0.0726
    0.0792
    0.0863
    0.0941
    0.1026
    0.1119
    0.1221
    0.1331
    0.1452
    0.1583
    0.1726
    0.1883
    0.2053
    0.2239
    0.2441
    0.2662
    0.2903
    0.3166
    0.3453
    0.3765
    0.4106
    0.4478
    0.4883
    0.5325
    0.5807
    0.6332
    0.6905
    0.7530
    0.8212
    0.8955
    0.9766
    1.0649
    1.1613
    1.2664
    1.3811
    1.5061
    1.6424
    1.7910
    1.9531
    2.1299
    2.3227
    2.5329
    2.7621
    3.0121
    3.2848
    3.5820
    3.9063
    4.2598
    4.6453
    5.0658
    5.5243
    6.0243
    6.5695
    7.1641
    7.8125
    8.5196
    9.2907
   10.1316
   11.0485
   12.0485
   13.1390
   14.3282
   15.6250
   17.0392
   18.5814
   20.2631
   22.0971
   24.0970
   26.2780
   28.6564
   31.2500
   34.0784
   37.1627
   40.5262
   44.1942
   48.1941];
avg=[  -148.1453
 -148.1655
 -149.2399
 -149.5642
 -150.1757
 -150.4324
 -151.1351
 -151.6419
 -152.1588
 -152.6554
 -153.0676
 -153.4257
 -153.8311
 -154.1081
 -154.5743
 -154.7635
 -155.0608
 -155.2331
 -155.3885
 -155.4764
 -155.4122
 -155.1689
 -154.9291
 -154.3277
 -153.1486
 -151.5304
 -149.9865
 -148.7770
 -148.4155
 -148.5980
 -148.8818
 -149.0203
 -148.3378
 -146.3480
 -142.5338
 -138.5642
 -135.4392
 -133.3074
 -131.9764
 -130.9459
 -129.5574
 -127.2078
 -126.6494
 -126.8935
 -127.2545
 -127.5584
 -127.5558
 -127.3766
 -127.1688
 -127.0052
 -127.0208
 -127.2987
 -127.8078
 -128.2987
 -128.8156
 -129.3325
 -129.9039
 -130.4779
 -131.1299
 -131.6468
 -132.1636
 -132.5169
 -132.4779
 -132.2000
 -132.3922
 -132.8701
 -132.8338
 -132.6364
 -132.4052
 -131.9195
 -131.2753
 -130.7818
 -130.5714
 -130.4026
 -130.0260
 -129.5195
 -129.2468
 -129.0831
 -128.8182
 -128.4130
 -128.0208
 -127.4701
 -126.8519
 -126.1169
 -125.2883
 -124.3039
 -123.3948
 -122.4026
 -121.5662
 -121.1532
 -120.7948
 -120.3844
 -120.1818
 -120.1299
 -119.9558
 -119.5013
 -118.6883
 -118.8182
 -118.4571
 -118.0753
 -117.8935
 -117.3299
 -117.0312
 -121.7636
 -143.3221];

std=[      12.6968
   12.6875
   12.3804
   12.3130
   12.1979
   12.1400
   12.0739
   12.0302
   12.0022
   11.9551
   11.9474
   11.9159
   11.8838
   11.8897
   11.8597
   11.8841
   11.7864
   11.7192
   11.6136
   11.5159
   11.3690
   11.1680
   10.9884
   10.6604
   10.2662
    9.7702
    9.4309
    9.2052
    9.1414
    9.1598
    9.2026
    9.2399
    9.2209
    9.0631
    8.6952
    8.3509
    8.1828
    8.0526
    7.9602
    7.8531
    7.6759
    7.9719
    7.8478
    7.8562
    7.8920
    7.9803
    8.1674
    8.4457
    8.7889
    9.1890
    9.5131
    9.7704
   10.0713
   10.4748
   10.9765
   11.5126
   12.0716
   12.5613
   12.9809
   13.2892
   13.6457
   13.8842
   13.9359
   13.8729
   13.9840
   14.3527
   14.4685
   14.6592
   14.7975
   14.8143
   14.8386
   14.8608
   14.8442
   14.7617
   14.7919
   14.7118
   14.6572
   14.5455
   14.5440
   14.5936
   14.5724
   14.4770
   14.4912
   14.5210
   14.6603
   14.6506
   14.5852
   14.6702
   14.4984
   14.2613
   14.1676
   14.1019
   13.8343
   13.8097
   13.4226
   13.2207
   13.1312
   12.8626
   12.7033
   12.8461
   12.8345
   12.6274
   12.8241
   13.0224
   13.1282];
