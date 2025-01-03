function [T]=get_stations(NET,STA,CHA,TIME,LAT,LON,RAD_KM)

% [T]=get_stations(NET,STA,CHA,[TIME, LAT,LON,RAD_KM])
% examples: 
% get_stations('IV','RE01','EHZ')
% get_stations('IV','RE01','EHZ','2008-12-30')
% get_stations('IV','RE01','EHZ','2008-12-30')
% get_stations('IV','RE01','EHZ','2008-12-30',44.58,10.31,10)
% get_stations('IV','*','EHZ','2008-12-30',44.58,10.31,30)

% davide.piccinini -at- ingv.it

MAP=1;


STA=strrep(STA,' ','');

if nargin==3;
    STR='http://webservices.rm.ingv.it/fdsnws/station/1/query?level=channel&format=text&network=NET&station=STA&channel=CHA&starttime=2020-01-10';
    STR=strrep(STR,'STA',STA);
    STR=strrep(STR,'NET',NET);
    STR=strrep(STR,'CHA',CHA);
    STR=strrep(STR,'2000-01-10',datestr(now,'yyyy-mm-dd'));
elseif nargin==4;
    STR='http://webservices.rm.ingv.it/fdsnws/station/1/query?level=channel&format=text&network=NET&station=STA&channel=CHA&starttime=2020-01-10';
    STR=strrep(STR,'STA',STA);
    STR=strrep(STR,'NET',NET);
    STR=strrep(STR,'CHA',CHA);
    STR=strrep(STR,'2000-01-10',TIME);
else
    STR='http://webservices.rm.ingv.it/fdsnws/station/1/query?level=channel&format=text&network=NET&station=STA&channel=CHA&latitude=LAT&longitude=LON&maxradius=RAD&starttime=2020-01-10';
    STR=strrep(STR,'STA',STA);
    STR=strrep(STR,'NET',NET);
    STR=strrep(STR,'CHA',CHA);
    STR=strrep(STR,'LAT',sprintf('%8.5f',LAT));
    STR=strrep(STR,'LON',sprintf('%8.5f',LON));
    STR=strrep(STR,'RAD',sprintf('%f',km2deg(RAD_KM)));
    STR=strrep(STR,'2000-01-10',TIME);
end

warning off

options = weboptions;
options.Timeout = 60;

try
T=readtable(STR,'FileType','text','WebOptions',options);
    
%keyboard
if MAP==1
    LS=unique(T.Station);
    for k=1:numel(LS)
        STAN(k)=LS(k);
        
        id=find(contains(T.Station,STAN(k)));id=id(1);
        STLA(k)=T.Latitude(id);
        STLO(k)=T.Longitude(id);
        NTW(k)=T.x_Network(id);
    end

    figure; 

    geoscatter(STLA,STLO,50,'^r','filled');
    hold on
    if nargin > 4
    geoscatter(LAT,LON,600,'pb','filled','MarkerFaceAlpha',.5)
    end
    for j=1:numel(STLA)
    h=text(STLA(j),STLO(j),sprintf('%s.%s',char(NTW(j)), char(STAN(j))),'FontWeight','bold');
    set (h, 'Clipping', 'on');
    end
    geotickformat('-dd')
    geobasemap topographic
end
catch
    fprintf('NO STATION\n')
end
        