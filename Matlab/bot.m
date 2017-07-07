function f=bot(val,dir,plotsFolder,dataFolder)
% Bot que guarda los valores "val" obtenidos en archivos .m

gtitle=strcat(val.mod.kernel,'_ATM',int2str(val.col),'_N',int2str(val.mod.N),...
       'p',int2str(val.mod.p),'_V',int2str(val.val_ind),'_',...
        int2str(val.grid_ind));

save(strcat(dataFolder,'\',dir,'\',gtitle,'.mat'),'val');
f=[];
end
