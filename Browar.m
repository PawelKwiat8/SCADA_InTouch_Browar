function varargout = Browar(varargin)
% Browar M-file for Browar.fig
%      Browar, by itself, creates a new Browar or raises the existing
%      singleton*.
%
%      H = Browar returns the handle to a new Browar or the handle to
%      the existing singleton*.
%
%      Browar('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Browar.M with the given input arguments.
%
%      Browar('Property','Value',...) creates a new Browar or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Browar_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Browar_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Browar

% Last Modified by GUIDE v2.5 04-Mar-2012 21:13:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Browar_OpeningFcn, ...
                   'gui_OutputFcn',  @Browar_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before Browar is made visible.
function Browar_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Browar (see VARARGIN)

% Choose default command line output for Browar
handles.output = hObject;

%clc; %wyczysc ekran polecen Matlab'a
disp('Browar - start aplikacji');

% Update handles structure
guidata(hObject, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = Browar_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Resize Browar
set(gcf, 'Units' , 'Pixel');
set(gcf, 'Position', [0, 0, 1274, 1004]);

modelName = 'BrowarModel';
% Do some simple error checking on the input
if ~localValidateInputs(modelName)
    estr = sprintf('The model %s.mdl cannot be found.',modelName);
    errordlg(estr,'Model not found error','modal');
    return
end

% Load the simulink model
ad = localLoadModel(modelName);

% Create the handles structure
ad.handles = guihandles(hObject);

% Save the application data
guidata(hObject,ad);

% Ustaw przyciski Zaklocenia procesowe
ZaklProc = str2double(get_param('BrowarModel/Parametry symulacji/ZaklProc','Value'));
if ZaklProc > 0.5
   set(ad.handles.btnZaklProcOn,'Enable','off');
else
   set(ad.handles.btnZaklProcOff,'Enable','off');    
end

% Ustaw przyciski Zaklocenia pomiarowe
ZaklPom = str2double(get_param('BrowarModel/Parametry symulacji/ZaklPom','Value'));
if ZaklPom > 0.5
   set(ad.handles.btnZaklPomOn,'Enable','off');
else
   set(ad.handles.btnZaklPomOff,'Enable','off');    
end

% Ustaw przyciski Tryb sterowania
TrybSter = str2double(get_param('BrowarModel/Parametry symulacji/TrybSter','Value'));
if TrybSter > 0.5
   set(ad.handles.btnTrybSterZdalne,'Enable','off');
else
   set(ad.handles.btnTrybSterLokalne,'Enable','off');    
end

% Ustaw przyciski Tryb symulacji
TrybSym = str2double(get_param('BrowarModel/Parametry symulacji/TrybSym','Value'));
if TrybSym < 0.5
   set(ad.handles.btnSymulacjaNormalna,'Enable','off');
else
   set(ad.handles.btnSymulacjaSzybka,'Enable','off');    
end

% This UI hard codes the name of the model that is being controlled

%Glowny timer odswiezania ekranu
ad.handles.guifig = gcf;
ad.handles.TmrScreenRefresh = timer('TimerFcn', {@TmrScreenRefreshFcn,ad.handles.guifig},...
                                 'BusyMode','Drop',...
                                 'ExecutionMode','FixedRate',...
                                 'Period',0.5);                     %ekran odswiezany co 500 ms

% Save the application data
guidata(hObject,ad);
end


%Funkcja odswiezania ekranu - wyzwalana wewnetrznym zegarem TmrScreenRefresh
function TmrScreenRefreshFcn(src,event,handles) 
%mycallback(source, eventdata, handles)
ad = guidata(handles);


%Colours definitions
ColourFaultState = [1,0,0];
ColourNoFaultState = [0,0,1];
FaultEnabled = 0;


% ### General ###
%set(ad.handles.txCzasSymulacji,'String',str);
rto = get_param('BrowarModel/Parametry symulacji/Zegar','RuntimeObject');
set(ad.handles.txCzasSymulacji,'String',num2str(rto.OutputPort(1).Data));


% ### Mlyn browarniany ###
%update Mlyn
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F121','Value')));
if FaultEnabled > 0
   set(ad.handles.btnMlyn,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnMlyn,'ForegroundColor',ColourNoFaultState);    
end


%update MlynDozownik
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F131','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F132','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F133','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F134','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F135','Value')));
if FaultEnabled > 0
   set(ad.handles.btnMlynDozownik,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnMlynDozownik,'ForegroundColor',ColourNoFaultState);    
end


%update MlynWalce
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F141','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F142','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F143','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F144','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F145','Value')));
if FaultEnabled > 0
   set(ad.handles.btnMlynWalce,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnMlynWalce,'ForegroundColor',ColourNoFaultState);    
end


%update LV101
rto = get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/Zawor doplywu slodu/GUIMon','RuntimeObject');
set(ad.handles.txLV101,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F111','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F112','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F113','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F114','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLV101,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLV101,'ForegroundColor',ColourNoFaultState);    
end


%update LT102
rto = get_param('BrowarModel/Mlyn browarniany/LT102/GUIMon','RuntimeObject');
set(ad.handles.txLT102,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT102/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT102/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT102,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT102,'ForegroundColor',ColourNoFaultState);    
end


%update LT102H
rto = get_param('BrowarModel/Mlyn browarniany/LT102H/GUIMon','RuntimeObject');
set(ad.handles.txLT102H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT102H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT102H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT102H,'ForegroundColor',ColourNoFaultState);    
end


%update LT102L
rto = get_param('BrowarModel/Mlyn browarniany/LT102L/GUIMon','RuntimeObject');
set(ad.handles.txLT102L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT102L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT102L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT102L,'ForegroundColor',ColourNoFaultState);    
end


%update FV103SP
rto = get_param('BrowarModel/Mlyn browarniany/FV103SP/GUIMon','RuntimeObject');
set(ad.handles.txFV103SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F136','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV103,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV103,'ForegroundColor',ColourNoFaultState);    
end


%update ST103
rto = get_param('BrowarModel/Mlyn browarniany/ST103/GUIMon','RuntimeObject');
set(ad.handles.txST103,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET103
rto = get_param('BrowarModel/Mlyn browarniany/ET103/GUIMon','RuntimeObject');
set(ad.handles.txET103,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV103State
rto = get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/Dozownik mlyna/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV103State,'String','STOP');
    case 2
       set(ad.handles.txFV103State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV103State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV103State,'String','***'); 
end


%update TT103
rto = get_param('BrowarModel/Mlyn browarniany/TT103/GUIMon','RuntimeObject');
set(ad.handles.txTT103,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/TT103/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/TT103/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT103,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT103,'ForegroundColor',ColourNoFaultState);    
end


%update LT104H
rto = get_param('BrowarModel/Mlyn browarniany/LT104H/GUIMon','RuntimeObject');
set(ad.handles.txLT104H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT104H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT104H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT104H,'ForegroundColor',ColourNoFaultState);    
end


%update LT104L
rto = get_param('BrowarModel/Mlyn browarniany/LT104L/GUIMon','RuntimeObject');
set(ad.handles.txLT104L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/LT104L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT104L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT104L,'ForegroundColor',ColourNoFaultState);    
end


%update FV105SP
rto = get_param('BrowarModel/Mlyn browarniany/FV105SP/GUIMon','RuntimeObject');
set(ad.handles.txFV105SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F146','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV105,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV105,'ForegroundColor',ColourNoFaultState);    
end


%update ST105
rto = get_param('BrowarModel/Mlyn browarniany/ST105/GUIMon','RuntimeObject');
set(ad.handles.txST105,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET105
rto = get_param('BrowarModel/Mlyn browarniany/ET105/GUIMon','RuntimeObject');
set(ad.handles.txET105,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV105State
rto = get_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/Walce mlyna/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV105State,'String','STOP');
    case 2
       set(ad.handles.txFV105State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV105State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV105State,'String','***'); 
end


%update TT105
rto = get_param('BrowarModel/Mlyn browarniany/TT105/GUIMon','RuntimeObject');
set(ad.handles.txTT105,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/TT105/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/TT105/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT105,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT105,'ForegroundColor',ColourNoFaultState);    
end


%update FT105
rto = get_param('BrowarModel/Mlyn browarniany/FT105/GUIMon','RuntimeObject');
set(ad.handles.txFT105,'String',num2str(round(10*rto.OutputPort(1).Data)/10));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/FT105/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Mlyn browarniany/FT105/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnFT105,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFT105,'ForegroundColor',ColourNoFaultState);    
end


% ### Kadz zacierna ###
%update KadzZacierna
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F221','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F231','Value')));
if FaultEnabled > 0
   set(ad.handles.btnKadzZacierna,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnKadzZacierna,'ForegroundColor',ColourNoFaultState);    
end


%update LV201
rto = get_param('BrowarModel/Kadz zacierna/Kadz zacierna/Zawor doplywu wody/GUIMon','RuntimeObject');
set(ad.handles.txLV201,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F211','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F212','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F213','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F214','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLV201,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLV201,'ForegroundColor',ColourNoFaultState);    
end


%update FT201
rto = get_param('BrowarModel/Kadz zacierna/FT201/GUIMon','RuntimeObject');
set(ad.handles.txFT201,'String',num2str(round(10*rto.OutputPort(1).Data)/10));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/FT201/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/FT201/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnFT201,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFT201,'ForegroundColor',ColourNoFaultState);    
end


%update LT202
rto = get_param('BrowarModel/Kadz zacierna/LT202/GUIMon','RuntimeObject');
set(ad.handles.txLT202,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/LT202/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/LT202/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT202,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT202,'ForegroundColor',ColourNoFaultState);    
end


%update LT202H
rto = get_param('BrowarModel/Kadz zacierna/LT202H/GUIMon','RuntimeObject');
set(ad.handles.txLT202H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/LT202H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT202H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT202H,'ForegroundColor',ColourNoFaultState);    
end


%update LT202L
rto = get_param('BrowarModel/Kadz zacierna/LT202L/GUIMon','RuntimeObject');
set(ad.handles.txLT202L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/LT202L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT202L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT202L,'ForegroundColor',ColourNoFaultState);    
end


%update TT203L
rto = get_param('BrowarModel/Kadz zacierna/TT203L/GUIMon','RuntimeObject');
set(ad.handles.txTT203L,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203L/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203L/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT203L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT203L,'ForegroundColor',ColourNoFaultState);    
end


%update TT203M
rto = get_param('BrowarModel/Kadz zacierna/TT203M/GUIMon','RuntimeObject');
set(ad.handles.txTT203M,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203M/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203M/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT203M,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT203M,'ForegroundColor',ColourNoFaultState);    
end


%update TT203H
rto = get_param('BrowarModel/Kadz zacierna/TT203H/GUIMon','RuntimeObject');
set(ad.handles.txTT203H,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203H/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/TT203H/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT203H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT203H,'ForegroundColor',ColourNoFaultState);    
end


%update TV203
rto = get_param('BrowarModel/Kadz zacierna/Kadz zacierna/Model ogrzewacza/GUIMon','RuntimeObject');
set(ad.handles.txTV203,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F241','Value')));
if FaultEnabled > 0
   set(ad.handles.btnTV203,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTV203,'ForegroundColor',ColourNoFaultState);    
end


%update QT204
rto = get_param('BrowarModel/Kadz zacierna/QT204/GUIMon','RuntimeObject');
set(ad.handles.txQT204,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/QT204/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnQT204,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnQT204,'ForegroundColor',ColourNoFaultState);    
end


%update XV205SP
rto = get_param('BrowarModel/Kadz zacierna/XV205SP/GUIMon','RuntimeObject');
set(ad.handles.txXV205SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz zacierna/Kadz zacierna/F232','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV205,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV205,'ForegroundColor',ColourNoFaultState);    
end


%update ST205
rto = get_param('BrowarModel/Kadz zacierna/ST205/GUIMon','RuntimeObject');
set(ad.handles.txST205,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET205
rto = get_param('BrowarModel/Kadz zacierna/ET205/GUIMon','RuntimeObject');
set(ad.handles.txET205,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV205State
rto = get_param('BrowarModel/Kadz zacierna/Kadz zacierna/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txXV205State,'String','STOP');
    case 2
       set(ad.handles.txXV205State,'String','PRACA'); 
    case 3
       set(ad.handles.txXV205State,'String','ALARM'); 
    otherwise
       set(ad.handles.txXV205State,'String','***'); 
end


% ### Kadz filtracji ###
%update KadzFiltracji
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F341','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F343','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F351','Value')));
if FaultEnabled > 0
   set(ad.handles.btnKadzFiltracji,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnKadzFiltracji,'ForegroundColor',ColourNoFaultState);    
end


%update FV301
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Doplyw kadzi/Zawor dyskretny/GUIMon','RuntimeObject');
set(ad.handles.txFV301,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F311','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F312','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F313','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV301,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV301,'ForegroundColor',ColourNoFaultState);    
end


%update FV302SP
rto = get_param('BrowarModel/Kadz filtracji/FV302SP/GUIMon','RuntimeObject');
set(ad.handles.txFV302SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F314','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV302,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV302,'ForegroundColor',ColourNoFaultState);    
end


%update ST302
rto = get_param('BrowarModel/Kadz filtracji/ST302/GUIMon','RuntimeObject');
set(ad.handles.txST302,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET302
rto = get_param('BrowarModel/Kadz filtracji/ET302/GUIMon','RuntimeObject');
set(ad.handles.txET302,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV302State
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Doplyw kadzi/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV302State,'String','STOP');
    case 2
       set(ad.handles.txFV302State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV302State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV302State,'String','***'); 
end


%update FV303
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Zawor doplywu wody/GUIMon','RuntimeObject');
set(ad.handles.txFV303,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F321','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F322','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F323','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F324','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV303,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV303,'ForegroundColor',ColourNoFaultState);    
end


%update FV304SP
rto = get_param('BrowarModel/Kadz filtracji/FV304SP/GUIMon','RuntimeObject');
set(ad.handles.txFV304SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F337','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV304,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV304,'ForegroundColor',ColourNoFaultState);    
end


%update ST304
rto = get_param('BrowarModel/Kadz filtracji/ST304/GUIMon','RuntimeObject');
set(ad.handles.txST304,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET304
rto = get_param('BrowarModel/Kadz filtracji/ET304/GUIMon','RuntimeObject');
set(ad.handles.txET304,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV304State
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Odplyw + cyrkulacja/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV304State,'String','STOP');
    case 2
       set(ad.handles.txFV304State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV304State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV304State,'String','***'); 
end


%update FV305
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Odplyw + cyrkulacja/Zawor dyskretny - spust/GUIMon','RuntimeObject');
set(ad.handles.txFV305,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F331','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F332','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F333','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV305,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV305,'ForegroundColor',ColourNoFaultState);    
end


%update FV306
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Odplyw + cyrkulacja/Zawor dyskretny - powrot/GUIMon','RuntimeObject');
set(ad.handles.txFV306,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F334','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F335','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F336','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV306,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV306,'ForegroundColor',ColourNoFaultState);    
end


%update XV307SP
rto = get_param('BrowarModel/Kadz filtracji/XV307SP/GUIMon','RuntimeObject');
set(ad.handles.txXV307SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/Kadz filtracji/F342','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV307,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV307,'ForegroundColor',ColourNoFaultState);    
end


%update ST307
rto = get_param('BrowarModel/Kadz filtracji/ST307/GUIMon','RuntimeObject');
set(ad.handles.txST307,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET307
rto = get_param('BrowarModel/Kadz filtracji/ET307/GUIMon','RuntimeObject');
set(ad.handles.txET307,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update XV307State
rto = get_param('BrowarModel/Kadz filtracji/Kadz filtracji/Zbiornik gorny/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txXV307State,'String','STOP');
    case 2
       set(ad.handles.txXV307State,'String','PRACA'); 
    case 3
       set(ad.handles.txXV307State,'String','ALARM'); 
    otherwise
       set(ad.handles.txXV307State,'String','***'); 
end


%update LT308
rto = get_param('BrowarModel/Kadz filtracji/LT308/GUIMon','RuntimeObject');
set(ad.handles.txLT308,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT308/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT308/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT308,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT308,'ForegroundColor',ColourNoFaultState);    
end


%update LT308H
rto = get_param('BrowarModel/Kadz filtracji/LT308H/GUIMon','RuntimeObject');
set(ad.handles.txLT308H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT308H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT308H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT308H,'ForegroundColor',ColourNoFaultState);    
end


%update LT308L
rto = get_param('BrowarModel/Kadz filtracji/LT308L/GUIMon','RuntimeObject');
set(ad.handles.txLT308L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT308L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT308L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT308L,'ForegroundColor',ColourNoFaultState);    
end


%update LT309
rto = get_param('BrowarModel/Kadz filtracji/LT309/GUIMon','RuntimeObject');
set(ad.handles.txLT309,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT309/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT309/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT309,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT309,'ForegroundColor',ColourNoFaultState);    
end


%update LT309H
rto = get_param('BrowarModel/Kadz filtracji/LT309H/GUIMon','RuntimeObject');
set(ad.handles.txLT309H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT309H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT309H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT309H,'ForegroundColor',ColourNoFaultState);    
end


%update LT309L
rto = get_param('BrowarModel/Kadz filtracji/LT309L/GUIMon','RuntimeObject');
set(ad.handles.txLT309L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/LT309L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT309L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT309L,'ForegroundColor',ColourNoFaultState);    
end


%update QT310
rto = get_param('BrowarModel/Kadz filtracji/QT310/GUIMon','RuntimeObject');
set(ad.handles.txQT310,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/QT310/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/QT310/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnQT310,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnQT310,'ForegroundColor',ColourNoFaultState);    
end


%update QT311
rto = get_param('BrowarModel/Kadz filtracji/QT311/GUIMon','RuntimeObject');
set(ad.handles.txQT311,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/QT311/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz filtracji/QT311/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnQT311,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnQT311,'ForegroundColor',ColourNoFaultState);    
end


%update XV312
rto = get_param('BrowarModel/Kadz filtracji/XV312/GUIMon','RuntimeObject');
set(ad.handles.txXV312,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;


% ### Kadz warzelna ###
%update KadzWarzelna
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F411','Value')));
if FaultEnabled > 0
   set(ad.handles.btnKadzWarzelna,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnKadzWarzelna,'ForegroundColor',ColourNoFaultState);    
end


%update LT401
rto = get_param('BrowarModel/Kadz warzelna/LT401/GUIMon','RuntimeObject');
set(ad.handles.txLT401,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/LT401/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/LT401/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT401,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT401,'ForegroundColor',ColourNoFaultState);    
end


%update LT401H
rto = get_param('BrowarModel/Kadz warzelna/LT401H/GUIMon','RuntimeObject');
set(ad.handles.txLT401H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/LT401H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT401H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT401H,'ForegroundColor',ColourNoFaultState);    
end


%update LT401L
rto = get_param('BrowarModel/Kadz warzelna/LT401L/GUIMon','RuntimeObject');
set(ad.handles.txLT401L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/LT401L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT401L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT401L,'ForegroundColor',ColourNoFaultState);    
end


%update TT402L
rto = get_param('BrowarModel/Kadz warzelna/TT402L/GUIMon','RuntimeObject');
set(ad.handles.txTT402L,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402L/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402L/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT402L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT402L,'ForegroundColor',ColourNoFaultState);    
end


%update TT402M
rto = get_param('BrowarModel/Kadz warzelna/TT402M/GUIMon','RuntimeObject');
set(ad.handles.txTT402M,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402M/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402M/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT402M,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT402M,'ForegroundColor',ColourNoFaultState);    
end


%update TT402H
rto = get_param('BrowarModel/Kadz warzelna/TT402H/GUIMon','RuntimeObject');
set(ad.handles.txTT402H,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402H/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/TT402H/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT402H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT402H,'ForegroundColor',ColourNoFaultState);    
end


%update TV402
rto = get_param('BrowarModel/Kadz warzelna/Kadz warzelna/Model ogrzewacza/GUIMon','RuntimeObject');
set(ad.handles.txTV402,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F421','Value')));
if FaultEnabled > 0
   set(ad.handles.btnTV402,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTV402,'ForegroundColor',ColourNoFaultState);    
end


%update FV404SP
rto = get_param('BrowarModel/Kadz warzelna/FV404SP/GUIMon','RuntimeObject');
set(ad.handles.txFV404SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F431','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV404,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV404,'ForegroundColor',ColourNoFaultState);    
end


%update ST404
rto = get_param('BrowarModel/Kadz warzelna/ST404/GUIMon','RuntimeObject');
set(ad.handles.txST404,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET404
rto = get_param('BrowarModel/Kadz warzelna/ET404/GUIMon','RuntimeObject');
set(ad.handles.txET404,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV404State
rto = get_param('BrowarModel/Kadz warzelna/Kadz warzelna/Odplyw z kadzi/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV404State,'String','STOP');
    case 2
       set(ad.handles.txFV404State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV404State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV404State,'String','***'); 
end


%update FV405
rto = get_param('BrowarModel/Kadz warzelna/Kadz warzelna/Odplyw z kadzi/Zawor dyskretny/GUIMon','RuntimeObject');
set(ad.handles.txFV405,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F441','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F442','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz warzelna/Kadz warzelna/F443','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV405,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV405,'ForegroundColor',ColourNoFaultState);    
end


% ### System dozowania chmielu ###
%update DozownikChmielu
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F521','Value')));
if FaultEnabled > 0
   set(ad.handles.btnDozownikChmielu,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnDozownikChmielu,'ForegroundColor',ColourNoFaultState);    
end


%update LV501
rto = get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/Zawor doplywu chmielu/GUIMon','RuntimeObject');
set(ad.handles.txLV501,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F511','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F512','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F513','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F514','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLV501,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLV501,'ForegroundColor',ColourNoFaultState);    
end


%update LT502H
rto = get_param('BrowarModel/System dozowania chmielu/LT502H/GUIMon','RuntimeObject');
set(ad.handles.txLT502H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/LT502H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT502H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT502H,'ForegroundColor',ColourNoFaultState);    
end


%update LT502L
rto = get_param('BrowarModel/System dozowania chmielu/LT502L/GUIMon','RuntimeObject');
set(ad.handles.txLT502L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/LT502L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT502L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT502L,'ForegroundColor',ColourNoFaultState);    
end


%update PT503
rto = get_param('BrowarModel/System dozowania chmielu/PT503/GUIMon','RuntimeObject');
set(ad.handles.txPT503,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/PT503/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/PT503/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnPT503,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnPT503,'ForegroundColor',ColourNoFaultState);    
end


%update PV503
rto = get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/Zasilacz hydrauliczny/GUIMon','RuntimeObject');
set(ad.handles.txPV503,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F531','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F532','Value')));
if FaultEnabled > 0
   set(ad.handles.btnPV503,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnPV503,'ForegroundColor',ColourNoFaultState);    
end


%update XT504
rto = get_param('BrowarModel/System dozowania chmielu/XT504/GUIMon','RuntimeObject');
set(ad.handles.txXT504,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/XT504/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/XT504/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnXT504,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT504,'ForegroundColor',ColourNoFaultState);    
end


%update XV504
rto = get_param('BrowarModel/System dozowania chmielu/XV504/GUIMon','RuntimeObject');
set(ad.handles.txXV504,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F541','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV504,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV504,'ForegroundColor',ColourNoFaultState);    
end


%update XT504C
rto = get_param('BrowarModel/System dozowania chmielu/XT504C/GUIMon','RuntimeObject');
set(ad.handles.txXT504C,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/XT504C/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT504C,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT504C,'ForegroundColor',ColourNoFaultState);    
end


%update WT505
rto = get_param('BrowarModel/System dozowania chmielu/WT505/GUIMon','RuntimeObject');
set(ad.handles.txWT505,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/WT505/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/WT505/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnWT505,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnWT505,'ForegroundColor',ColourNoFaultState);    
end


%update XV506
rto = get_param('BrowarModel/System dozowania chmielu/XV506/GUIMon','RuntimeObject');
set(ad.handles.txXV506,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F551','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV506,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV506,'ForegroundColor',ColourNoFaultState);    
end


%update XT506H
rto = get_param('BrowarModel/System dozowania chmielu/XT506H/GUIMon','RuntimeObject');
set(ad.handles.txXT506H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/XT506H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT506H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT506H,'ForegroundColor',ColourNoFaultState);    
end


%update XT506L
rto = get_param('BrowarModel/System dozowania chmielu/XT506L/GUIMon','RuntimeObject');
set(ad.handles.txXT506L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania chmielu/XT506L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT506L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT506L,'ForegroundColor',ColourNoFaultState);    
end


% ### Schladzacz ###
%update TV601
rto = get_param('BrowarModel/Schladzacz/TV601/GUIMon','RuntimeObject');
set(ad.handles.txTV601,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;



%update TT601
rto = get_param('BrowarModel/Schladzacz/TT601/GUIMon','RuntimeObject');
set(ad.handles.txTT601,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT601/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT601/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT601,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT601,'ForegroundColor',ColourNoFaultState);    
end

%update TT602
rto = get_param('BrowarModel/Schladzacz/TT602/GUIMon','RuntimeObject');
set(ad.handles.txTT602,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT602/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT602/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT602,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT602,'ForegroundColor',ColourNoFaultState);    
end


%update TT603
rto = get_param('BrowarModel/Schladzacz/TT603/GUIMon','RuntimeObject');
set(ad.handles.txTT603,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT603/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT603/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT603,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT603,'ForegroundColor',ColourNoFaultState);    
end


%update TT604
rto = get_param('BrowarModel/Schladzacz/TT604/GUIMon','RuntimeObject');
set(ad.handles.txTT604,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT604/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Schladzacz/TT604/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT604,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT604,'ForegroundColor',ColourNoFaultState);    
end


% ### Kadz fermentacyjna ###
%update KadzFermentacyjna
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F711','Value')));
if FaultEnabled > 0
   set(ad.handles.btnKadzFermentacyjna,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnKadzFermentacyjna,'ForegroundColor',ColourNoFaultState);    
end


%update LT701
rto = get_param('BrowarModel/Kadz fermentacyjna/LT701/GUIMon','RuntimeObject');
set(ad.handles.txLT701,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/LT701/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/LT701/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnLT701,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT701,'ForegroundColor',ColourNoFaultState);    
end


%update LT701H
rto = get_param('BrowarModel/Kadz fermentacyjna/LT701H/GUIMon','RuntimeObject');
set(ad.handles.txLT701H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/LT701H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT701H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT701H,'ForegroundColor',ColourNoFaultState);    
end


%update LT701L
rto = get_param('BrowarModel/Kadz fermentacyjna/LT701L/GUIMon','RuntimeObject');
set(ad.handles.txLT701L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/LT701L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT701L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT701L,'ForegroundColor',ColourNoFaultState);    
end


%update TT702L
rto = get_param('BrowarModel/Kadz fermentacyjna/TT702L/GUIMon','RuntimeObject');
set(ad.handles.txTT702L,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702L/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702L/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT702L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT702L,'ForegroundColor',ColourNoFaultState);    
end


%update TT702M
rto = get_param('BrowarModel/Kadz fermentacyjna/TT702M/GUIMon','RuntimeObject');
set(ad.handles.txTT702M,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702M/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702M/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT702M,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT702M,'ForegroundColor',ColourNoFaultState);    
end


%update TT702H
rto = get_param('BrowarModel/Kadz fermentacyjna/TT702H/GUIMon','RuntimeObject');
set(ad.handles.txTT702H,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702H/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/TT702H/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnTT702H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTT702H,'ForegroundColor',ColourNoFaultState);    
end


%update TV702
rto = get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/Model ogrzewacza/GUIMon','RuntimeObject');
set(ad.handles.txTV702,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F721','Value')));
if FaultEnabled > 0
   set(ad.handles.btnTV702,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnTV702,'ForegroundColor',ColourNoFaultState);    
end


%update XV704SP
rto = get_param('BrowarModel/Kadz fermentacyjna/XV704SP/GUIMon','RuntimeObject');
set(ad.handles.txXV704SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F731','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV704,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV704,'ForegroundColor',ColourNoFaultState);    
end


%update ST704
rto = get_param('BrowarModel/Kadz fermentacyjna/ST704/GUIMon','RuntimeObject');
set(ad.handles.txST704,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET704
rto = get_param('BrowarModel/Kadz fermentacyjna/ET704/GUIMon','RuntimeObject');
set(ad.handles.txET704,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV704State
rto = get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txXV704State,'String','STOP');
    case 2
       set(ad.handles.txXV704State,'String','PRACA'); 
    case 3
       set(ad.handles.txXV704State,'String','ALARM'); 
    otherwise
       set(ad.handles.txXV704State,'String','***'); 
end


%update FV705SP
rto = get_param('BrowarModel/Kadz fermentacyjna/FV705SP/GUIMon','RuntimeObject');
set(ad.handles.txFV705SP,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F741','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV705,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV705,'ForegroundColor',ColourNoFaultState);    
end


%update ST705
rto = get_param('BrowarModel/Kadz fermentacyjna/ST705/GUIMon','RuntimeObject');
set(ad.handles.txST705,'String',num2str(round(rto.OutputPort(1).Data)));


%update ET705
rto = get_param('BrowarModel/Kadz fermentacyjna/ET705/GUIMon','RuntimeObject');
set(ad.handles.txET705,'String',num2str(round(100*rto.OutputPort(1).Data)/100));


%update FV705State
rto = get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/Odplyw z kadzi/Silnik elektryczny/Stan/GUIMon','RuntimeObject');
State = rto.OutputPort(1).Data;
switch State
    case 1
       set(ad.handles.txFV705State,'String','STOP');
    case 2
       set(ad.handles.txFV705State,'String','PRACA'); 
    case 3
       set(ad.handles.txFV705State,'String','ALARM'); 
    otherwise
       set(ad.handles.txFV705State,'String','***'); 
end


%update FV706
rto = get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/Odplyw z kadzi/Zawor dyskretny/GUIMon','RuntimeObject');
set(ad.handles.txFV706,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F751','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F752','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F753','Value')));
if FaultEnabled > 0
   set(ad.handles.btnFV706,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnFV706,'ForegroundColor',ColourNoFaultState);    
end


% ### System dozowania drozdzy ###
%update DozownikDrozdzy
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F821','Value')));
if FaultEnabled > 0
   set(ad.handles.btnDozownikDrozdzy,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnDozownikDrozdzy,'ForegroundColor',ColourNoFaultState);    
end


%update LV801
rto = get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/Zawor doplywu drozdzy/GUIMon','RuntimeObject');
set(ad.handles.txLV801,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F811','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F812','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F813','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F814','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLV801,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLV801,'ForegroundColor',ColourNoFaultState);    
end


%update LT802H
rto = get_param('BrowarModel/System dozowania drozdzy/LT802H/GUIMon','RuntimeObject');
set(ad.handles.txLT802H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/LT802H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT802H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT802H,'ForegroundColor',ColourNoFaultState);    
end


%update LT802L
rto = get_param('BrowarModel/System dozowania drozdzy/LT802L/GUIMon','RuntimeObject');
set(ad.handles.txLT802L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/LT802L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnLT802L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnLT802L,'ForegroundColor',ColourNoFaultState);    
end


%update PT803
rto = get_param('BrowarModel/System dozowania drozdzy/PT803/GUIMon','RuntimeObject');
set(ad.handles.txPT803,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/PT803/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/PT803/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnPT803,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnPT803,'ForegroundColor',ColourNoFaultState);    
end


%update PV803
rto = get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/Zasilacz hydrauliczny/GUIMon','RuntimeObject');
set(ad.handles.txPV803,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F831','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F832','Value')));
if FaultEnabled > 0
   set(ad.handles.btnPV803,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnPV803,'ForegroundColor',ColourNoFaultState);    
end


%update XT804
rto = get_param('BrowarModel/System dozowania drozdzy/XT804/GUIMon','RuntimeObject');
set(ad.handles.txXT804,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/XT804/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/XT804/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnXT804,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT804,'ForegroundColor',ColourNoFaultState);    
end


%update XV804
rto = get_param('BrowarModel/System dozowania drozdzy/XV804/GUIMon','RuntimeObject');
set(ad.handles.txXV804,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F841','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV804,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV804,'ForegroundColor',ColourNoFaultState);    
end


%update XT804C
rto = get_param('BrowarModel/System dozowania drozdzy/XT804C/GUIMon','RuntimeObject');
set(ad.handles.txXT804C,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/XT804C/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT804C,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT804C,'ForegroundColor',ColourNoFaultState);    
end


%update WT805
rto = get_param('BrowarModel/System dozowania drozdzy/WT805/GUIMon','RuntimeObject');
set(ad.handles.txWT805,'String',num2str(round(100*rto.OutputPort(1).Data)/100));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/WT805/F_offset','Value')));
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/WT805/F_gain','Gain')));
if FaultEnabled > 0
   set(ad.handles.btnWT805,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnWT805,'ForegroundColor',ColourNoFaultState);    
end


%update XV806
rto = get_param('BrowarModel/System dozowania drozdzy/XV806/GUIMon','RuntimeObject');
set(ad.handles.txXV806,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F851','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXV806,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXV806,'ForegroundColor',ColourNoFaultState);    
end


%update XT806H
rto = get_param('BrowarModel/System dozowania drozdzy/XT806H/GUIMon','RuntimeObject');
set(ad.handles.txXT806H,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/XT806H/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT806H,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT806H,'ForegroundColor',ColourNoFaultState);    
end


%update XT806L
rto = get_param('BrowarModel/System dozowania drozdzy/XT806L/GUIMon','RuntimeObject');
set(ad.handles.txXT806L,'String',num2str(rto.OutputPort(1).Data));
FaultEnabled = 0;
FaultEnabled = FaultEnabled + abs(str2double(get_param('BrowarModel/System dozowania drozdzy/XT806L/FT','Value')));
if FaultEnabled > 0
   set(ad.handles.btnXT806L,'ForegroundColor',ColourFaultState);    
else
   set(ad.handles.btnXT806L,'ForegroundColor',ColourNoFaultState);    
end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to ensure that the model actually exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelExists = localValidateInputs(modelName)

num = exist(modelName,'file');
if num == 4
    modelExists = true;
else
    modelExists = false;
end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check that model is still loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modelLoaded = modelIsLoaded(modelName)

try
    modelLoaded = ...
        ~isempty(find_system('Type','block_diagram','Name',modelName));
catch ME %#ok
    % Return false if the model can't be found
    modelLoaded = false;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to determine motor state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = localLoadModel(modelName)

% Load the simulink model
if ~modelIsLoaded(modelName)
    load_system(modelName);
end
ad.modelName = modelName;
end


% --- Executes during object creation, after setting all properties.
function axesBackground_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesBackground
axes(hObject);
% imshow('Browar.tif');
img = imread('Browar.tif');
imagesc(img);
end


% --- Executes on button press in btnZaklProcOn.
function btnZaklProcOn_Callback(hObject, eventdata, handles)
% hObject    handle to btnZaklProcOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/ZaklProc','Value','1');

% Turn off the ZaklProcOn button
set(ad.handles.btnZaklProcOn,'Enable','off');
% Turn on the ZaklProcOff button
set(ad.handles.btnZaklProcOff,'Enable','on');
end


% --- Executes on button press in btnZaklProcOff.
function btnZaklProcOff_Callback(hObject, eventdata, handles)
% hObject    handle to btnZaklProcOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/ZaklProc','Value','0');

% Turn off the ZaklProcOff button
set(ad.handles.btnZaklProcOff,'Enable','off');
% Turn on the ZaklProcOn button
set(ad.handles.btnZaklProcOn,'Enable','on');
end


% --- Executes on button press in btnZaklPomOn.
function btnZaklPomOn_Callback(hObject, eventdata, handles)
% hObject    handle to btnZaklPomOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/ZaklPom','Value','1');

% Turn off the ZaklPomOn button
set(ad.handles.btnZaklPomOn,'Enable','off');
% Turn on the ZaklPomOff button
set(ad.handles.btnZaklPomOff,'Enable','on');
end


% --- Executes on button press in btnZaklPomOff.
function btnZaklPomOff_Callback(hObject, eventdata, handles)
% hObject    handle to btnZaklPomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/ZaklPom','Value','0');

% Turn off the ZaklPomOff button
set(ad.handles.btnZaklPomOff,'Enable','off');
% Turn on the ZaklPomOnf button
set(ad.handles.btnZaklPomOn,'Enable','on');
end


% --- Executes on button press in btnSymulacjaStart.
function btnSymulacjaStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnSymulacjaStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set_param('Browar.mdl','SimulationCommand','start');
% get the application data
ad = guidata(hObject);

% Load the model if required (it may have been closed manually).
if ~modelIsLoaded(ad.modelName)
    load_system(ad.modelName);
end

% toggle the simulation buttons
% Turn off the Start button
set(ad.handles.btnSymulacjaStart,'Enable','off');
% Turn on the Stop button
set(ad.handles.btnSymulacjaStop,'Enable','on');

% Check that a valid value has been entered
str = get(ad.handles.txCzasSymulacji,'String');
newValue = str2double(str);

% set the stop time to inf
set_param(ad.modelName,'StopTime','inf');
% set the simulation mode to normal
set_param(ad.modelName,'SimulationMode','normal');
% start the model
set_param(ad.modelName,'SimulationCommand','start');
%Automatycznie uruchom timer
start(ad.handles.TmrScreenRefresh); 
end


% --- Executes on button press in btnSymulacjaStop.
function btnSymulacjaStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnSymulacjaStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ad = guidata(hObject);

%stop represh timer
stop(ad.handles.TmrScreenRefresh); 

% stop the model
set_param(ad.modelName,'SimulationCommand','stop');

% toggle the simulation buttons
% Turn on the Start button
set(ad.handles.btnSymulacjaStart,'Enable','on');
% Turn off the Stop button
set(ad.handles.btnSymulacjaStop,'Enable','off');
end


% --- Executes on button press in btnSymulacjaNormalna.
function btnSymulacjaNormalna_Callback(hObject, eventdata, handles)
% hObject    handle to btnSymulacjaNormalna (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/TrybSym','Value','0');
% toggle the simulation speed buttons
% Turn off the SymulacjaNormalna button
set(ad.handles.btnSymulacjaNormalna,'Enable','off');
% Turn on the SymulacjaNormalna button
set(ad.handles.btnSymulacjaSzybka,'Enable','on');
end


% --- Executes on button press in btnSymulacjaSzybka.
function btnSymulacjaSzybka_Callback(hObject, eventdata, handles)
% hObject    handle to btnSymulacjaSzybka (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/TrybSym','Value','1');
% toggle the simulation speed buttons
% Turn on the SymulacjaNormalna button
set(ad.handles.btnSymulacjaNormalna,'Enable','on');
% Turn off the SymulacjaNormalna button
set(ad.handles.btnSymulacjaSzybka,'Enable','off');
end


% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ad = guidata(hObject);
close(gcf);
end


% --- Executes on button press in btnTrybSterZdalne.
function btnTrybSterZdalne_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrybSterZdalne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/TrybSter','Value','1');

% Turn off the Zdalne button
set(ad.handles.btnTrybSterZdalne,'Enable','off');
% Turn on the Lokalne button
set(ad.handles.btnTrybSterLokalne,'Enable','on');
end


% --- Executes on button press in btnTrybSterLokalne.
function btnTrybSterLokalne_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrybSterLokalne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the application data
ad = guidata(hObject);

set_param('BrowarModel/Parametry symulacji/TrybSter','Value','0');

% Turn on the Zdalne button
set(ad.handles.btnTrybSterZdalne,'Enable','on');
% Turn off the Lokalne button
set(ad.handles.btnTrybSterLokalne,'Enable','off');
end


% --- Executes on button press in btnResetUszkodzen.
function btnResetUszkodzen_Callback(hObject, eventdata, handles)
% hObject    handle to btnResetUszkodzen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F111','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F112','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F113','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F114','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F121','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F131','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F132','Value','0');
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F133','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F134','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F135','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F136','Value','0');
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F141','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F142','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F143','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F144','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F145','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/Mlyn browarniany/F146','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/LT102/F_offset','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/LT102/F_gain','Gain',num2str(0));
set_param('BrowarModel/Mlyn browarniany/LT102H/FT','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT102H/FT_value','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT102L/FT','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT102L/FT_value','Value','0');
set_param('BrowarModel/Mlyn browarniany/TT103/F_offset','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/TT103/F_gain','Gain',num2str(0));
set_param('BrowarModel/Mlyn browarniany/LT104H/FT','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT104H/FT_value','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT104L/FT','Value','0');
set_param('BrowarModel/Mlyn browarniany/LT104L/FT_value','Value','0');
set_param('BrowarModel/Mlyn browarniany/TT105/F_offset','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/TT105/F_gain','Gain',num2str(0));
set_param('BrowarModel/Mlyn browarniany/FT105/F_offset','Value',num2str(0));
set_param('BrowarModel/Mlyn browarniany/FT105/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F211','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F212','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F213','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F214','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F221','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F231','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F232','Value','0');
set_param('BrowarModel/Kadz zacierna/Kadz zacierna/F241','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/FT201/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/FT201/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/LT202/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/LT202/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/LT202H/FT','Value','0');
set_param('BrowarModel/Kadz zacierna/LT202H/FT_value','Value','0');
set_param('BrowarModel/Kadz zacierna/LT202L/FT','Value','0');
set_param('BrowarModel/Kadz zacierna/LT202L/FT_value','Value','0');
set_param('BrowarModel/Kadz zacierna/TT203H/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/TT203H/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/TT203L/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/TT203L/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/TT203M/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz zacierna/TT203M/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz zacierna/QT204/FT','Value','0');
set_param('BrowarModel/Kadz zacierna/QT204/FT_value','Value','0');
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F311','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F312','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F313','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F314','Value','0');
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F321','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F322','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F323','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F324','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F331','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F332','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F333','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F334','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F335','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F336','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F337','Value','0');
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F341','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F342','Value','0');
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F343','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/Kadz filtracji/F351','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/LT308/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/LT308/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz filtracji/LT308H/FT','Value','0');
set_param('BrowarModel/Kadz filtracji/LT308H/FT_value','Value','0');
set_param('BrowarModel/Kadz filtracji/LT308L/FT','Value','0');
set_param('BrowarModel/Kadz filtracji/LT308L/FT_value','Value','0');
set_param('BrowarModel/Kadz filtracji/LT309/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/LT309/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz filtracji/LT309H/FT','Value','0');
set_param('BrowarModel/Kadz filtracji/LT309H/FT_value','Value','0');
set_param('BrowarModel/Kadz filtracji/LT309L/FT','Value','0');
set_param('BrowarModel/Kadz filtracji/LT309L/FT_value','Value','0');
set_param('BrowarModel/Kadz filtracji/QT310/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/QT310/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz filtracji/QT311/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz filtracji/QT311/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F411','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F421','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F431','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F441','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F442','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/Kadz warzelna/F443','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/LT401/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/LT401/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz warzelna/LT401H/FT','Value','0');
set_param('BrowarModel/Kadz warzelna/LT401H/FT_value','Value','0');
set_param('BrowarModel/Kadz warzelna/LT401L/FT','Value','0');
set_param('BrowarModel/Kadz warzelna/LT401L/FT_value','Value','0');
set_param('BrowarModel/Kadz warzelna/TT402H/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/TT402H/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz warzelna/TT402L/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/TT402L/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz warzelna/TT402M/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz warzelna/TT402M/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F511','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F512','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F513','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F514','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F521','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F531','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F532','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F541','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/System dozowania chmielu/F551','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/LT502H/FT','Value','0');
set_param('BrowarModel/System dozowania chmielu/LT502H/FT_value','Value','0');
set_param('BrowarModel/System dozowania chmielu/LT502L/FT','Value','0');
set_param('BrowarModel/System dozowania chmielu/LT502L/FT_value','Value','0');
set_param('BrowarModel/System dozowania chmielu/PT503/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/PT503/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania chmielu/XT504/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/XT504/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania chmielu/XT504C/FT','Value','0');
set_param('BrowarModel/System dozowania chmielu/XT504C/FT_value','Value','0');
set_param('BrowarModel/System dozowania chmielu/WT505/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania chmielu/WT505/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania chmielu/XT506H/FT','Value','0');
set_param('BrowarModel/System dozowania chmielu/XT506H/FT_value','Value','0');
set_param('BrowarModel/System dozowania chmielu/XT506L/FT','Value','0');
set_param('BrowarModel/System dozowania chmielu/XT506L/FT_value','Value','0');
set_param('BrowarModel/Schladzacz/TT601/F_offset','Value',num2str(0));
set_param('BrowarModel/Schladzacz/TT601/F_gain','Gain',num2str(0));
set_param('BrowarModel/Schladzacz/TT602/F_offset','Value',num2str(0));
set_param('BrowarModel/Schladzacz/TT602/F_gain','Gain',num2str(0));
set_param('BrowarModel/Schladzacz/TT603/F_offset','Value',num2str(0));
set_param('BrowarModel/Schladzacz/TT603/F_gain','Gain',num2str(0));
set_param('BrowarModel/Schladzacz/TT604/F_offset','Value',num2str(0));
set_param('BrowarModel/Schladzacz/TT604/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F711','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F721','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F731','Value',num2str(0));
%set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F732','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F741','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F751','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F752','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/Kadz fermentacyjna/F753','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/LT701/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/LT701/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/LT701H/FT','Value','0');
set_param('BrowarModel/Kadz fermentacyjna/LT701H/FT_value','Value','0');
set_param('BrowarModel/Kadz fermentacyjna/LT701L/FT','Value','0');
set_param('BrowarModel/Kadz fermentacyjna/LT701L/FT_value','Value','0');
set_param('BrowarModel/Kadz fermentacyjna/TT702H/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/TT702H/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/TT702L/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/TT702L/F_gain','Gain',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/TT702M/F_offset','Value',num2str(0));
set_param('BrowarModel/Kadz fermentacyjna/TT702M/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F811','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F812','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F813','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F814','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F821','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F831','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F832','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F841','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/System dozowania drozdzy/F851','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/LT802H/FT','Value','0');
set_param('BrowarModel/System dozowania drozdzy/LT802H/FT_value','Value','0');
set_param('BrowarModel/System dozowania drozdzy/LT802L/FT','Value','0');
set_param('BrowarModel/System dozowania drozdzy/LT802L/FT_value','Value','0');
set_param('BrowarModel/System dozowania drozdzy/PT803/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/PT803/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/XT804/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/XT804/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/XT804C/FT','Value','0');
set_param('BrowarModel/System dozowania drozdzy/XT804C/FT_value','Value','0');
set_param('BrowarModel/System dozowania drozdzy/WT805/F_offset','Value',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/WT805/F_gain','Gain',num2str(0));
set_param('BrowarModel/System dozowania drozdzy/XT806H/FT','Value','0');
set_param('BrowarModel/System dozowania drozdzy/XT806H/FT_value','Value','0');
set_param('BrowarModel/System dozowania drozdzy/XT806L/FT','Value','0');
set_param('BrowarModel/System dozowania drozdzy/XT806L/FT_value','Value','0');
end


% --- Executes on button press in btnMlyn.
function btnMlyn_Callback(hObject, eventdata, handles)
% hObject    handle to btnMlyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_Mlyn);
end


% --- Executes on button press in btnMlynDozownik.
function btnMlynDozownik_Callback(hObject, eventdata, handles)
% hObject    handle to btnMlynDozownik (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_MlynDozownik);
end


% --- Executes on button press in btnMlynWalce.
function btnMlynWalce_Callback(hObject, eventdata, handles)
% hObject    handle to btnMlynWalce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_MlynWalce);
end


% --- Executes on button press in btnLV101.
function btnLV101_Callback(hObject, eventdata, handles)
% hObject    handle to btnLV101 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LV101);
end


% --- Executes on button press in btnLT102.
function btnLT102_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT102 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT102);
end


% --- Executes on button press in btnLT102H.
function btnLT102H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT102H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT102H);
end


% --- Executes on button press in btnLT102L.
function btnLT102L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT102L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT102L);
end


% --- Executes on button press in btnFV103.
function btnFV103_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV103);
end


% --- Executes on button press in btnTT103.
function btnTT103_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT103 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT103);
end


% --- Executes on button press in btnLT104H.
function btnLT104H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT104H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT104H);
end


% --- Executes on button press in btnLT104L.
function btnLT104L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT104L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT104L);
end


% --- Executes on button press in btnFT105.
function btnFT105_Callback(hObject, eventdata, handles)
% hObject    handle to btnFT105 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FT105);
end


% --- Executes on button press in btnFV105.
function btnFV105_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV105 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV105);
end


% --- Executes on button press in btnTT105.
function btnTT105_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT105 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT105);
end


% --- Executes on button press in btnKadzZacierna.
function btnKadzZacierna_Callback(hObject, eventdata, handles)
% hObject    handle to btnKadzZacierna (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_KadzZacierna);
end


% --- Executes on button press in btnFT201.
function btnFT201_Callback(hObject, eventdata, handles)
% hObject    handle to btnFT201 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FT201);
end


% --- Executes on button press in btnLT202.
function btnLT202_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT202 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT202);
end


% --- Executes on button press in btnLV201.
function btnLV201_Callback(hObject, eventdata, handles)
% hObject    handle to btnLV201 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LV201);
end


% --- Executes on button press in btnLT202H.
function btnLT202H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT202H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT202H);
end


% --- Executes on button press in btnLT202L.
function btnLT202L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT202L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT202L);
end


% --- Executes on button press in btnTT203H.
function btnTT203H_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT203H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT203H);
end


% --- Executes on button press in btnTT203M.
function btnTT203M_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT203M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT203M);
end


% --- Executes on button press in btnTT203L.
function btnTT203L_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT203L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT203L);
end


% --- Executes on button press in btnTV203.
function btnTV203_Callback(hObject, eventdata, handles)
% hObject    handle to btnTV203 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TV203);
end


% --- Executes on button press in btnQT204.
function btnQT204_Callback(hObject, eventdata, handles)
% hObject    handle to btnQT204 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_QT204);
end


% --- Executes on button press in btnXV205.
function btnXV205_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV205 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV205);
end


% --- Executes on button press in btnKadzFiltracji.
function btnKadzFiltracji_Callback(hObject, eventdata, handles)
% hObject    handle to btnKadzFiltracji (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_KadzFiltracji);
end


% --- Executes on button press in btnFV301.
function btnFV301_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV301 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV301);
end


% --- Executes on button press in btnFV302.
function btnFV302_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV302 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV302);
end


