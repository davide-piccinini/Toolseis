function []=xml_from_nrl()

% usage: xml_from_nrl
% scarica xml dal webservice NRL
% davide.piccinini (at) ingv.it
%

% ver.1.0 2025/09/05

%% URL base
rootUrl = 'https://service.iris.edu/irisws/nrl/1';   % radice del servizio
baseUrl = [rootUrl '/catalog'];                      % endpoint per cataloghi

%% Scarico lista sensori e digitalizzatori
txt = webread([baseUrl '?level=manufacturer&format=text&nodata=404']);
lines = strtrim(splitlines(txt));

% Trova sensori e digitizer 
sensors    = unique(erase(lines(startsWith(lines,'"sensor"')), '"sensor"'));
digitizers = unique(erase(lines(startsWith(lines,'"datalogger"')), '"datalogger"'));

%% SENSORI
disp('--- SENSORI DISPONIBILI ---')
disp(sensors)
isensor = input('Seleziona il sensore: ','s'); clc

% Lista modelli disponibili
urlModel = sprintf('%s?element=sensor&manufacturer=%s&level=model&format=text&nodata=404', ...
                   baseUrl, isensor);
A = readtable(urlModel);
disp(A)
imodel = input('Modello? ','s');

% Configurazioni sensore
urlConfig = sprintf('%s?element=sensor&manufacturer=%s&model=%s&level=configuration&format=text&nodata=404', ...
                    baseUrl, isensor, imodel);
A = readtable(urlConfig);

if height(A) > 1
    disp(A)
    Sensconfig = input('Inserisci il campo Var10:\n (es: sensor_REFTEK_Colt_LP60_SG2000_STgroundVel) ','s');
else
    fprintf('%s\n%s\n%s\n%s\n', A.Manufacturer{1}, A.Model{1}, A.Description{1}, A.Instconfig{1});
    Sensconfig = A.Instconfig{1};
end

%% DATALOGGER
disp('--- DIGITIZER DISPONIBILI ---')
disp(digitizers)
idigit = input('Seleziona il digitalizzatore: ','s'); clc

% Lista modelli digitizer
urlModel = sprintf('%s?element=datalogger&manufacturer=%s&level=model&format=text&nodata=404', ...
                   baseUrl, idigit);
A = readtable(urlModel);
disp(A)
imodel = input('Modello? ','s');

% Configurazioni digitizer
urlConfig = sprintf('%s?manufacturer=%s&model=%s&level=configuration&format=text&nodata=404', ...
                    baseUrl, idigit, imodel);
A = readtable(urlConfig);
disp(A)

dataloggerconfig = input('Inserisci il campo Var7\n (es: datalogger_REFTEK_130-01_PG100_FR125): ','s');

%% COMBINAZIONE
fprintf('\nSensore   : %s\nDatalogger: %s\n\n', Sensconfig, dataloggerconfig);

combineUrl = sprintf('%s/combine?instconfig=%s:%s&format=stationxml&nodata=404', ...
                     rootUrl, Sensconfig, dataloggerconfig);

%% Info stazione
if strcmpi(input('Vuoi inserire i dati relativi alla stazione? (y/n): ','s'),'y')
    NET = input('NET= ','s'); 
    STA = input('STA= ','s'); 
    LOC = input('LOC= ','s'); 
    CHA = input('CHA= ','s'); 
    INI = input('StartTime: ','s'); 
    FIN = input('EndTime:   ','s');

    combineUrl = sprintf(['%s/combine?instconfig=%s:%s&format=stationxml', ...
        '&net=%s&sta=%s&loc=%s&cha=%s&starttime=%s&endtime=%s&nodata=404'], ...
        rootUrl, Sensconfig, dataloggerconfig, NET, STA, LOC, CHA, INI, FIN);

    if strcmpi(input('Scarico xml per tutti e tre i canali? (y/n): ','s'),'y')
        channels = {'Z','N','E'};
        for ch = channels
            outUrl = strrep(combineUrl, CHA, [CHA(1:2) ch{1}]);
            websave(sprintf('%s.%s.%s.%s.xml', NET, STA, LOC, ch{1}), outUrl);
        end
    else
        websave(sprintf('%s.%s.%s.%s.xml', NET, STA, LOC, CHA), combineUrl);
    end
else
    websave(sprintf('%s.%s.xml', Sensconfig, dataloggerconfig), combineUrl);
end
