function [Y, M, D, H, MI, SE, LAT, LON, DEP, ML, TIMES, EvID]=get_quake(START,END,CENTER,RADIUS,STATS)

% [Y M D H MI S LAT LON DEP ML TIMES EvID]=get_quake(START,END,CENTER,RADIUS,STATS);
% START=YYYY-MM-DDTHH-MI-SS
% END  =YYYY-MM-DDTHH-MI-SS
% CENTER=[LAT LON]
% RADIUS=KM
% STATS 0/1 produces plot

% davide.piccinini -at- ingv.it

MFOUR=1.0;

if RADIUS > 99
    print('Max radius allowed 99 km; STOP');
    return
end


S='http://webservices.rm.ingv.it/fdsnws/event/1/query?starttime=2014-12-19T00:00:00&endtime=2014-12-21T18:00:00&format=text&lat=43.577196&lon=11.315713&maxradiuskm=20';

S=strrep(S,'2014-12-19T00:00:00',START);
S=strrep(S,'2014-12-21T18:00:00',END);
S=strrep(S,'43.577196',num2str(CENTER(1)));
S=strrep(S,'11.315713',num2str(CENTER(2)));
S=strrep(S,'km=20',sprintf('km=%2.0f',RADIUS));


%% NEW CODE
options = weboptions("Timeout", 30);
A=webread(S,options);
XX=strread(A,'%s','delimiter','|');

XX=XX(15:end); %% remove header
L=numel(XX);
NEV=L/14;


for k=1:NEV;
    BLKINI=(k*14)-13;
    BLKFIN=(k*14);
    BLK=XX(BLKINI:BLKFIN);
    EvID(k)=strread(char( BLK(1)),'%s');
    Time(k)=strread(char( BLK(2)),'%s');
    LAT (k)=strread(char( BLK(3)),'%f');
    LON (k)=strread(char( BLK(4)),'%f');
    DEP (k)=strread(char( BLK(5)),'%f');
    ML  (k)=strread(char(BLK(11)),'%f');
end

