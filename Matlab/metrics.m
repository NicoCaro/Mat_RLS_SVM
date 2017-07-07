function f=metrics(metric_name,y,yp)
% Diccionario d emetricas
% f=metrics(metric_name,y,yp)
%
% Input:
% metric_name : nombre de la metrica.(string)
% y           : valores "originales".(double)
% y_p         : valores "predichos".(double)
% Output:
%
% f = resultado de evaluar la metrica
%
% <Author: Nicolas Caro>
% 
% See also KERNEL

if strcmp(metric_name,'IA') 
    
y_hat=mean(y);

ac=0;
for i=1:length(yp)
ac= (abs(y(i)-y_hat)+abs(yp(i)-y_hat))^2+ac;
end  

f= 1-((norm(y-yp,2)^2)/ac);

elseif strcmp(metric_name,'SMAPE')

ac=0;
for i=1:length(yp)
ac= abs(yp(i)-y(i))/((abs(yp(i))+abs(y(i)))/2) + ac;
end

f=(100*ac)/length(yp);

end

