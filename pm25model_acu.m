pm=medfilt1(pm25acu); %Filtro de medianas a la variable objetivo 
pm=pm25acu; % Denominación de la variable objetivo como "pm"

input= inputs; %Matriz "inputs" con variables de entrada  
           
in=transpose(input); %Se transpone la matriz, eso depende de la forma...
...inicial (pero el tiempo avanza en columnas)

%Creación de red y estructura
net=network;
net.name='RED3';
net.numInputs=15;       %Número de entradas 
net.numLayers=2;       %Número de capas 
net.biasConnect=[1;0];     %Conexion de bias a cada neurona de cada capa
net.inputConnect=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %Conexiones de cada entrada a cada capa
net.layerConnect=[0 1;1 0];     %Conectar la capa 1 con la 2
net.outputConnect=[0 1];        %Conectar la capa 2 a la salida de la red
net.layerWeights{1,2}.delays =1;  %Delay a la realimentación

%Capa de entrada
net.inputs{1}.exampleInput=in(1,:);      %ingreso de datos de entrada
net.inputs{1}.name='PM10acu';            %nombre de cada variable        
net.inputs{2}.exampleInput=in(2,:);
net.inputs{2}.name='PM10apra';
net.inputs{3}.exampleInput=in(3,:);
net.inputs{3}.name='NOx';
net.inputs{4}.exampleInput=in(4,:);
net.inputs{4}.name='BLHacu';
net.inputs{5}.exampleInput=in(5,:);
net.inputs{5}.name='SH2';
net.inputs{6}.exampleInput=in(6,:);
net.inputs{6}.name='Vacu';
net.inputs{7}.exampleInput=in(7,:);
net.inputs{7}.name='hora';
net.inputs{8}.exampleInput=in(8,:);
net.inputs{8}.name='oxi';
net.inputs{9}.exampleInput=in(9,:);
net.inputs{9}.name='CO';
net.inputs{10}.exampleInput=in(10,:);
net.inputs{10}.name='estab';
net.inputs{11}.exampleInput=in(11,:);
net.inputs{11}.name='tol';
net.inputs{12}.exampleInput=in(12,:);
net.inputs{12}.name='HRacu';
net.inputs{13}.exampleInput=in(13,:);
net.inputs{13}.name='HCM';
net.inputs{14}.exampleInput=in(14,:);
net.inputs{14}.name='MPxi';
net.inputs{15}.exampleInput=in(15,:);
net.inputs{15}.name='Uacu';

for i=1:1:15
   net.inputs{i}.processFcns={'mapminmax'}; % Preprocesamiento para las...
   ...variables de entrada
end

net.initFcn='initlay'; %La red se inicializa de acuerdo a las funciones...
...de inicialización asignada a cada capa em net.initParam

%Capa oculta
net.layers{1}.name='capa oculta';
net.layers{1}.size=9;               %Cantidad de neuronas
net.layers{1}.transferFcn='tansig'; %Función de transferencia de neuronas 
net.layers{1}.initFcn='initnw';     %Función de inicialización de pesos...
...y bias de acuerdo a Nguyen-Widrow

%Capa de salida
net.layers{2}.name='capa de salida';
net.layers{2}.size=1;                 %Cantidad de neuronas de salida 
net.layers{2}.transferFcn='purelin';  %Función de transferencia lineal
net.layers{2}.initFcn='initnw';  %Función de inicialización Nguyen-Widrow

net.performFcn='mse';      %Función de rendimiento error cuadrático medio
net.trainFcn='trainlm';      %Función de entrenamiento Levenberg-Marquardt
net.divideFcn='dividerand';     %Divide set de entrada en entrenamiento...
...,test y validación al azar (dafault 70%,15%,15%)
net.plotFcns={'plotperform','plottrainstate', 'plotregression'};%Gráficas

%view(net);           %Visualizar la estructura de la red
net=init(net); %Inicializa la red para dar valores de pesos y sesgos...
...iniciales

target=pm; %Se elige la variable "pm" como objetivo
tar=transpose(target); % Se transpone (idem con variables de entrada)
[T,PS2]=mapminmax(tar); % Preprocesamiento a la variable objetivo


%Parámetros de función de entrenamiento
net.trainParam.epochs=1000; %Máxima cantidad de épocas (1000)
net.trainParam.goal=0;       %Meta de performance (0)
net.trainParam.max_fail=6;   %Máxima cantidad de fallas consecutivas en...
...la validación (6) 
net.trainParam.min_grad=1e-7; %Mínimo gradiente de performance (1e-7)
net.trainParam.mu=0.001; %Ganancia de entrenamiento inicial (0.001)
net.trainParam.mu_dec=0.1; %Factor de decrecimiento de la ganancia (0.1)...
..., va de 0 a 1
net.trainParam.mu_inc=10;    %Factor de crecimiento de la ganancia (10)
net.trainParam.mu_max=1e10;     %Máxima ganancia (1e10)
net.trainParam.time=inf     %Tiempo máximo de entrenamiento (inf)
net.trainParam.showWindow = true;   %Muestra el "Graphical User Interface" 
net.trainParam.showCommandLine = true;   %Muestra las líneas de comando 
net.trainParam.show= 2;   %Muestra los parámetros cada 2 iteraciones

[net,tr]=train(net,in,T);     %Entrenamiento