%% OLD CODE
% S=['/usr/local/bin/wget -O dati ' '"' 'http://webservices.rm.ingv.it/fdsnws/event/1/query?starttime=2014-12-19T00:00:00&endtime=2014-12-21T18:00:00&format=text&lat=43.577196&lon=11.315713&maxradiuskm=20' '"' ];
% disp('Retrieving online data using wget...');
% [~,result] = unix(S);
% 
% if ECHO==1
% 
%     S
%     disp(result)
%     disp('...done!');
% 
%     disp('Reading file...')
% end
% 
% 
% %#EventID|Time|Latitude|Longitude|Depth/Km|Author|Catalog|Contributor|ContributorID|MagType|Magnitude|MagAuthor|EventLocationName|web_id_locator(deprecated)
% %4734591|2014-12-21T09:55:38.240000|43.6183|11.2507|5.3|SURVEY-INGV||||ML|1.1|SURVEY-INGV|Firenze|4004734591
% 
% [EvID,Time,LAT,LON,DEP,~,~,~,~,~,ML,~,~,~]=textread('dati',...
%     '%s %s %f %f %f %s %s %s %s %s %f %s %s %s','delimiter','|','headerlines',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Tmat=datenum(Time,'yyyy-mm-ddTHH:MM:SS.FFF');
[TIMES, I]=sort(Tmat);

TIME=datevec(TIMES);
Y=TIME(:,1);
M=TIME(:,2);
D=TIME(:,3);
H=TIME(:,4);
MI=TIME(:,5);
SE=round(TIME(:,6));

% REARRANGING ORDER ACCORDING TO ASCENDING TIME
LAT=LAT(I);
LON=LON(I);
DEP=DEP(I);
ML=ML(I);
EvID=EvID(I);

disp('...done!')
fprintf('# of events: %4.0f\n',length(SE));
fprintf('First Time : %s \n',datestr(min(datevec(Tmat))));
fprintf('Last Time  : %s \n',datestr(max(datevec(Tmat))));
fprintf('min-max ML : %4.1f - %4.1f\n',min(ML),max(ML));

if STATS==1
    fi=find(ML >= MFOUR)  
    [ii,jj]=max(ML);

    figure; 
    subplot(221)
    hist(ML,20),xlabel('Magnitude [M_L]'),ylabel('Counts')
    subplot(222)
    hist(DEP,20),xlabel('DEPTH [km]'); ylabel('Counts')
    subplot(2,2,[3 4])
    stem(TIMES,ML);xlabel('Time');ylabel('Mag'); hold on
    stem(TIMES(fi),ML(fi),'pr','MarkerSize',10,'MarkerFaceColor','r');xlabel('Time');ylabel('Mag'); hold on
    datetick('x',20)
    print -dpng -r300 stats.png
    [ii,jj]=max(ML);
    %jj=find(ML >=3.5)
    
    figure;

    geoscatter(LAT,LON,(ML.^2)*10,-DEP,'filled','MarkerEdgeColor',[.7 .7 .7],'MarkerFaceAlpha',.4);hold on    
    %geoscatter(LAT(jj),LON(jj),(ML(jj).^2)*50,'r','p','filled','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceAlpha',.5);        
    geoscatter(LAT(fi),LON(fi),(ML(fi).^2)*20,'k','p','filled','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceAlpha',.5);        
    geobasemap topographic
    a = colorbar;
    a.Label.String = 'Depth [km]';
    a.Label.FontSize=12;
    a.Limits=[-max(DEP) 0];
    title('Size=Mag Color=depth')
    print -dpng -r300 map_dep.png
    
    figure;
    geoscatter(LAT,LON,(ML.^2)*10,TIMES,'filled','MarkerEdgeColor',[.7 .7 .7],'MarkerFaceAlpha',.4);hold on    
    %geoscatter(LAT(jj),LON(jj),(ML(jj).^2)*50,'r','p','filled','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceAlpha',.5);        
    geoscatter(LAT(fi),LON(fi),(ML(fi).^2)*20,'k','p','filled','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceAlpha',.5);        
    geobasemap topographic
    % colorbar
    a = colorbar;
    a.Label.String = 'Time';
    a.Label.FontSize=12;
    a.Limits=[TIMES(1) TIMES(end)];
    cbdate('yy-mm')
    title('Size=Mag Color=time')
    colormap cool

    print -dpng -r300 map_time.png

    
    % keyboard
    figure;
    scatter(TIMES,[1:length(TIMES)],(ML.^2)*10,-DEP,'filled','MarkerEdgeColor',[.7 .7 .7],'MarkerFaceAlpha',.4); hold on
    scatter(TIMES(fi),fi,500,'k','Marker','p','MarkerEdgeColor','k','LineWidth',1,'MarkerFaceAlpha',.4); hold on
    xlim([TIMES(1)-1 TIMES(end)+1])
    datetick('x','yy-mm-dd')
    box on
    plot(TIMES(end),10,'pk','MarkerSize',12,'MarkerFaceColor','k')
    text(TIMES(end-5),6,sprintf('M>=%3.1f',MFOUR))
    a = colorbar;
    a.Label.String = 'Depth [km]';
    a.Label.FontSize=12;
    a.Limits=[-max(DEP) 0];
    xlabel('Time');
    ylabel('Cumulative Number')
    title('Events Located by INGV Size=Mag Color=Depth')
    print -dpng -r300 release_dep.png
% keyboard
    
    MCOMP=Mc9095(ML);
    if isempty(MCOMP)==1
        [A,MCOMP,Bml,Err]=bmle(ML);
        fprintf('%s\n','Mc=Max-Curvature')
    else
        [A,MCOMP,Bml,Err]=bmle(ML,MCOMP(1));
        fprintf('%s\n','Mc= 90%')
    end                       
    print -dpng -r300 bval.png
end

