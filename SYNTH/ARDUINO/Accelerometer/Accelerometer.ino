#include <AcceleroMMA7361.h>

AcceleroMMA7361 accelero;

// Offset di calibrazione mediati
const int xOffset = 339;
const int yOffset = 339;
const int zOffset = 502;

// Definisci la tensione di riferimento
const double referenceVoltage = 5.0; // Cambia a 3.3 se usi 3.3V

// Definisci gli shift per pitch e roll
const float pitchShift = -11.3;
const float rollShift = -5.0;

void setup() {
  Serial.begin(9600);
  accelero.begin();
  accelero.setARefVoltage(referenceVoltage);
  accelero.setOffSets(xOffset, yOffset, zOffset);
}

void loop() {
  int x, y, z;
  accelero.getAccelXYZ(&x, &y, &z);

  float pitch = atan2(y, sqrt(x * x + z * z)) * 180.0 / PI + pitchShift;
  float roll = atan2(x, sqrt(y * y + z * z)) * 180.0 / PI + rollShift;

  Serial.print(pitch);
  Serial.print(",");
  Serial.println(roll);

  delay(30);
}
