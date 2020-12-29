function pmEllipse_Fig6_S7_S8
% Make Figures 6A-B-C, S7 and S8
% 
% TODO: separate it in sub-scripts that use the same dataset that we load here
% 
% See also
%  s00_MainFiguresScript
% 
%% Plotting parameters
clear all
ext  = 'png'; % Could be svg
saveTo = fullfile(pmRootPath,'local','figures');  % Folder path
if ~exist(saveTo,'dir'), mkdir(saveTo); end


%% READ: Real Data 7T

proj   = 'realdata';
tools  = {'vista6','vista4'};
subs   = {'115017','164131','536647'}; 
ses    = '01';
run    = '01';

[compTable,bylabelsums] = pmEllipse_loadExpData(proj,tools,subs,ses,run);
nonfilteredbuylabelsums = bylabelsums;

%% PLOT 6 (A,B,C):Real Data 7T, ONLY VISTA

doSave     = true;
centerPerc = 90;
eccenInGT  = true;
xlims      = [0,10];
ylims      = [0,10];
tools      = {'vista6'}; 
useLabels  = {    'V1d', 'V2d', 'V3d','V1v', 'V2v', 'V3v'};
Cs         = .65*[1 0 0; 0 1 0; 0 0 1;1 0 0; 0 1 0; 0 0 1];
marks      =     [  '*',   '*',   '*',  'o',   'o',   'o',];
lstyle     =     { '-.',  '-.',  '-.',  '-',   '-',   '-'};

% Obtain the same eccentricities as in the simulations
eccenvalues = linspace(1.5,6.5,6);

% useLabels  = {'V1','V2','V3'};
duration   = 300;
tr         = 1;
% Filter results
sMajMIN    = 1;%-inf %1 ; % .5; % 1;
sMinMIN    = 1;%-inf %1 ; % .5; % .75;
sMajMAX    = 3;%inf %5 ; % 1.5 % 3; % 4;
eccenMIN   = 2;%-inf %2 ; % 1 % 2;
eccenMAX   = 6;%inf %6 ; % 6;
minR2      = 0.25;
% How many bins
NeccenBins = 6;
NareaBins  = NeccenBins;
% Close all
tools  = {'vista4','vista6'};
subs   = {'115017','164131','536647'};

bylabelsums = nonfilteredbuylabelsums;
% Apply the restrictions
for nt=1:length(tools)
    tool = tools{nt};
    for nl = 1:length(useLabels)
        lab = useLabels{nl};
        [TH,R]      = cart2pol(bylabelsums.(tool).(lab).x0, bylabelsums.(tool).(lab).y0);
        bylabelsums.(tool).(lab).angle = rad2deg(TH);
        bylabelsums.(tool).(lab).eccen = R;
        bylabelsums.(tool).(lab).area  = pmEllipseArea(2*bylabelsums.(tool).(lab).sMaj, 2*bylabelsums.(tool).(lab).sMin);
        bylabelsums.(tool).(lab) = bylabelsums.(tool).(lab)(...
                                        bylabelsums.(tool).(lab).sMaj  > sMajMIN & ...
                                        bylabelsums.(tool).(lab).sMin  > sMinMIN & ...
                                        bylabelsums.(tool).(lab).sMaj  < sMajMAX & ...
                                        bylabelsums.(tool).(lab).eccen > eccenMIN & ...
                                        bylabelsums.(tool).(lab).eccen < eccenMAX & ...
                                        bylabelsums.(tool).(lab).r2    > minR2,:);
        % Theta can only be [-90,+90]
        % Vista and Afni treat it differently it seems
        % I added 90 deg to AFNI, but I still don't know if I need it or not. Remove it
        theta            = rad2deg(bylabelsums.(tool).(lab).Th - deg2rad(90));
        theta(theta>180) = theta(theta>180) -180;
        theta(theta>90)  = theta(theta>90) -180;
        bylabelsums.(tool).(lab).Th = theta;
        % We can express the theta in the same way, because we only care about the
        % radiality, not the exact angle
        angle            = bylabelsums.(tool).(lab).angle;
        angle(angle>180) = angle(angle>180) - 180;
        angle(angle>90)  = angle(angle>90) - 180;
        bylabelsums.(tool).(lab).angle = angle;
        
        bylabelsums.(tool).(lab).aspect = bylabelsums.(tool).(lab).sMaj  ./ bylabelsums.(tool).(lab).sMin;
        
        
    end
