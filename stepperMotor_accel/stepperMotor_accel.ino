#include <SoftwareSerial.h>
#include <AccelStepper.h>

SoftwareSerial BlueTooth(10, 11);

int pinStep1 = 8;
int pinDir1 = 9;
int pinStep2 = 5;
int pinDir2 = 6;

AccelStepper stepper1(1, pinStep1, pinDir1);
AccelStepper stepper2(1, pinStep2, pinDir2);

void setup()
{
  Serial.begin(9600);
  BlueTooth.begin(9600);
  
  stepper1.setMaxSpeed(4000);
  stepper1.setSpeed(2500);
  stepper1.setAcceleration(3000);

  stepper2.setMaxSpeed(4000);
  stepper2.setSpeed(2500);
  stepper2.setAcceleration(3000);
}

String str;

void loop() {

  char incomingByte;
  
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    Serial.print("USB received: ");
    Serial.println(incomingByte);
    BlueTooth.print("USB received: ");
    BlueTooth.println(incomingByte);
    
    useByte(incomingByte);
    
  }

  //stepper1.run();
  //stepper2.run();
//
//  if (BlueTooth.available() > 0) {
//    incomingByte = BlueTooth.read();
//    Serial.print("UART received: ");
//    Serial.println(incomingByte);
//    BlueTooth.print("UART received: ");
//    BlueTooth.println(incomingByte);
//  }
    //int value = (str.substring(1)).toInt();
//    if (str[0] == 'p') {
//      moveDegrees(value, stepper1);
//    } else {
//      moveDegrees(value, stepper2);
//    }
//  }
//  
}

void useByte(char incomingByte) {
  String str;
  char newByte;
  int isNegative = 0;
  if (Serial.available() > 0) {
    newByte = Serial.read();
    Serial.print("USB received: ");
    Serial.println(newByte);
    BlueTooth.print("USB received: ");
    BlueTooth.println(newByte);
  }
    
  while (newByte != '|') {
    if (newByte == '-') {
      isNegative = 1;
    } else { 
      str.concat(newByte);
    }
    if (Serial.available() > 0) {
      newByte = Serial.read();
      Serial.print("USB received: ");
      Serial.println(newByte);
      BlueTooth.print("USB received: ");
      BlueTooth.println(newByte);
    }
   }
  int value = str.toInt();

  if (incomingByte == 'p') {
    if (isNegative == 1) {
      moveDegrees(-value, stepper1);
    } else {
      moveDegrees(value, stepper1);
    }
  } else if (incomingByte == 'r') {
    if (isNegative == 1) {
      moveDegrees(-value, stepper2);
    } else {
      moveDegrees(value, stepper2);
    }
  }
}

void moveDegrees(int deg, AccelStepper stepper) {
  //one step is 1.8 degrees and the default for the drivers is to move 1/8 of a step 
  //so 1600 steps = 360 degrees
  int numSteps = (deg / 1.8) * 8;
  stepper.moveTo(numSteps);
  BlueTooth.print("NUM STEPS.......");
  BlueTooth.println(numSteps);
  stepper.runToPosition();
  //stepper.stop();
}




