pm=medfilt1(pm25eca);  %Filtro de medianas a PM25 medido por ECAUNGS      
      
var=input; %Entrada "var" asignada a matriz con variables de entrada...
..."input"

in=transpose(var); %Se transpone la matriz de entrada. El tiempo corre...
...en las columnas

%Creaci�n de red y estructura
net=network;
net.name='REDungs';
net.numInputs=7;       %N�mero de entradas 
net.numLayers=2;       %N�mero de capas 
net.biasConnect=[1;0];     %Conexion de bias a cada neurona de cada capa
net.inputConnect=[1 1 1 1 1 1 1;0 0 0 0 0 0 0]; %Conexiones de cada...
...entrada a cada capa
net.layerConnect=[0 1;1 0];     %Conectar la capa 1 con la 2
net.outputConnect=[0 1];        %Conectar la capa 2 a la salida de la red
net.layerWeights{1,2}.delays =1;  %Delay a la realimentaci�n

%Capa de entrada
net.inputs{1}.exampleInput=in(1,:); %ingreso de datos de entrada y nombres
net.inputs{1}.name='BLH';                
net.inputs{2}.exampleInput=in(2,:);
net.inputs{2}.name='meses';
net.inputs{3}.exampleInput=in(3,:);
net.inputs{3}.name='AODungs';
net.inputs{4}.exampleInput=in(4,:);
net.inputs{4}.name='Uacu';
net.inputs{5}.exampleInput=in(5,:);
net.inputs{5}.name='PM10acu';
net.inputs{6}.exampleInput=in(6,:);
net.inputs{6}.name='Vacu';
net.inputs{7}.exampleInput=in(7,:);
net.inputs{7}.name='hora';

for i=1:1:7
   net.inputs{i}.processFcns={'mapstd'}; %Preprocesamiento para las...
   ...variables de entrada
end

net.initFcn='initlay'; %La red se inicializa de acuerdo a las funciones...
...de inicializaci�n asignada a cada capa em net.initParam

%Capa oculta
net.layers{1}.name='capa oculta';
net.layers{1}.size=30;        %Cantidad de neuronas
net.layers{1}.transferFcn='radbasn'; %Funci�n de transferencia de neuronas 
net.layers{1}.initFcn='initnw';  %Funci�n de inicializaci�n de pesos...
...y bias de acuerdo a Nguyen-Widrow

%Capa de salida
net.layers{2}.name='capa de salida';
net.layers{2}.size=1;           %Cantidad de neuronas de salida 
net.layers{2}.transferFcn='purelin';    %Funci�n de transferencia lineal
net.layers{2}.initFcn='initnw';  %Funci�n de inicializaci�n Nguyen-Widrow

net.performFcn='mse';      %Funci�n de rendimiento error cuadr�tico medio
net.trainFcn='traincgf';      %Funci�n de entrenamiento de gradiente...
...conjugado 
net.divideFcn='dividerand';     %Divide set de entrada en entrenamiento,...
...test y validaci�n al azar (dafault 70%,15%,15%)
net.divideParam.trainRatio = 60/100; %Proporci�n para datos de...
...entrenamiento
net.divideParam.valRatio = 20/100; %Proporci�n para datos de validaci�n
net.divideParam.testRatio = 20/100; %Proporci�n para datos de test
net.plotFcns={'plotperform','plottrainstate', 'plotregression'}; %Gr�ficas
%view(net);           %Visualizar la estructura de la red
net=init(net); %Inicializa la red para dar valores de pesos y...
...biases iniciales

target=pm;
tar=transpose(target); 
T=mapstd(tar); %Preprocesamiento a variable objetivo

%Par�metros de funci�n de entrenamiento

net.trainParam.epochs=1000;   %M�xima cantidad de �pocas (1000)
net.trainParam.goal=0;   %Meta de performance (0)
net.trainParam.max_fail=6;  %M�xima cantidad de fallas consecutivas...
...en la validaci�n (6) 
net.trainParam.min_grad=1e-7; %M�nimo gradiente de performance (1e-7)
net.trainParam.mu=0.001; %Ganancia de entrenamiento inicial (0.001)
net.trainParam.mu_dec=0.1; %Factor de decrecimiento de la ganancia...
...(0.1), va de 0 a 1
net.trainParam.mu_inc=10;    %Factor de crecimiento de la ganancia (10)
net.trainParam.mu_max=1e10;     %M�xima ganancia (1e10)
net.trainParam.time=inf;     %Tiempo m�ximo de entrenamiento (inf)
net.trainParam.showWindow = true;   %Muestra el GUI 
net.trainParam.showCommandLine = true;   %Muestra las l�neas de comando 
net.trainParam.show= 2;   %Muestra los par�metros cada 2 iteraciones

[net,tr]=train(net,in,T);  %Entrenamiento