end
% Read the synthetic data as well, this is the eccenv2 dataset, with mid and low
% noise levels, with TR=1 and 2, duration 400, and the ground truth aspect ratio
% limited to 1



% Generated TR=1, Dur=300 data to plot alongside with the real data
fprintf('\n\nLoading synthetic TR=1 300sec data')

sub = 'ellipse'; ses = 'tr1dur300v2';
p = fullfile(pmRootPath,'local',sub,'BIDS','derivatives','prfreport',['sub-' sub],['ses-' ses]);
f = ['sub-' sub '_ses-' ses '-prf_acq-normal_run-01_bold.mat'];
tools = {'synth','vista4','vista6'};

C = load(fullfile(p,f));
dt = C.compTable;
for nt=1:length(tools)
    dt.(tools{nt}).aspect = dt.(tools{nt}).sMaj ./ dt.(tools{nt}).sMin;
    [TH,R] = cart2pol(dt.(tools{nt}).x0, dt.(tools{nt}).y0);
    dt.(tools{nt}).angle = rad2deg(TH);
    dt.(tools{nt}).eccen = R;
    dt.(tools{nt}).area  = pmEllipseArea(2*dt.(tools{nt}).sMaj, 2*dt.(tools{nt}).sMin);
end
% GT aspect ratio is always one
dt   = dt(dt.synth.aspect==1,:);
A1A2 = dt;

A1A2 = A1A2(A1A2.vista6.sMaj >= sMajMIN  & ...
            A1A2.vista6.sMaj <= sMajMAX & ...
            A1A2.vista6.eccen >= eccenMIN & ...
            A1A2.vista6.eccen <= eccenMAX , :); % & ...
         % A1A2.HRFtype=="vista_twogammas", :);
%}
%{
A1A2 = A1A2(A1A2.HRFtype=="vista_twogammas", :);
%}
%{
A1A2 = A1A2(A1A2.HRFtype=="afni_spm", :);
%}

%{
unique(A1A2.synth.sMaj)
unique(A1A2.synth.sMin)
unique(A1A2.synth.eccen)
unique(A1A2.HRFtype)
unique(A1A2.noiseLevel)
%}

disp ('... done with load')

aspect1  = A1A2.vista6.aspect(A1A2.noiseLevel=="low");
B1=prctile(aspect1, [5, 95]);inRange1 = aspect1 >= B1(1) & aspect1 <= B1(2);
aspect1  = aspect1(inRange1);
% sprintf('Low noise: Min aspect ratio for vista 6 is %g and max is %g', min(aspect1),max(aspect1))


aspect2  = A1A2.vista6.aspect(A1A2.noiseLevel=="mid");
B2=prctile(aspect2, [5, 95]);inRange2 = aspect2 >= B2(1) & aspect2 <= B2(2);
aspect2  = aspect2(inRange2);

% Discretize by label, to bin the eccentricities
A1A2.vista6.Y = zeros(size(A1A2.vista6.aspect));
A1A2.vista6.Y(A1A2.noiseLevel=="mid") = discretize(A1A2.vista6.eccen(A1A2.noiseLevel=="mid"),eccenvalues); 
A1A2.vista6.Y(A1A2.noiseLevel=="low") = discretize(A1A2.vista6.eccen(A1A2.noiseLevel=="low"),eccenvalues); 
A1A2low = A1A2(A1A2.noiseLevel=="low", :);
A1A2mid = A1A2(A1A2.noiseLevel=="mid", :);
% Apply percentiles and plot individually
% Create the vectors and then plot all together
vistaMedLowEcc = zeros(1,length(eccenvalues)-1);
vistaMedMidEcc = zeros(1,length(eccenvalues)-1);
for ne=1:(length(eccenvalues)-1)
    aspecclow = A1A2low.vista6.aspect(A1A2low.vista6.Y==ne);
    aspeccmid = A1A2mid.vista6.aspect(A1A2mid.vista6.Y==ne);
    % Median
    vistaMedLowEcc(ne) = median(aspecclow);
    vistaMedMidEcc(ne) = median(aspeccmid);
end

