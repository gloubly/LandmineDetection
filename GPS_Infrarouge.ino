#include <TinyGPS++.h>
#include <Wire.h>
#include <SparkFun_GridEYE_Arduino_Library.h>

TinyGPSPlus gps;       // Objet GPS
GridEYE grideye;       // Objet Grid-EYE

void setup() {
  Serial.begin(9600);   // Communication série avec Processing
  Serial1.begin(9600);  // Communication série avec le module GPS
  Wire.begin();         // Initialisation I2C
  if (!grideye.begin()) {
    Serial.println("Grid-EYE non détecté !");
    while (1);          // Boucle bloquante si Grid-EYE absent
  }
  Serial.println("Capteurs initialisés.");
}

void loop() {
  // Lecture des données GPS
  while (Serial1.available() > 0) {
    gps.encode(Serial1.read());
  }

  // Envoyer les données GPS uniquement si une localisation valide est disponible
  if (gps.location.isValid()) {
    Serial.print("GPS:");
    Serial.print(gps.location.lat(), 6);
    Serial.print(",");
    Serial.print(gps.location.lng(), 6);
    Serial.print(",");
    Serial.print(gps.date.year());
    Serial.print("-");
    Serial.print(gps.date.month());
    Serial.print("-");
    Serial.print(gps.date.day());
    Serial.print(",");
    Serial.print(gps.time.hour());
    Serial.print(":");
    Serial.print(gps.time.minute());
    Serial.print(":");
    Serial.println(gps.time.second());
  } else {
    Serial.println("GPS:INVALID");
  }

  // Lecture des températures du Grid-EYE
  for (int i = 0; i < 64; i++) {
    Serial.print(grideye.getPixelTemperature(i));
    if (i < 63) Serial.print(",");
  }
  Serial.println();  // Fin de la trame de données Grid-EYE

  delay(500);  // Pause pour limiter les envois
}
