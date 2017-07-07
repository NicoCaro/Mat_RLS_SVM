function f=J_D(Y,varargin)
% Funcion objetivo del problema de optimizacion
% f=J_D(Y,varagrin)
% input:
% Y=[y_p alpha bias pm]
%
% Opciones extra(EO):
%
% EO={N,p,reg_alpha,y0}
% N : tamaño training set
% p : orden del modelo
% reg_alpha : parametro de regularizacion 
% y0 : conjunto de respuestas y_i de tamaño N.
%
% Valores por defecto:
% EO={100,5,100,zeros(l00,1)};
% 
% <Author: Nicolas Caro>
%
% See also FMINCON , M_TRAIN.
EO=150;
h=zeros(EO,1);
EO={EO,5,100,h};

% EO(1)=N;
% EO(2)=p;
% EO(3)=reg_alpha;
% EO(4)=y0;

if abs(nargin)>1
   for i=1:length(varargin) 
   EO(i)=varargin(i);
   end
end
N=cell2mat(EO(1));
p=cell2mat(EO(2));

f=0.5*(norm(cell2mat(EO(4))-Y(1:N),2)^2) + ...
  cell2mat(EO(3))*norm(Y((N+1):(2*N-p+1)),1);