% prepare data
tool = 'vista6';
for nl  = 1:length(useLabels)
    lab = useLabels{nl};
    % Discretize by label, to bin the eccentricities
    bylabelsums.(tool).(lab).Y = discretize(bylabelsums.(tool).(lab).eccen,eccenvalues); 
    % Apply percentiles and plot individually
    % Create the vectors and then plot all together
    aspectmedecc.(lab) = zeros(1,length(eccenvalues)-1);
    aspectminecc.(lab) = zeros(1,length(eccenvalues)-1);
    aspectmaxecc.(lab) = zeros(1,length(eccenvalues)-1);
    
    for ne=1:(length(eccenvalues)-1)
        % ECC - ASPECT
        aspecc = bylabelsums.(tool).(lab).aspect(bylabelsums.(tool).(lab).Y==ne);
        % Median and std
        if isempty(aspecc)
            aspectmedecc.(lab)(ne) = 0;
            aspectminecc.(lab)(ne) = 0;
            aspectmaxecc.(lab)(ne) = 0;
        else
            aspectmedecc.(lab)(ne) = median(aspecc);
            aspectminecc.(lab)(ne) = min(aspecc);  % They use SEM, check
            aspectmaxecc.(lab)(ne) = max(aspecc);
        end
    end
end


% PLOT 6A
fnameBegin = 'Fig6-A_RealData_Ecc&Size';
% Create main plot with the ground truth lines
fnameEnd = sprintf('TR-%i_Dur-%is_C.I.-%i',tr,duration,centerPerc);
fnameRoot = strcat(fnameBegin,'-', fnameEnd);
% disp(fnameRoot) 
kk = mrvNewGraphWin(fnameRoot);
% Fig size is relative to the screen used. This is for laptop at 1900x1200
set(kk,'Position',[0.007 0.62  .5 0.4]);
% ECCEN vs ASPECT
% Plot it
E = eccenvalues;
Emidpoints = mean([E(2:end);E(1:end-1)]);
as = [];
for nl  = 1:length(useLabels)
    lab = useLabels{nl};
    as = [as;plot(Emidpoints,aspectmedecc.(lab),'Color',Cs(nl,:), ...
              ... % marks(nl),'MarkerSize',12, ...
              'LineStyle',lstyle{nl},'LineWidth',2)];hold on
    % a  = plot([Emidpoints;Emidpoints] ,...
    %           [aspectminecc  ; aspectmaxecc], ...
    %           'Color','k','LineStyle','-','LineWidth',3);  % 0.75*[0 1 0]
end

lowplot = plot(Emidpoints, vistaMedLowEcc,'k--','LineWidth',3);
midplot = plot(Emidpoints, vistaMedMidEcc,'k:','LineWidth',3);

legend([useLabels,'Synth Low Noise','Synth Mid Noise'], 'Location','eastoutside')
title(strrep(sprintf('%s_TR-%i_Dur-%is_C.I.-%i',...
    tool,tr,duration,centerPerc),'_','\_'))
grid on
xlabel('Eccentricity (deg)')
ylabel('pRF aspect ratio')
xlim([Emidpoints(1)-.2,Emidpoints(end)+.2]);
ylim([1,3]);%ylim([1,2]);
xticks(Emidpoints);
set(gca, 'FontSize', 16);

fname = fullfile(saveTo, strcat(fnameRoot,['.' ext]));
saveas(gcf,fname,ext);
fprintf('\nSaved %s\n', fname)

% PLOT S7
aspects = [];
fnameBegin = 'FigS7_RealData_AspectHistogram_Separated';
% Create main plot with the ground truth lines
fnameEnd = sprintf('TR-%i_Dur-%is_C.I.-%i',tr,duration,centerPerc);
fnameRoot = strcat(fnameBegin,'-', fnameEnd);
% disp(fnameRoot) 
kk = mrvNewGraphWin(fnameRoot);
% Fig size is relative to the screen used. This is for laptop at 1900x1200
set(kk,'Position',[0.007 0.62  .5  .5]);
% SET UP DATA
% Here is the aspect we want to plot
% bylabelsums.(tool).(lab).aspect
tool = 'vista6';
for nl  = 1:length(useLabels)
    subplot(2,3,nl)
    lab = useLabels{nl};
    % Obtain aspect
    aspectvista = bylabelsums.(tool).(lab).aspect;
    aspectvista = aspectvista(aspectvista < 5);
    aspects     = [aspects;aspectvista];
    
    % Plot it
    h = histogram(aspectvista,20,'Normalization','probability');
    set(h,'LineWidth',2,'EdgeColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',1,'FaceColor',[.5 .5 .5]);hold on
    plot(median(aspectvista)*[1,1],[0,max(h.Values)],'r-')    
    
    % Add the low noise and mid noise lines now

    
    xlim([1,5])
    ylim([0,.2])%ylim([0,0.35])
    % legend({lab,'median','Synth Low Noise','Synth Mid Noise'});
    title(lab)
    xlabel('Aspect Ratio')
