#include <AcceleroMMA7361.h>

AcceleroMMA7361 accelero;

// Definisci la tensione di riferimento
const double referenceVoltage = 5.0; // Cambia a 3.3 se usi 3.3V

void setup() {
  Serial.begin(9600);
  accelero.begin();
  accelero.setARefVoltage(referenceVoltage);
  accelero.calibrate();  // Calibra l'accelerometro

  // Stampa i valori di offset di calibrazione
  Serial.print("X Offset: "); Serial.println(accelero.getXRaw());
  Serial.print("Y Offset: "); Serial.println(accelero.getYRaw());
  Serial.print("Z Offset: "); Serial.println(accelero.getZRaw());
}

void loop() {
  // Non fare nulla
}
