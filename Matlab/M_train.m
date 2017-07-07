function [mod, out]=M_train(y,p,kernel_name,reg_alpha,varargin)
% M_train Recurrent Least Squares - Support Vector Machines training script
% 
% M_train(y,p,kernel_name,reg_alpha,varargin)
%
% y: vector de entrenamiento. (array double) 
% p: orden del modelo.[p<N=length(y)](int)
% kernel_name: nombre del kernel.['dot' or 'RBF'](str)
% reg_alpha  : Valor del parametro de regularizacion
%                               
% Opciones extras del modelo (EO):
% Puede entregarse un valor vacio para este tipo de opciones.
%
% EO={par,algorithm,Mfun,tol,normal,noise,seed,mu,sig,UseParallel,...
%     metric_conf,thr,it_max}
%
% par: valor especifico del hiperparametro para el kernel . para 'dot' par=[]. 
%                                                           para 'RBF' par double.
% 
% alg: Algoritmo de optimizacion usado por el solver.
% Mfun: Limite de evaluaciones de la funcion objetivo.
% tol: Tolerancia en el algoritmo de optimizacion.
% normal: true -> normalizacion por desvicion estandar y media.
%         false-> normalizacion en [0,1] "min max"

% noise: agrega ruido al punto inicial (Y,alpha) (bool)
% seed: random seed
% mu,sig: promedio y desviacion standard del ruido,
% UseParallel: uso de computo paralelo (bool)
% metric_conf: metrica en entrenamiento.[SMAPE IA](str)
% thr        : valor umbral en el proceso de validacion intermetrica (double)
% it_max     : canidad de evaluaciones en el proceso de validacion intermetrica(int)
%
% input example: (valores por defecto)
%
% EO={defaults(kernel_name),'interior-point',3000,10^(-3),false,true,...
%     1,0,0.1,true,'SMAPE',15,5};
%
% Output:
% El output de esta funcion es una estructura con los siguientes campos:
%
% mod.kernel    : kernel.(str)
% mod.yk        : vector y_gorro ajustado.(array double)
% mod.alpha     : pesos alpha del modelo N-p+1.(array souble)
% mod.bias      : bias .(double)
% mod.time_tr   : tiempo de entrenamiento.[seconds](double)
% mod.N         : tamaño del training set.(int)
% mod.p         : orden del modelo.[p<N](int)
% mod.reg_alpha : valor del parametro de regularizacion.
% mod.y_input   : vector de y normalizado, usado en el entrenamiento.
% 
% out es la estructura "out" entregada por fmincon.
%
% <Author: Nicolas Caro>
%
% See also FMINCON,APP,KERNEL,RLS_SVM,DEFAULTS


%%%%%%%%%%% ATM time series prediction using RLS-SVM %%%%%%%%%%%%
% Esta funcion fue hecha para la base de datos ATM's

%% Preliminares
%Orden del modelo p y N

N=length(y);

% Opciones adicionales

%Valores por defecto

EO={defaults(kernel_name),'interior-point',3000,10^(-3),false,true,...
    1,0,0.1,true,'SMAPE',15,5};

%EO(1)<-par
%EO(2)<-alg  
%EO(3)<-Mfun 
%EO(4)<-tol 
%EO(5)<-normal
%EO(6)<-noise 
%EO(7)<-seed 
%EO(8)<-mu 
%EO(9)<-sig 
%EO(10)<-UseParallel
%EO(11<- metric_conf
%EO(12)<-thr
%EO(13)<-it_max

% valores personalizados

if abs(nargin)>4
    for i=1:length(varargin)
    EO(i)=varargin(i);
    end
end

rng(cell2mat(EO(7)));
pars=cell2mat(EO(1));

mod.y_original=y;

if cell2mat(EO(5))
   y=(y-mean(y))/std(y);
else
   y=(y-min(y))/(max(y)-min(y));
end

%% Problema de optimizacion

% puntos iniciales

% se añade ruido gaussiano al punto inicial

if cell2mat(EO(6)) 
y_p = y+[zeros(p,1); normrnd(cell2mat(EO(8)),cell2mat(EO(9)),N-p,1)];
alpha=normrnd(cell2mat(EO(8)),cell2mat(EO(9)),N-p+1,1);
else
y_p=y;
alpha=zeros(N-p+1,1);
end
bias=0;

% dim = 2*N-p+2 (del punto inicial)

Y_0=[y_p; alpha ; bias];

% restricciones lineales

% sum alpha(1:N-p+1)=0 ==> primer intervalo de tamaño p en la "convolucion"
Aeq=[zeros(1,N) ones(1,N-p+1) 0];

options = optimset('MaxFunEvals',cell2mat(EO(3)),'Tolfun',cell2mat(EO(4)),...
          'Algorithm',cell2mat(EO(2)),'UseParallel',cell2mat(EO(10)));

% handles necesarios para usar fmincon
f=@(x) J_D(x,N,p,reg_alpha,y); 
re=@(x) Nres(x,N,p,reg_alpha,pars,kernel_name,y);

% proceso de validacion intermetrica

metric_conf=cell2mat(EO(11)); % metrica usada para confirmar
thr=cell2mat(EO(12)); % valor de threshold

if strcmp(metric_conf,'SMAPE')
 h=@(x) x>=thr;
 mc=200;
elseif strcmp(metric_conf,'IA')
 h=@(x) x<=thr;
 mc=0;
end    

it=0;
t0=tic;
it_max=cell2mat(EO(13));

% El problema de optimizacion se resuelve a lo mas it_max veces
% y se detiene cuando hay sobreajuste a los datos entrenamiento (medido por un valor threshold)

while (h(mc))&&(it<it_max)
    
% Proceso de entrenamiento, problema de optimiacion:    
[Y,~,~,out]=fmincon(f,Y_0,[],[],Aeq,0,[],[],re,options);

mc=metrics(metric_conf,y,Y(1:N));
it=it+1;
Y_0=Y;
end

% Output del modelo

mod.time_tr=toc(t0);
mod.it=it;
mod.tr_metric={metric_conf,mc};
mod.par=pars;
mod.kernel=kernel_name;
mod.yk=Y(1:N);
mod.alpha=Y((N+1):2*N-p+1);
mod.bias=Y(2*N-p+2);
mod.N=N;
mod.p=p;
mod.reg_alpha=reg_alpha;
mod.y_input=y;
mod.normal=cell2mat(EO(5));

end
