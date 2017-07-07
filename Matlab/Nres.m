function [c,ceq]=Nres(Y,varargin)
% Generaion de las restriccion no lineales de igualdad
% en el problema de optimizacion
%
% [c,ceq]=Nres(Y,EO)
% Y : input array containing al variables to be minimized.
% 
% Opciones Extra (EO): 
%
% EO={N,p,reg_alpha,y0}
%
% N : Tamaño del conjunto de entrenamiento
% p : oderen del modelo
% reg_alpha : parametro de regularizacion L-1
% par : hiperparametros del kernel.
% kernel_name: kernel a usar
% y0 : vector de observacion y_i de tamaño N.
%
% Ejemplo, valores defaul
%
% EO={100,5,100,1,'RBF',zeros(100,1)};
%
% ouput
% c   : [] no hay restricciones de desigualdad para este metodo.
% ceq : REstricciones de igualdad.
%
%<Author:Nicolas Caro>
%
% See alse FMINCON M_TRAIN

EO={100,5,100,1,'RBF',zeros(100,1)};

% EO(1)=N;
% EO(2)=p;
% EO(3)=reg_alpha;
% EO(4)=par;
% EO(5)=kerel_name;
% EO(6)=y0;

if abs(nargin)>1
   for i=1:length(varargin) 
   EO(i)=varargin(i);
   end
end

N=cell2mat(EO(1));
p=cell2mat(EO(2));
bias=Y(2*N-p+2);
y_p=Y(1:N);
pars=cell2mat(EO(4));
alpha=Y((N+1):(2*N-p+1));
kernel_name=cell2mat(EO(5));
y0=cell2mat(EO(6));

% no hay restricciones de desigualdad
c=[];

% Generacion de retriccion de igualadad.
    
ceq=zeros(N,1);
ceq(1:p)=y0(1:p);

for k=(p+1):N
ceq(k)=app(kernel(kernel_name),pars,y_p,y_p,k,alpha,bias,N,p)-y_p(k);
end
