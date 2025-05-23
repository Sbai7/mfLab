function Bud = zonebudget(B,zoneArray,zones)
%ZONEBUDGET compute water budget for set of zones
%
% USAGE:
%    Bud = zonebudget(B,zoneArray,zones);
%
%    Bud = zonebudget(B [,zoneArray[,zones]])
%    Bud = zonebudget(B)                  % print budget over entire model
% zonebudget(B,zoneArray)        % print for all zones in zonearray
% zonebudget(B,zoneArray,zones)  % print for specific set of zones
% B is budget struct generated by readBud, see help readBud.
% zoneArray is a 3D array (NROW,NCOL,NLAY) with zone numbers
% zones is the set of zones for which the budget is desired
% zones<1 is not printed
%
% TO 091129 100830
%
% see also readBud
%
% Copyright 2009 2010 Theo Olsthoorn, TU-Delft and Waternet, without any warranty
% under free software foundation GNU license version 3 or later

switch nargin
    case 1,
        zones=1;
        fprintf('\n============================================\n');
        fprintf('zoneBudget will be computed for entire model.');
        ZA= true(size(B(1).term{1}));
    case 2,
        zones=unique(zoneArray(zoneArray>0));
        fprintf('\n============================================\n');
        fprintf('zoneBudget will be computed for zones ');
        fprintf(' %d',unique(zoneArray(zoneArray(:)>0)));
        fprintf(' that are in the zoneArray.\n');
        ZA= (zoneArray>0);
    case 3
        zones=unique(zones(:));
        ZA= false(size(B(1).term{1}));
        fprintf('\n============================================\n');
        fprintf('zoneBudget will be computed for zones: ');
        for i=1:length(zones)
            ZA= ZA | (zoneArray==zones(i));
            fprintf(' %d',zones(i));
        end
        fprintf('\n');
    otherwise
        error('Zonebudget: wrong number of arguments, see help zonebudget\n');
end

for i=1:length(B)
    Qtoti=0; Qtoto=0;
    what=['ZONE ',sprintf(' %d',zones)];

    fprintf('\nBudget [consistent model units] for period=%d, itsp=%d:\n\n',B(i).period,B(i).tstp);
    fprintf('BUDGET FOR %-20s  -----IN-----  ----OUT-----\n',upper(what));

    B(i).label = rmSpace(B(i).label);
    Bud(numel(B),1).label= B(i).label; %#ok
    
    for iterm=1:length(B(i).label)
        Lbl=B(i).label{iterm};
        if strmatchi('FLOWFRONTFACE',B(i).label(iterm))
            QFF=diff(ZA,1,1).*B(i).term{iterm}(1:end-1,:,:);
            QFFi= sum(QFF(QFF>0));  Qtoti=Qtoti+QFFi;
            QFFo=-sum(QFF(QFF<0));  Qtoto=Qtoto+QFFo;
            fprintf('total for %20s = %12.2f  %12.2f\n',Lbl,QFFi,QFFo);
            
            Bud(i).In .QFF = QFFi;
            Bud(i).Out.QFF = QFFo;

        elseif strmatchi('FLOWRIGHTFACE',B(i).label(iterm))
            QRF=diff(ZA,1,2).*B(i).term{iterm}(:,1:end-1,:);
            QRFi= sum(QRF(QRF>0));  Qtoti=Qtoti+QRFi;
            QRFo=-sum(QRF(QRF<0));  Qtoto=Qtoto+QRFo;
            fprintf('total for %20s = %12.2f  %12.2f\n',Lbl,QRFi,QRFo);
            
            Bud(i).In .QRF = QRFi;
            Bud(i).Out.QRF = QRFo;

        elseif strmatchi('FLOWLOWERFACE',B(i).label(iterm))
            QLF=diff(ZA,1,3).*B(i).term{iterm}(:,:,1:end-1);
            QLFi= sum(QLF(QLF>0));  Qtoti=Qtoti+QLFi;
            QLFo=-sum(QLF(QLF<0));  Qtoto=Qtoto+QLFo;
            fprintf('total for %20s = %12.2f  %12.2f\n',Lbl,QLFi,QLFo);
            
            Bud(i).In .QLF = QLFi;
            Bud(i).Out.QLF = QLFo;

        else
            Q=sum(B(i).term{iterm}(ZA>0));
            Qi= sum(Q(Q>0));  Qtoti=Qtoti+Qi;
            Qo=-sum(Q(Q<0));  Qtoto=Qtoto+Qo;
            fprintf('total for %20s = %12.2f  %12.2f\n',Lbl,Qi,Qo);
            
            Bud(i).In.( Lbl) = Qi;
            Bud(i).Out.(Lbl) = Qo;

        end
    end
    fprintf('          %20s   ------------  ------------\n',' ');
    fprintf('total for %20s = %12.2f  %12.2f\n',what,Qtoti,Qtoto);
    fprintf('total net %20s = %12.2f  \n',what,Qtoti-Qtoto);
end

function labels = rmSpace(labels)

% remove whitespace from labels
for i=1:numel(labels)
    labels{i}(labels{i}==' ')=[];
end
