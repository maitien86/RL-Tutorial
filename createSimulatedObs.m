%   Generate obs
%%
global Op;
global Obs;
dest = Obs(1,1);
globalVar;

disp('Observation generating ....')
Op.n = 2;
isLinkSizeInclusive = false;
isFixedUturn = false;
x0 = [-2.0, -1.0, -1.0, -20.0, -0.20 ]';
% ODpairs = Obs(:,1:2);
% For tutorial
ODpairs = [27,1;27,2];
ODpairs = [dest,1;dest,2];
x0 = [-2.0;-0.1;0;0];
%------------------------------
nbobsOD = 500;
filename = './ExampleTutorial/SyntheticObs.txt';
filename = './ExampleTutorial_addedLinks/SyntheticObs.txt';
%filename = './ExampleTutorial_addedLinks/ChoiceSets.txt';

generateObs(filename, x0, ODpairs, nbobsOD);
