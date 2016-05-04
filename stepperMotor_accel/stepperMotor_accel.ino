#include <SoftwareSerial.h>
#include <AccelStepper.h>


int btRxPin = 10;
int btTxPin = 11;

int pinDir1 = 8;
int pinStep1 = 9;
int pinDir2 = 6;
int pinStep2 = 7;

SoftwareSerial Bluetooth(btRxPin, btTxPin);

AccelStepper stepper1(AccelStepper::DRIVER, pinStep1, pinDir1);
AccelStepper stepper2(AccelStepper::DRIVER, pinStep2, pinDir2);

void setup()
{
  Serial.begin(115200);
  Bluetooth.begin(115200);

  int maxSpeed = 4000;
  int acceleration = maxSpeed*maxSpeed;
  
  stepper1.setMaxSpeed(maxSpeed);
  stepper1.setAcceleration(acceleration);

  stepper2.setMaxSpeed(maxSpeed);
  stepper2.setAcceleration(acceleration);

  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);
}

String str;

void loop()
{
  char incomingByte;
  
  if (Bluetooth.available() > 0) {
    incomingByte = Bluetooth.read();
    useByte(incomingByte);
  }

  stepper1.run();
  stepper2.run();
}

void useByte(char incomingByte)
{
  String str;
  char newByte = ' ';
  int sign = 1;
  
  if (Bluetooth.available() > 0) {
    newByte = Bluetooth.read();
  }
    
  while (newByte != '|') {
    if (newByte == '-') {
      sign = -1;
    } else { 
      str.concat(newByte);
    }
    if (Bluetooth.available() > 0) {
      newByte = Bluetooth.read();
    }
  }
  
  int value = sign * str.toInt();
  int steps = deg2steps(value);

  Serial.print(incomingByte);
  Serial.print(' ');
  Serial.print(str);
  Serial.print('=');
  Serial.println(value);
  
  if (incomingByte == 'p') {
    stepper1.moveTo(steps); 
    
  } else if (incomingByte == 'r') {
    stepper2.moveTo(steps);
  
  } else if(incomingByte == 'z') {
    if(str == "p"){
      stepper1.setCurrentPosition(0);
    } else if(str == "r"){
      stepper2.setCurrentPosition(0);
    }
  }
}

int deg2steps(int deg)
{
  int steps = (deg / 1.8) * 8;
  
  return steps;
}




