# Mat_RLS_SVM

V.1 Codigo Tesis

Recurrent Least Squares SVM código versión .m

El codigo esta optimizado para Matlab R2015b y funciona directamente clonando la carpeta principal, 
la data nueva esta en la carpeta "Data cif" y contiene las especificaciones para trabajar con ella.

## Observaciones y/o TODO's

* Mejorar la estructura de carpetas main.m (16~34)
* Mejorar el Proceso de Validacion del modelo main.m (102 ~ 106)
* Quitar redundancia en el almacenamiento de los resultados y buscar un metodo
  más "limpio" main.n (136)
* Reflexionar sobre el proceso de normalizacion. main.m (166)
* Mejorar la forma de almacenar los resultados. bot.m

## Data nueva

La carpeta "DATA csv" contiene los datos "nuevos", el programa funciona para estas series de tiempo nuevas aunque hay que fijar 
el tamaño del conjunto de entrenamiento. El programa funcionó sin ningun problema sobre las primeras 3 series de tiempo, 
para un conjunto de entrenamiento de tamaño N=60. Los datos de la carpeta "DATA csv" estan procesados de manera tal que  cada
columna es una serie distinta, los datos como "nombre" "horizonte" e "intervalo" fueron removido. Para medir la performance en 
test es necesario usar la variable de horizonte de prediccion.
 
En esta [pagina](http://irafm.osu.cz/cif/main.php?c=Static&page=download "Datos CIF") hay informacion adiional sobre los datos.


## Pasos a seguir

* Decidir si se añade otra base de datos.
* Añadir Agrupacion por similitud
* Añadir MLK 
* Traduccion a python
