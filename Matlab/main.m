%% Main RLS SVM

% Generacion de carpetas 
% Estructura:
% Current directory/
%
% /plots --> /BEST  ---> /ADJ  --->fig
%                   ---> /PRED --->fig
%
%        --> /ALL   ---> /ADJ  --->fig
%                   ---> /PRED --->fig
%
% /data  --> /BEST
%        --> /ALL

pwd
currentFolder=pwd;
mkdir(currentFolder,'plots')
plotsFolder=strcat(currentFolder,'\plots');
mkdir(plotsFolder,'\best')
mkdir(plotsFolder,'\best\PRED')
mkdir(plotsFolder,'\best\ADJ')
mkdir(plotsFolder,'\best\PRED\fig')
mkdir(plotsFolder,'\best\ADJ\fig')
mkdir(plotsFolder,'\all')
mkdir(plotsFolder,'\all\PRED')
mkdir(plotsFolder,'\all\ADJ')
mkdir(plotsFolder,'\all\PRED\fig')
mkdir(plotsFolder,'\all\ADJ\fig')

mkdir(currentFolder,'data')
dataFolder=strcat(currentFolder,'\data');
mkdir(dataFolder,'\best')
mkdir(dataFolder,'\all')

%% Carga de datos
load('DATA.mat')

%% Parametros del Modelo

% Indice de Validacion: Cantidad de veces que se valida
% usando el metodo intermetrica
K=1; 

% Para la base de ATM (Tesis) Ncol Selecciona el rango de ATMs
% con los que se trabajara

Ncol1=1;
Ncol2=3;

% Cantidad de observaciones del conjunto de test
N=60;

% Puntos de incio y termino en la serie para el proceso de entrenamiento
% por defecto pare en 1 y termina en N. Si se qusiera entrenar la serie en
% otro intervalo de tiempo se cambian estos parametros

N1=1;
N2=N1+N-1;

N_pt=14;

% Algoritmo de optimizacion en el entrenamiento
Op_alg='SQP';

% kernel Usado (sin MKL), si kernel =dot entonces gr(2)= false

kernel_name='dot'; 

% Regularizacion en alpha para el proceso de "sparsness inducida"
reg_alpha=0;

% Cantiadad Maxima se evaluaciones de la funcion objetivo en entrenamiento 
% (problema de optimizacion)

M_fun=3000;

% Tolerancia usada por el algoritmo de optimizacion (SQP, Punto interior, etc ...)
tol_fun=10^(-1);

% Parametros aleatoreos y adicion de ruido al punto inicial en el proceso de
% entrenamiento

normal=false;
noise=true;
seed=1;

mu=0;
sig=0.1;

% Parametros en paralelizacion

%OBS: * Si la version de matlab es inferior a R2013 usar "UsePar='always'"
%     * En versiones antiguas inicializar el procesamiento paralelo con "matlabpool"

%matlabpool

UsePar=true; % 'always' 

% Metricas en el proceso de validacion intermetrica. Puede ser SMAPE o IA

metric_conf='SMAPE';
thr=15;   % valor umbral para medir sobreajuste, en caso SMAPE, si en entrenamiento ajusta
%a un SMAPE inferior a 15 se considera sobreajustado.

it_max=1; % cuantas veces se entrena el modelo

metric_name='SMAPE'; %Metrica del despeño final

% Parametros metodo de la grilla 

if strcmp(kernel_name,'dot')
    par_tuning=false;
else
    par_tuning=true;
end

% Configuracion metodo de la grilla con salto exponencial:
% para el kernel RBF el salto exponencial siginica que el valor de 
% \eta se obtiene con saltos de 2^{paso} con n pasos.

exp_step=true;
p_bounds=[3 14]; % cotas para p en la busqueda por grilla

% numer de nodos asociados al eje del parametro
n_par=9;

par_bounds=[-4 4];%[lb ub]: exp_step --> exp_lb = 2^lb, exp_up=2^ub
n_p =(p_bounds(2)-p_bounds(1)+1); %numbero de nodos en el eje p de la grilla

% construccion de la grilla o red (mesh)
mesh=gr(p_bounds,par_tuning,exp_step,n_par,par_bounds,n_p);

lm=length(mesh);

