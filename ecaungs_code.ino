//Inclusión de librerías
#include <SoftwareSerial.h> //Comunicación por puerto serial de la placa
#include <Arduino.h> //Control de los pines de la placa
#include <Wire.h> //Librería para protocolo de comunicación I2C
include <RTClib.h> //Control del módulo de reloj
include <SD.h> //Control del módulo de almacenamiento en tarjeta SD
include <cactus\_io\_BME280\_I2C.h> //Control de sensor BME280

//Definición de objetos

BME280\_I2C bme; //Objeto bme para el sensor
File myFile; Objeto myFile para crear un archivo en la tarjeta SD
#define LENG 31   //0x42 + 31 bytes = 32 bytes} Configuración serial
unsigned char buf[LENG]; //Buffer de comunicación
RTC\_DS3231 rtc; //Objeto rtc para el módulo de reloj
int PM01Value=0; //Objeto para P1       
int PM2\_5Value=0; //Objeto para PM2.5  
int PM10Value=0; //Objeto para PM10        
SoftwareSerial PMSerial(9,10); // RX, TX Pines digitales de la placa para la comunicación serial con el sensor de PM

//Bloque de una sola iteración
void setup()
{
PMSerial.begin(9600); //Comunicación serial con el sensor de PM a 9600 baudios
PMSerial.setTimeout(1000); //Milisegundos a esperar para buscar un nuevo dato en el puerto serial del sensor de PM\       
Serial.begin(9600); //Comunicación serial de la placa a 9600 baudios
pinMode(2,OUTPUT); //Pin digital de la placa asignado al LED verde
pinMode(3,OUTPUT); //Pin digital de la placa asignado al LED rojo
digitalWrite(3,LOW); //LED rojo apagado por defecto

if (!SD.begin(4)) { //Ciclo condicional para advertir ante falla del módulo SD
Serial.println(``No se pudo inicializar SD'');
digitalWrite(3,HIGH); //Enciende el LED rojo
return;
Serial.println(``inicializacion exitosa de SD'');}

if (!bme.begin()) { //Ciclo condicional para advertir ante falla en el BME280
digitalWrite(3,HIGH); //Enciende el LED rojo
Serial.println(``No se pudo inicializar BME'');
while (1);} 

if (! rtc.begin()){ //Ciclo condicional para advertir ante falla en módulo de reloj
Serial.println("No inicio RTC");
digitalWrite(3,HIGH);
while (1);}
  
if (rtc.lostPower()) { //Ciclo condicional para mantener seguimiento de fecha y hora en caso de corte de energía
rtc.adjust(DateTime(F(\_\_DATE\_\_), F(\_\_TIME\_\_)));}
  
Serial.println(``Fecha y hora PM1(ug/m3)  PM2.5(ug/m3)  PM10(ug/m3)  T(C)  HR(\%)  P(hPa) Marcador''); //Impresión de nombres de columnas en puerto serial 
}