% --- Executes on button press in btnFV303.
function btnFV303_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV303 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV303);
end


% --- Executes on button press in btnFV304.
function btnFV304_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV304 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV304);
end


% --- Executes on button press in btnFV305.
function btnFV305_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV305 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV305);
end


% --- Executes on button press in btnFV306.
function btnFV306_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV306 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV306);
end

% --- Executes on button press in btnXV307.
function btnXV307_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV307 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV307);
end


% --- Executes on button press in btnLT308.
function btnLT308_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT308 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT308);
end


% --- Executes on button press in btnLT308H.
function btnLT308H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT308H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT308H);
end


% --- Executes on button press in btnLT308L.
function btnLT308L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT308L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT308L);
end


% --- Executes on button press in btnLT309.
function btnLT309_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT309 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT309);
end


% --- Executes on button press in btnLT309H.
function btnLT309H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT309H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT309H);
end

% --- Executes on button press in btnLT309L.
function btnLT309L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT309L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT309L);
end


% --- Executes on button press in btnQT310.
function btnQT310_Callback(hObject, eventdata, handles)
% hObject    handle to btnQT310 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_QT310);
end


% --- Executes on button press in btnQT311.
function btnQT311_Callback(hObject, eventdata, handles)
% hObject    handle to btnQT311 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_QT311);
end


