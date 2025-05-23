function  adv=readADV(basename)
%READADV reads basic advection transport package file
%
% Example:
%     adv=readADV(basename,adv)
%
% TO 0706030 081227

% Copyright 2007-2013 Theo Olsthoorn, TU-Delft and Waternet, without any warranty
% under free software foundation GNU license version 3 or later


% handle incompatibility with UD2REL (MT3DMS p97).
adv.unit=100;  


fid=fopen(basename,'rt');
if fid<0
    fid=fopen([basename,'.ADV'],'rt');
end

%% B0 HEADING not allowed in ADV file
fprintf(    '%s\n',['# MT3DMS readADV ' datestr(now)]);


%B1 MIXELM PERCEL MXPART NADVFD (I10 F10.0 I10 I100
%   MIXELM adv solution option flag
%   PERCEL courant number, use 1
%   MXPART max total number of moving particles
%   NADVFD weighting scheme flag
adv.MIXELM=fscanf(fid,'%d',1);
adv.PERCEL=fscanf(fid,'%f',1);
adv.MXPART=fscanf(fid,'%d',1);
adv.NADVFD=fscanf(fid,'%d',1);
fgets(fid);

%B2 if MIXELM=1,2 or 3: ITRACK WD (I10 F10.0)
%   ITRACK particle tracking algorithm flag (p115)
%   WD     concentration weighting factor   (0.5 generally adequate)
if adv.MIXELM==1 || adv.MIXELM==2 || adv.MIXELM==3
    adv.ITRACK = fscanf(fid,'%d',1);
    adv.WD     = fscanf(fid,'%f',1);
    fgets(fid);
end

%B3 if MIXELM=1 or 3
%   DCEPS NPLANE NPL NPH NPMIN NPMAX (F10.0 5I10)
%   DCEPS  small relatie cell conce gradient
%   NPLANE random of fixed particle placement pattern flag 0=random
%   NPL initial # of particles in DCEPS cells, use 0
%   NPH initial # of particles in all other cells (16 in 2D to 32 in 3D adequate)
%   NPMIN min # of particles per cell use 2 (see p116) 
%   NPMAX max # of particles per cell use 2*NPH (see p116)
if adv.MIXELM==1 || adv.MIXELM==3
    adv.DCEPS  = fscanf(fid,'%d',1);
    adv.NPLANE = fscanf(fid,'%d',1);
    adv.NPL    = fscanf(fid,'%d',1);
    adv.NPH    = fscanf(fid,'%d',1);
    adv.NPMIN  = fscanf(fid,'%d',1);
    adv.NPMAX  = fscanf(fid,'%d',1);
    fgets(fid);
end

%B4 (if MIXELM=2 or 3) INTERP NLSINK NPSINK (3I10)
if adv.MIXELM==2 || adv.MIXELM==3
    adv.INTERP=1;            %   INTERP conc interpolation method flag, currently must be 1
    adv.NLSINK=adv.NPLANE;   %   NLSINK random or fixec particle placement flag in MMOC scheme use NLPLANE
    adv.NPSINK=adv.NPH;      %   NPSINK # particles to approximate sink cells in MMOC, use NPH
    adv.INTERP = fscanf(fid,'%d',1);
    adv.NLSINK = fscanf(fid,'%d',1);
    adv.NPSINK = fscanf(fid,'%d',1);
    fgets(fid);
end

%B5 (if MIXELM=3) DCHMOC (F10.0)
% DCHMOC crit rel conc grad controlling selective use of MOC or MMOC in HMOC
if adv.MIXELM==3
    adv.DCHMOC=fscanf(fid,'%f',1);
end

fclose(fid);
