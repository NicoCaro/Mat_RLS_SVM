function res=RLS_SVM(mod,n)
%res=RLS_SVM(mod,n,varargin)
%
% Estimador RLS-SVM
%
%res=RLS_SVM(mod,n)
%mod : Estructura mod. (M_train output).(struct)
%n   : Numero de predicciones a hacer.(int)
%
% Output:
% res --> estructura que contiene:
% 
% y_original        : vector input usado en entrenamiento.(array double)
% y_model           : vector y_barra ajustado por el modelo en entrenamiento
%                     .(array double)
% y_pred            : vector de predicciones.(array double)
% time_RLS          : tiempo consumido en prediccion.[secs](double)
%
% <Author:Nicolas Caro>
%
% See also M_TRAIN,APP,KERNEL,DEFAULTS

N=mod.N;
p=mod.p;

% ventana pivote de tamaño p
y_win=mod.yk((N-p+1):N);

% vector de predicciones 
y_pred=zeros(n,1);

% proceso de evaluacion recurrente
t0=tic;
for i=1:n
   
    y_pred(i)=app(kernel(mod.kernel),mod.par,mod.yk,y_win,(p+1),mod.alpha...
                  ,mod.bias,N,p);
    y_win=[y_win(2:p) ; y_pred(i)];

end

% Almacenaje de resultados

res.time_RLS=toc(t0);
res.y_input=mod.y_input;
res.y_original=mod.y_original;
res.y_model=mod.yk;
res.y_pred=y_pred;

end
