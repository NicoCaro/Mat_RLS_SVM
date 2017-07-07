function f=app(ker,pars,y_l,y_k,K,alpha,bias,N,p)
% Funcion auxiliar para la evaluacion recurrente del metodo RLS-SVM
%
% f=app(ker,pars,y_l,y_k,K,alpha,bias,N,p)
% ker  : kernel .(function handle)
% pars : parametros del kernel.
% y_l  : vector input usado en la "convolucion".(see ref.)
% y_k  : segundo vector convolucionado.
% k    : subindice del punto estimado
% alpha: kernel weigths.(array double)
% bias : bias del modelo. double.
% N    : tamaño del training set
% p    : orden del modelo
%
% output: 
%
% f: resultado de la "convolucion" con y_k.
%
% esta funcion se usa para generar las restricciones de igualdad
% no lineales necesarias en para el solver de optimizacion.
%
%<Author:Nicolas Caro>
% 
% See also NRES , RLS_SVM , M_TRAIN.

if K>p
    
    f=0;
    for i=p:N
    f=alpha(i-p+1)*ker(y_l((i-p+1):i),y_k((K-p):(K-1)),pars)+f;
    end
    f=f+bias;
 
else
    display('k has to be greater than p')
end