end
fname = fullfile(saveTo, strcat(fnameRoot,['.' ext]));
saveas(gcf,fname,ext);
fprintf('\nSaved %s\n', fname)

% PLOT 6B
fnameBegin = 'Fig6-B_RealData_AspectHistogram_Combined';
% Create main plot with the ground truth lines
fnameEnd = sprintf('TR-%i_Dur-%is_C.I.-%i',tr,duration,centerPerc);
fnameRoot = strcat(fnameBegin,'-', fnameEnd);
% disp(fnameRoot) 
kk = mrvNewGraphWin(fnameRoot);
% Fig size is relative to the screen used. This is for laptop at 1900x1200
set(kk,'Position',[0.007 0.62  .5  .5]);

binWidth = 0.05;

aspect2  = aspect2(aspect2 < 4);
% hmid = histogram(aspect2,'DisplayStyle','stairs','BinWidth',h.BinWidth,'Normalization','probability');
hmid = histogram(aspect2,'BinWidth',binWidth,'Normalization','probability');
% set(hmid,'LineWidth',2,'EdgeColor',[.5 .5 .5 ],'LineStyle','-','EdgeAlpha',.5,'FaceAlpha',.5,'FaceColor',[.5 .5 .5 ]);
set(hmid,'LineWidth',2,'EdgeColor','k','FaceAlpha',1,'FaceColor','k');hold on
blow = plot(median(aspect2)*[1,1],[0,.1],'LineWidth',2,'Color','k','LineStyle','--'); 


h = histogram(aspects,35,'Normalization','probability','BinWidth',binWidth);hold on
% set(h,'LineWidth',2,'EdgeColor','k','FaceAlpha',1,'FaceColor','k');
set(h,'LineWidth',2,'EdgeColor',[.5 .5 .5 ],'LineStyle','-','EdgeAlpha',0,'FaceAlpha',.75,'FaceColor',[.5 .5 .5 ]);
a = plot(median(aspects)*[1,1],[0,.1],'Color',[.5 .5 .5 ],'LineStyle','--');

tool = 'vista6';
% Add the low noise and mid noise lines now
%  aspect1  = aspect1(aspect1 < 4);
% hlow = histogram(aspect1,'DisplayStyle','stairs','BinWidth',h.BinWidth,'Normalization','probability');
% hlow = histogram(aspect1,'BinWidth',h.BinWidth,'Normalization','probability');
% set(hlow,'LineWidth',2,'EdgeColor',[1 .5 .5 ],'LineStyle','-','EdgeAlpha',0,'FaceAlpha',.5,'FaceColor',[1 .5 .5 ]);
% alow = plot(median(aspect1)*[1,1],[0,.1],'LineWidth',2,'Color',[1 .5 .5 ],'LineStyle','-'); 

xlim([1,5]);

% legend([h;a;hlow;hmid],{'Experimental Data','Median of Exp. Data','Synth Low Noise','Synth Mid Noise'});

legend([h;a;hmid;blow],{'Experimental Data','Median of Exp. Data','Synth Mid Noise','Median of Synth. Data'});
fname = fullfile(saveTo, strcat(fnameRoot,['.' ext]));
saveas(gcf,fname,ext);
fprintf('\nSaved %s\n', fname)

%% PLOT S8  % THETA vs ANGLE
% prepare data
tool = 'vista6';
thetas = [];
angles = [];
for nl  = 1:length(useLabels)
    lab = useLabels{nl};
    thetas = [thetas;bylabelsums.(tool).(lab).Th];
    angles = [angles;bylabelsums.(tool).(lab).angle];
end

fnameBegin = 'FigS8_RealData_AnglevsTheta';
% Create main plot with the ground truth lines
fnameEnd = sprintf('TR-%i_Dur-%is_C.I.-%i',tr,duration,centerPerc);
fnameRoot = strcat(fnameBegin,'-', fnameEnd);
% disp(fnameRoot) 
kk = mrvNewGraphWin(fnameRoot);
% Fig size is relative to the screen used. This is for laptop at 1900x1200
set(kk,'Position',[0.007 0.62  1  0.5]);
subplot(1,2,1)
% PLOT 2b
h = histogram(theta-angle,25,'Normalization','probability');
set(h,'LineWidth',2,'EdgeColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',1,'FaceColor',[.5 .5 .5]);hold on
xlabel('Theta - Angle')