% --- Executes on button press in btnXV312.
function btnXV312_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV312 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV312);
end


% --- Executes on button press in btnKadzWarzelna.
function btnKadzWarzelna_Callback(hObject, eventdata, handles)
% hObject    handle to btnKadzWarzelna (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_KadzWarzelna);
end


% --- Executes on button press in btnLT401.
function btnLT401_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT401 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT401);
end


% --- Executes on button press in btnLT401H.
function btnLT401H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT401H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT401H);
end


% --- Executes on button press in btnLT401L.
function btnLT401L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT401L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT401L);
end


% --- Executes on button press in btnTV402.
function btnTV402_Callback(hObject, eventdata, handles)
% hObject    handle to btnTV402 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TV402);
end


% --- Executes on button press in btnTT402H.
function btnTT402H_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT402H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT402H);
end


% --- Executes on button press in btnTT402M.
function btnTT402M_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT402M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT402M);
end


% --- Executes on button press in btnTT402L.
function btnTT402L_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT402L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT402L);
end


% --- Executes on button press in btnFV404.
function btnFV404_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV404 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV404);
end


% --- Executes on button press in btnFV405.
function btnFV405_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV405 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV405);
end


% --- Executes on button press in btnDozownikChmielu.
function btnDozownikChmielu_Callback(hObject, eventdata, handles)
% hObject    handle to btnDozownikChmielu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_DozownikChmielu);
end


