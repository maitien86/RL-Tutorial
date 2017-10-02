function [] = SaveResults( Stoppingtype, ElapsedTime )
%Save results to file
%   Stoppingtype : reason the algorithm stopped
%   ElapsedTime : total time needed by algorithm

global resultsTXT; 
global Op;
global Stdev;

formatout1='yymmdd';
formatout2='hhMM';
date1=datestr(now,formatout1);
date2=datestr(now,formatout2);
FolderString=horzcat('./Results/',date1);
if ~exist(FolderString, 'dir')
  % If the folder does not exist, this creates it
  mkdir(FolderString);
end
FileString=horzcat('./Results/',date1,'/',date2,'.txt');
FileID=fopen(FileString,'w');
fprintf(FileID,'The algorithm stops, due to %s \n', Stoppingtype);
fprintf(FileID,'The attributes are \n');         
fprintf(FileID,'[Iteration]: %d\n', Op.k);
fprintf(FileID,'     LL = %f\n', Op.value);
fprintf(FileID,'     x = \n');
fprintf(FileID,'         %i\n', Op.x');
fprintf(FileID,'     norm of step = %f\n', norm(Op.step));
fprintf(FileID,'     radius = %f\n', Op.delta);  
fprintf(FileID,'     Norm of grad = %f\n', norm(Op.grad));
relatice_grad = relative_gradient(Op.value, Op.x, Op.grad, 1.0);
fprintf(FileID,'     Norm of relative gradient = %f\n', relatice_grad);
fprintf(FileID,'     Number of function evaluation = %f\n', Op.nFev);

fprintf(FileID,'\n Number of function evaluation %d \n', Op.nFev);
fprintf(FileID,'\n Estimated time %d \n', ElapsedTime);
fprintf(FileID,'Estimated : %5.8f \n',Op.x);
fprintf(FileID,'Standard deviation : %5.8f \n', Stdev);
fprintf(FileID,resultsTXT);
fclose(FileID);

end

