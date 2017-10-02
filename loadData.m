%   Load route choice data

%% Read files
disp('Loading data ...')

global incidenceFull;
global Atts;
global Obs;
global nbobs;
global LSatt;
global isLinkSizeInclusive;

file_linkAttributes='./Input/Example1/LinkAttributes.txt';
file_incidence='./Input/Example1/IncidenceMatrix.txt';
file_observations='./Input/Example1/Observations.txt'

% get attributes and incidence data from files
linkAttributes = csvread(file_linkAttributes,1,0);
incidenceFull = spconvert(load(file_incidence));
Obs = spconvert(load(file_observations));
nbobs = length(Obs(:,1));

% number of network links = nbNetworkStates
% number of netowrk + dummy links = nbTotalStates
[nbNetworkStates,nbTotalStates]=size(incidenceFull); 

%% Define link attributes 

% choose appropriate columns from attributes data matrix
LinkLength=linkAttributes(:,4);
Trafficsignal=linkAttributes(:,5);

%% Define link pairs attributes

% extend attribute value to absorbing links as 0
% attribute value must always be 0 for absorbing links!
LinkLength(nbTotalStates) = 0;
Trafficsignal(nbTotalStates) = 0;
icd=incidenceFull;
icd(:,nbNetworkStates:nbTotalStates) = 0;

% create link pair matrix x(a|k) for each attribute
icdLength = incidenceFull * spdiags(LinkLength,0,nbTotalStates,nbTotalStates);
icdTrafficSignal = incidenceFull * spdiags(Trafficsignal,0,nbTotalStates,nbTotalStates);

% put everything in Atts variables
Atts  = objArray(1);
Atts(1).value = icdLength; %link length
Atts(2).value = icdTrafficSignal; %traffic signal dummy
Atts(3).value = icd; %link dummy

%% Load link size attribute if needed

if isLinkSizeInclusive == true
    %either compute the link size attribute
%     ExpV_is_ok = getLinkSizeAtt();
%     if ExpV_is_ok ==0
%         disp('Warning: failed to compute link size attribute')
%     end
    %or load an already computed and saved link size attribute
    load('./Input/Example1/LSatt.mat')
end