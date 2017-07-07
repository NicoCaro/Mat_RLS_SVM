function f=kernel(kernel_name)
% diccionario de kernels
% fx=kernel(kernel_name)
%
% Input:
% kernel_name : Nombre del kernel a usar.(string)
%
% Output:
% 'f'      -> function handle que contiene el kernel con 
%             el que se trabajara
%
% <Author: Nicolas Caro>
%
% See also M_TRAIN APP RLS_SVM.
%% Kernel List

% RBF kernel

if strcmp(kernel_name,'RBF') 
       
   %kernel declaration 
   f=@(y_l,y_k,p1) exp(-p1*(norm(y_l-y_k,2))^2);
end

%dot kernel

if strcmp(kernel_name,'dot')
   %kernel declaration 
   f=@(y_l,y_k,p1) y_l'*y_k/(norm(y_l,2)*norm(y_k,2));
end