% Los resultados del entrenamiento se almacenan en la estructura "val"
val(lm).col={}; % almacena el cajero que se esta trabajando
val(lm).mod={}; % Datos del modelo: kernel alg_opt etc ...
val(lm).res={}; % Datos del resultado del proceso de entrenamiento
val(lm).out={}; % output del algoritmo de optimizacion
val(lm).metric_SMAPE={}; 
val(lm).metric_IA={};
val(lm).plot_adj={};  % vectores de datos para graficar el ajuste en entrenamiento
val(lm).plot_pred={}; % vectores de datos para graficar el ajuste en prediccion
val(lm).N_pt={};      % numero de puntos a predecir fuera del conjunto de entrenamiento 
val(lm).grid_ind={};  % indice de la grilla con los mejores valores para "p" y "ker_par"
val(lm).val_ind={};   % indice de validacion, no se usa realmente 
val(lm).t_time={};    % tiempo de entrenamiento
val(lm).y_pt_original={}; % puntos a predecir fuera del conjunto de test "originales"

%% Procesamiento Global, Entrenamiento

for col=Ncol1:Ncol2
    t0=tic;
    
    % alamcenamiento y normalizacion  de los datos
    y_train=DATA(N1:N2,col); % datos entrenamiento
    y_pt=DATA((N2+1):(N2+N_pt),col); % datos a precedir fuera del conjunto train
    
    % normalizacion de los datos

    y_pto=y_pt; 
    
    if normal % si se elige, se pueden normalizar los datos
        y_pt=(y_pt-mean(y_pt))/std(y_pt); 
    else      % por defecto los datos se normalizan a [0,1]
        y_pt=(y_pt-min(y_pt))/(max(y_pt)-min(y_pt));
    end
    
    % Tuning de hiperparametros paralelo
    parfor i=1:lm
        if par_tuning
        mp=cell2mat(mesh(i));
    
    % Usa la funcion M_train para entrenar un modelo, en caso de que se quiera 
    % hacer tuning de parametro, se entrena con el valor actual de grilla en (mesh(i))
    % en el parametro y en p

        [mod,out]=M_train(y_train,mp(1),kernel_name,reg_alpha,mp(2),...
            Op_alg,M_fun,tol_fun,normal,noise,seed,mu,sig,UsePar,...
            metric_conf,thr,it_max);
        else
    % en caso de que no se haga tuneo de hiperparametro se usa solo el valor de la 
    % grilla en p.

         mp=cell2mat(mesh(i));
        [mod,out]=M_train(y_train,mp(1),kernel_name,reg_alpha,[],...
            Op_alg,M_fun,tol_fun,normal,noise,seed,mu,sig,UsePar,...
            metric_conf,thr,it_max);
            
        end

    % Se usa la funcio RLS_SVM para calcular la metrica en el conjunto de test, es decir,
    % en los N_pt puntos luego del conjunto de entrenamiento

        res=RLS_SVM(mod,N_pt);
        
   % Se almacenan los resultados

        val(i).val_ind=K;
        val(i).N_pt=N_pt;
        val(i).grid_ind=i;
        val(i).mod=mod;
        val(i).out=out;
        val(i).res=res;
        val(i).metric_SMAPE=metrics('SMAPE',y_pt,res.y_pred);
        val(i).metric_IA=metrics('IA',y_pt,res.y_pred);
        val(i).col=col;
        val(i).y_pt_original=y_pto;
        
        v=(1:length(mod.y_input));
        plot_vec_adj={v,mod.y_input,mod.yk};
        val(i).plot_adj=plot_vec_adj;
        
        plot_vec_pred={1:N_pt,y_pt,val(i).res.y_pred};
        val(i).plot_pred=plot_vec_pred;
   % Esta funcion almacena los datos de forma automati     
        bot(val(i),'all',plotsFolder,dataFolder);
        
    end
    
    if strcmp(metric_name,'SMAPE')
        h=[val.metric_SMAPE];
        [~,h]=min(h);
    elseif strcmp(metric_name,'IA')
        h=[val.metric_IA];
        [~,h]=max(h);
    end
    
    val(h).t_time=toc(t0);

    bot(val(h),'best',plotsFolder,dataFolder);
    
end

