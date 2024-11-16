function T=get_xml(NET,STA,CHA,TIME,RES);

% T=get_xml(NET,STA,CHA,TIME);
% example: T=get_xml('IV','GRFL','*','2000-01-01',1);


if nargin ==2 
    CHA='*';
    TIME='2000-01-01';
    RES=1;
end

if nargin < 5
    RES=1;
end

STR='http://webservices.rm.ingv.it/fdsnws/station/1/query?level=channel&format=json&network=IV&station=XXXX&channel=CHA&starttime=2024-11-11';

STR=strrep(STR,'IV',NET);
STR=strrep(STR,'XXXX',STA);
STR=strrep(STR,'CHA',CHA);
STR=strrep(STR,'2024-11-11',TIME);

% keyboard
OUT=webread(STR);
if isempty(OUT)
    fprintf('No station found')
    return
end

 % keyboard

T.NetworkCode=OUT.FDSNStationXML.Network.code;
T.StationCode=OUT.FDSNStationXML.Network.Station.code;
T.AvailChannel=OUT.FDSNStationXML.Network.Station.Channel;
T.Latitude=OUT.FDSNStationXML.Network.Station.Latitude;
T.Longitude=OUT.FDSNStationXML.Network.Station.Longitude;
try
T.Depth=OUT.FDSNStationXML.Network.Station.Channel.Depth;
catch
    T.Depth=0;
end
T.StartDate=OUT.FDSNStationXML.Network.Station.startDate;
try
    T.endDate  =OUT.FDSNStationXML.Network.Station.endDate;
catch
    T.endDate  ='Running'
end
T.site=OUT.FDSNStationXML.Network.Station.Site;

% keyboard
%% 
if RES==1
    fprintf('%s\n',[T.NetworkCode '.' T.StationCode]);
    try
        fprintf('%s\n',T.site)
    catch
        fprintf('%s\n',T.StationCode)
    end

    for k=1:numel(T.AvailChannel)
        try
            ED=T.AvailChannel{k}.endDate;
        catch
            ED='Running';
        end
        try
        fprintf('%s %s %s %s %s\n',...
            T.AvailChannel{k}.code,...
            T.AvailChannel{k}.Sensor.Description,...
            T.AvailChannel{k}.DataLogger.Description,...
            T.AvailChannel{k}.startDate,...
            ED);  
        catch
        fprintf('%s %s %s %s %s\n',...
            T.AvailChannel(k).code,...
            T.AvailChannel(k).Sensor.Description,...
            T.AvailChannel(k).DataLogger.Description,...
            T.AvailChannel(k).startDate,...
            ED);  
        end   
    end


end






