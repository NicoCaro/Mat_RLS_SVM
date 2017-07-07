function f=defaults(kernel_name)
% Diccionario de valores defaul para cada kernel
% par=defautls(kernel)
%
%<Author: Nicolas Caro>
%
% See also M_TRAIN APP RLS_SVM.
%% Kernel List

% RBF kernel

if strcmp(kernel_name,'RBF') 
   %default value
   
   f=1;
   
end

% Dot kernel

if  strcmp(kernel_name,'dot') 

   display('No parameters are needed')
   f=[];
   
end

