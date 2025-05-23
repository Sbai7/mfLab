% Groundwater whirls (Hemker and Bakker (2006)), WRR
%
% TO DO: it works great but doesn't really whirl yet (figure out later)
%
% TO 0120401 130323

clear variables; close all;

global basename

basename='Whirls'; % model basename

%%
peff  = 0.35;
gradx = -1/1000;
grady = -1/1000;
phi0  = 100; % large enough to keep model saturated
k     = 1;

%%
dx = 10;
dy = 10;
dz = 1;

xGr = 0:dx:1000;  % xGrid
yGr = 0:dy:1000;  % yGrid
zGr = 0:-dz:-10;   % zGrid

gr = gridObj(xGr,yGr,zGr);

%%
IBOUND = gr.const(1);

Nx2 = round(gr.Nx/2);
Ny2 = round(gr.Ny/2);

IBOUND(Ny2+1:end,1,:)= -1; IBOUND(1:Ny2,end,:) = -1;
IBOUND(1,Nx2+1:end,:)= -1; IBOUND(end,1:Nx2,:) = -1;

iM     = round(gr.Nlay/2);

ani    = 2;

HK     = gr.const(k); HK(:,:,1:iM) = k * ani; HK(:,:,iM+1:end) = k / ani;
CHANI  = ones(gr.Nlay,1); CHANI(1:iM) = 1/ani^2; CHANI(iM+1:end) = ani^2;

VK     = gr.const(k);

PEFF   = gr.const(peff); % effective porosity

%%
STRTHD = bsxfun(@times, ones(1,1,gr.Nlay), bsxfun(@plus, gr.xm * gradx, gr.ym * grady));

%% Modpath info pertaining to this simulation

%%
% Specify the number and placement of the starting points with each cell.
% in this case cells are in top of all rows, column 5 layer 1.

zoneArray = false(gr.size);
zoneArray(1:5:end,1,:) = true;
zoneArray(end,1:5:end,:) = true;
zoneArray = zoneArray & IBOUND<0;

zoneVals           = {true,'name',basename,'placement',1,'LineSpec','bo'};

% Generate the mpath_partileGroupObj from which MODPATH can generate the
% staring locations of the particles.
pGrp = mpath_particleGroupObj(gr,zoneArray,zoneVals);

%% Particles
% The definition above will allow to generate input for MODPATH from which
% MODPATH can generate the required starting points. So mfLab does not need
% to do that. To allow plotting the particles within mfLab, they can also
% be generated by mfLab using the method getParticles. This methods addes
% the particles to the mpath_particleGroupObj
pGrp   = pGrp.getParticles(gr);

%% Show particles in 3D

figure; hold on; view(3); xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');

gr.plotMesh('faceAlpha',0.15);

pGrp.plot(); title('Particles starting points');

%% You can turn the graphic by hand to better view the particles


save underneath gradx grady iM