% --- Executes on button press in btnLV501.
function btnLV501_Callback(hObject, eventdata, handles)
% hObject    handle to btnLV501 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LV501);
end


% --- Executes on button press in btnLT502H.
function btnLT502H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT502H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT502H);
end


% --- Executes on button press in btnLT502L.
function btnLT502L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT502L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT502L);
end


% --- Executes on button press in btnPT503.
function btnPT503_Callback(hObject, eventdata, handles)
% hObject    handle to btnPT503 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_PT503);
end


% --- Executes on button press in btnPV503.
function btnPV503_Callback(hObject, eventdata, handles)
% hObject    handle to btnPV503 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_PV503);
end


% --- Executes on button press in btnXT504C.
function btnXT504C_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT504C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT504C);
end


% --- Executes on button press in btnXV504.
function btnXV504_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV504 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV504);
end


% --- Executes on button press in btnXT504.
function btnXT504_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT504 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT504);
end

% --- Executes on button press in btnWT505.
function btnWT505_Callback(hObject, eventdata, handles)
% hObject    handle to btnWT505 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_WT505);
end


% --- Executes on button press in btnXT506H.
function btnXT506H_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT506H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT506H);
end


% --- Executes on button press in btnXT506L.
function btnXT506L_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT506L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT506L);
end


