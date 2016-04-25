#define BlueTooth Serial1

void setup() {
  Serial.begin(9600);
  BlueTooth.begin(9600);
}

void loop() {
  char incomingByte;
        
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    Serial.print("USB received: ");
    Serial.println(incomingByte);
    BlueTooth.print("USB received:");
    BlueTooth.println(incomingByte);
  }
  if (BlueTooth.available() > 0) {
    incomingByte = BlueTooth.read();
    Serial.print("UART received: ");
    Serial.println(incomingByte);
    BlueTooth.print("UART received:");
    BlueTooth.println(incomingByte);
  }
}