subplot(1,2,2)
plot(thetas, angles,'ko');xlabel('\Theta (deg)');ylabel('Angle (deg)');hold on
identityLine(gca);
xlim([-90,90]);
ylim([-90,90]);
xticks(-90:15:90);
yticks(-90:15:90);
fname = fullfile(saveTo, strcat(fnameRoot,['.' ext]));
saveas(gcf,fname,ext);
fprintf('\nSaved %s\n', fname)


%% PLOT 6C: Compare r2 values vista4/vista6
useLabels = {'V1','V2','V3'};   
fnameRoot = 'Fig6-C_RealData_R2diff_histogram_filteredAsTheRest';

% Create intermediate variables
% R2 in perc
v6 = 100*compTable.vista6.r2;
v4 = 100*compTable.vista4.r2;
% Eccentricity values for filtering
[~,R6] = cart2pol(compTable.vista6.x0, compTable.vista6.y0);
[~,R4] = cart2pol(compTable.vista4.x0, compTable.vista4.y0);
compTable.vista6.eccen = R6;
compTable.vista4.eccen = R4;


% Filter by variance explained
v6ind = (v6 > 100*minR2) & ...
        (compTable.vista6.sMaj  > sMajMIN)  & (compTable.vista6.sMaj < sMajMAX) & ...
        (compTable.vista6.eccen > eccenMIN) & (compTable.vista6.eccen < eccenMAX);
v4ind = (v4 > 100*minR2) & ...
        (compTable.vista4.sMaj  > sMajMIN)  & (compTable.vista4.sMaj < sMajMAX) & ...
        (compTable.vista4.eccen > eccenMIN) & (compTable.vista4.eccen < eccenMAX);
vind  = v6ind & v4ind;
% Create filtered version
v6f   = v6(vind);
v4f   = v4(vind);

v6m   = median(v6);
v4m   = median(v4);
v6fm  = median(v6f);
v4fm  = median(v4f);

v64   = 100 * (v6m - v4m)/v4m;
v64f  = 100 * (v6fm - v4fm)/v4fm;


kk = mrvNewGraphWin('R2 vista4/vista6');
set(kk,'Position',[0.007 0.62  0.5 0.5]);
h = histogram(v6f - v4f,'Normalization','probability');  % 'DisplayStyle','stairs'
set(h,'LineWidth',2,'EdgeColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',1,'FaceColor',[.5 .5 .5]);hold on
a = plot(median(v6f - v4f)*[1,1],[0,max(h.Values)],'r-');
xlabel('Delta R2 (Elliptical - Circular; in %)')
legend(a,'Median of the difference')
xlim([-2,5])
set(gca,'FontSize',20)

% Print the variance explained for Insub
%{
kk = mrvNewGraphWin('R2 vista6 and vista4');
set(kk,'Position',[0.007 0.62  0.5 0.5]);
h6 = histogram(v6f,'Normalization','probability');  % 'DisplayStyle','stairs'
set(h6,'LineWidth',2,'EdgeColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',1,'FaceColor','k');hold on
h4 = histogram(v4f,'Normalization','probability');  % 'DisplayStyle','stairs'
set(h4,'LineWidth',2,'EdgeColor',[.5 .5 .5],'EdgeAlpha',0,'FaceAlpha',.65,'FaceColor',[.5 .5 .5]);
xlabel('R2 (%)')
legend('Elliptical Fit','Circular fit')
xlim([20,100])
set(gca,'FontSize',20)
%}


% title(sprintf('Elliptical median variance explained is %1.2g%% larger than Circular',v64f))
fname = fullfile(saveTo, strcat(fnameRoot,['.' ext]));
saveas(gcf,fname,ext);
fprintf('\nSaved %s\n', fname)


%% STATS
%{
% Obtain stats for 6B for now


synthAspect = aspect2;
vistaAspect = aspects;
length(vistaAspect)
length(synthAspect)

fprintf('\nASPECT RATIO GROUND TRUTH OF SYNTH = 1')
fprintf('\npRF Aspect Ratio')
[H,P,CI,STATS] = ttest2(synthAspect,vistaAspect);
fprintf('[Figure 6B: paired t-test SYNTHvsVISTA] t: %.2g, p: %.2g\n',STATS.tstat,P)
%}







end