% --- Executes on button press in btnXV506.
function btnXV506_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV506 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV506);
end


% --- Executes on button press in btnTV601.
function btnTV601_Callback(hObject, eventdata, handles)
% hObject    handle to btnTV601 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TV601);
end


% --- Executes on button press in btnTT601.
function btnTT601_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT601 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT601);
end


% --- Executes on button press in btnTT602.
function btnTT602_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT602 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT602);
end


% --- Executes on button press in btnTT603.
function btnTT603_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT603 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT603);
end


% --- Executes on button press in btnTT604.
function btnTT604_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT604 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT604);
end


% --- Executes on button press in btnKadzFermentacyjna.
function btnKadzFermentacyjna_Callback(hObject, eventdata, handles)
% hObject    handle to btnKadzFermentacyjna (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_KadzFermentacyjna);
end


% --- Executes on button press in btnLT701H.
function btnLT701H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT701H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT701H);
end


% --- Executes on button press in btnLT701L.
function btnLT701L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT701L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT701L);
end


% --- Executes on button press in btnLT701.
function btnLT701_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT701 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT701);
end


% --- Executes on button press in btnTV702.
function btnTV702_Callback(hObject, eventdata, handles)
% hObject    handle to btnTV702 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TV702);
end


% --- Executes on button press in btnTT702H.
function btnTT702H_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT702H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT702H);
end


