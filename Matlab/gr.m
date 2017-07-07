function mesh=gr(p_bounds,varargin)
% Generacion de red para validacion de metrica y metodo grid.
% mesh=grid(p_bounds,par,EO)
% 
% p_bounds = [Lb Ub] Cotas para p.(array int)
%
% Parametros extra: 
% 
% EO={par_tuning,exp_step,par_n,par_bounds,p_points}
%
% par_tuning : indica si se hace parameter tuning.(bool)
% exp_step   : indica si se usan pasos exponenciales.(bool)
%              ej: par_lb=2^lb, par_ub=2^ub
% par_n      : numero de nodos en el eje "parametro".(int)
% par_bounds :[Lb Ub] cotas para el parametro.(array double)
% p_points   : numero de nodos en el eje "p".(int)
%
% input ejemplo: (default values)
%
% EO={true,true,11,[-5 5],(p_bounds(2)-p_bounds(1)+1)};
%
% <Author:Nicolas Caro>
% See alse KERNEL, DEFAUTLS,M_TRAIN,RLS_SVM.


%EO(1)= par_tuning
%EO(2)= exp_step (bool) base=2
%EO(3)= par_n
%EO(4)= par_bounds  --> when EO(2) then lb=base^par_bounds(1)
%                                       ub=base^par_bounds(2)
%EO(5)= p_points 

% Valores por defecto

EO={true,true,11,[-5 5],(p_bounds(2)-p_bounds(1)+1)};

if abs(nargin)>1
    for i=1:length(varargin)
    EO(i)=varargin(i);
    end
end

% p_step paso en p, por defecto es 1

p_step=floor((p_bounds(2)-p_bounds(1)+1)/cell2mat(EO(5)));
it=1;

% generacion de la red, Warning: Juego de indices muy enredado (pero funciona).
if cell2mat(EO(1))
    if cell2mat(EO(2))
        par_step= @(lb,step_size,index) 2^(lb+(index-1)*step_size);
    else
        par_step= @(lb,step_size,index) lb+(index-1)*step_size;
    end
    
    h=cell2mat(EO(4));
    par_step_size=(h(2)-h(1)+1)/cell2mat(EO(3));
    
    mesh=cell(1,cell2mat(EO(3))*cell2mat(EO(5)));
    for j=1:cell2mat(EO(3))
        for i=1:cell2mat(EO(5))
            %i-->par                       %j-->par
            mesh(it)={[p_bounds(1)+(i-1)*p_step,par_step(h(1),par_step_size,j)]};
            
            it=it+1;
        end
    end
    
else
    display('Tuning only on p')
    mesh=cell(1,cell2mat(EO(5)));
    for i=1:length(mesh)
        mesh(i)={p_bounds(1)+(i-1)*p_step};
    end
end

end
