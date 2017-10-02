....
%   Link-based network route choice model with unrestricted choice set
%   Optmization algorithm
%   Chaire CN - DIRO - Université de Montréal
%   MAIN PROGRAM
%   ---------------------------------------------------
%%
Credits;

% declare global variables
globalVar; 

% set the link size attribute
isLinkSizeInclusive = false;
saveResults = true;

% load network attributes and observations
loadData;

% set the optimization parameters
Op = Op_structure;
initialize_optimization_structure();

Gradient = zeros(nbobs,Op.n);

%---------------------------
%Starting optimization
tic ;
disp('Start Optimizing ....')
[Op.value, Op.grad ] = LL(Op.x);
PrintOut(Op);
% print result to string text
header = [sprintf('%s \n',file_observations) Op.Optim_Method];
header = [header sprintf('\nNumber of observations = %d \n', nbobs)];
header = [header sprintf('Hessian approx methods = %s \n', OptimizeConstant.getHessianApprox(Op.Hessian_approx))];
resultsTXT = header;
%------------------------------------------------
while (true)    
  Op.k = Op.k + 1;
  if strcmp(Op.Optim_Method,OptimizeConstant.LINE_SEARCH_METHOD);
    ok = line_search_iterate();
    if ok == true
        PrintOut(Op);
    else
        disp(' Unsuccessful process ...')
        break;
    end
  else
    ok = btr_interate();
    PrintOut(Op);
  end
  [isStop, Stoppingtype, isSuccess] = CheckStopping(Op);  
  %----------------------------------------
  % Check stopping criteria
  if isStop == true
      isSuccess
      fprintf('The algorithm stops, due to %s', Stoppingtype);
      resultsTXT = [resultsTXT sprintf('The algorithm stops, due to %s \n', Stoppingtype)];
      break;
  end
end

% Compute variance-covariance matrix
PrintOut(Op);
disp(' Calculating VAR-COV ...');
global Stdev;
Stdev = zeros(1,Op.n);
getCov;

%   Finishing ...
ElapsedTime = toc
resultsTXT = [resultsTXT sprintf('\n Number of function evaluation %d \n', Op.nFev)];
resultsTXT = [resultsTXT sprintf('\n Estimated time %d \n', ElapsedTime)];

if saveResults == true
    SaveResults(Stoppingtype, ElapsedTime);
end