% --- Executes on button press in btnTT702M.
function btnTT702M_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT702M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT702M);
end


% --- Executes on button press in btnTT702L.
function btnTT702L_Callback(hObject, eventdata, handles)
% hObject    handle to btnTT702L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_TT702L);
end


% --- Executes on button press in btnXV704.
function btnXV704_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV704 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV704);
end


% --- Executes on button press in btnFV706.
function btnFV706_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV706 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV706);
end


% --- Executes on button press in btnFV705.
function btnFV705_Callback(hObject, eventdata, handles)
% hObject    handle to btnFV705 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_FV705);
end


% --- Executes on button press in btnDozownikDrozdzy.
function btnDozownikDrozdzy_Callback(hObject, eventdata, handles)
% hObject    handle to btnDozownikDrozdzy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_DozownikDrozdzy);
end


% --- Executes on button press in btnLV801.
function btnLV801_Callback(hObject, eventdata, handles)
% hObject    handle to btnLV801 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LV801);
end


% --- Executes on button press in btnLT802H.
function btnLT802H_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT802H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT802H);
end


% --- Executes on button press in btnLT802L.
function btnLT802L_Callback(hObject, eventdata, handles)
% hObject    handle to btnLT802L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_LT802L);
end


% --- Executes on button press in btnPT803.
function btnPT803_Callback(hObject, eventdata, handles)
% hObject    handle to btnPT803 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_PT803);
end


% --- Executes on button press in btnPV803.
function btnPV803_Callback(hObject, eventdata, handles)
% hObject    handle to btnPV803 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_PV803);
end


% --- Executes on button press in btnXV804.
function btnXV804_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV804 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV804);
end


% --- Executes on button press in btnXT804.
function btnXT804_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT804 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT804);
end


% --- Executes on button press in btnXT804C.
function btnXT804C_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT804C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT804C);
end


% --- Executes on button press in btnWT805.
function btnWT805_Callback(hObject, eventdata, handles)
% hObject    handle to btnWT805 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_WT805);
end


% --- Executes on button press in btnXT806H.
function btnXT806H_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT806H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT806H);
end


% --- Executes on button press in btnXT806L.
function btnXT806L_Callback(hObject, eventdata, handles)
% hObject    handle to btnXT806L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XT806L);
end


% --- Executes on button press in btnXV806.
function btnXV806_Callback(hObject, eventdata, handles)
% hObject    handle to btnXV806 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(Browar_XV806);
end