//Bloque de iteración repetitiva
void loop()
{
digitalWrite(2,HIGH);//Encender LED verde

if(PMSerial.find(0x42)){ //Verificación de comunicación serial con sensor de PM
     PMSerial.readBytes(buf,LENG);
     if(buf[0] == 0x4d) {
        if(checkValue(buf,LENG)) {
           PM01Value=transmitPM01(buf);
           PM25Value=transmitPM25(buf);
           PM10Value=transmitPM10(buf);
        }           
     }
}
  
static unsigned long OledTimer=millis();
  
if (millis() - OledTimer >=1000) { //Verificación comunicación con reloj    
    OledTimer=millis(); 
    DateTime now = rtc.now(); //Sincronización reloj

myFile = SD.open(``ECAUNGS.txt'', FILE\_WRITE); //Abrir archivo en tarjeta SD
bme.readSensor(); //Tomar lecturas del BME280
  
if (myFile){ //Si se verifica toda comunicación sin fallas se enciende el LED verde y se imprimen los valores de fecha, hora, PM, temperatura, humedad, presión y, de haberlo, el marcador de adertencias. Luego se apaga el LED verde
  
digitalWrite(2,HIGH);
Serial.print(now.year(), DEC);
myFile.print(now.year(), DEC);
Serial.print('/');
myFile.print(";");
Serial.print(now.month(), DEC);
myFile.print(now.month(), DEC);
Serial.print('/');
myFile.print(";");
Serial.print(now.day(), DEC);
myFile.print(now.day(), DEC);
Serial.print(" ");
myFile.print(";");
Serial.print(now.hour(), DEC);
myFile.print(now.hour(), DEC);
Serial.print(':');
myFile.print(";");
Serial.print(now.minute(), DEC);
myFile.print(now.minute(), DEC);
Serial.print(':');
myFile.print(";");
Serial.print(now.second(), DEC);
myFile.print(now.second(),DEC);
myFile.print(";");
Serial.print(" ");
Serial.print(PM01Value);
myFile.print(PM01Value);
Serial.print(" ");      
myFile.print(";");
Serial.print(PM2\_5Value);
myFile.print(PM2\_5Value);
Serial.print(" ");
myFile.print(";");
Serial.print(PM10Value);
myFile.print(PM10Value);
Serial.print(" ");
myFile.print(";");
Serial.print(bme.getTemperature\_C());
myFile.print(bme.getTemperature\_C());
Serial.print(" ");
myFile.print(";");
Serial.print(bme.getHumidity());
myFile.print(bme.getHumidity());
Serial.print(" ");
myFile.print(";");
Serial.print(bme.getPressure\_MB());
myFile.print(bme.getPressure\_MB());
Serial.print(" ");
myFile.print(";");

//Condicionales para la inclusión de los códigos de advertencia
if (PM01value<3.3) {
   Serial.print(``A'');
   myFile.print(``A'');
  }
if (PM25value<4.4) {
   Serial.print(``B'');
   myFile.print(``B'');
  }
if (PM10value<4.4) {
   Serial.print("C");
   myFile.print("C");
}
if (PM25value>500) {
   Serial.print("D");
   myFile.print("D");
}
if (PM25value - PM25ant > 4.6) {
   Serial.print("E");
   myFile.print("E");
}
if (PM25value - PM25ant < -4.6) {
   Serial.print("F");
   myFile.print("F");
}
if (bme.getHumidity()>50) {
   Serial.print("G");
   myFile.print("G");
}
if (bme.getHumidity()>70) {
   Serial.print("H");
   myFile.print("H");
}
Serial.println(";");
myFile.println(";");
PM25ant = PM25value;
myFile.close();
digitalWrite(2,LOW);
} else { //Condicional para advertir falla al abrir el archivo en la tarjeta SD
 
  Serial.println("Error al abrir el archivo");
  digitalWrite(3,HIGH);
 }
}
 
delay(1000); //Milisegungos de espera en el ciclo repetitivo

}

//Configuración de transmisiones de señales del sensor de PM

char checkValue(unsigned char *thebuf, char leng)
{
char receiveflag=0;
int receiveSum=0;
for(int i=0; i<(leng-2); i++)
receiveSum=receiveSum+thebuf[i];
receiveSum=receiveSum + 0x42;
if(receiveSum == ((thebuf[leng-2]<<8)+thebuf[leng-1])) {
receiveSum = 0;
receiveflag = 1;}
return receiveflag;
int transmitPM01(unsigned char *thebuf)}
int PM01Val;
PM01Val=((thebuf[3]<<8) + thebuf[4]);$}
return PM01Val;}}
int transmitPM25(unsigned char *thebuf)}{
int PM25Val;}
PM25Val=((thebuf[5]<<8) + thebuf[6]);
return PM25Val;}
int transmitPM10(unsigned char *thebuf){
int PM10Val;}
PM10Val=((thebuf[7]<<8) + thebuf[8]);
return PM10Val;
