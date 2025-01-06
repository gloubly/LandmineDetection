import processing.serial.*;
String myString = null;
Serial myPort;

// Variables pour stocker les données
float[] temps = new float[64];
String gpsData = "INVALID";

String defaultLat = "48.8961362085185";
String defaultLong = "2.236656940332593";

void setup() {
  size(600, 500); // Augmente la largeur pour inclure l'échelle
  noStroke();
  frameRate(30);

  // Liste les ports série disponibles
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 9600);
  myPort.clear();
  myString = myPort.readStringUntil(13);
  myString = null;
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  background(0);
  drawHeatmap();       // Dessine la carte thermique
  drawColorScale();    // Dessine l'échelle de couleurs
  drawDetectionStatus(); // Dessine le statut de détection (rectangle en bas)
  drawButton();        // Dessine le bouton
}

// Fonction pour dessiner la carte thermique
void drawHeatmap() {
  if (myPort.available() > 0) {
    myString = myPort.readStringUntil(13);

    if (myString != null) {
      println("Received: " + myString);

      // Vérifie si c'est une ligne GPS ou de données Grid-EYE
      if (!myString.startsWith("GPS:")) {
        String[] splitString = splitTokens(myString, ",");
        if (splitString.length >= 64) {
          for (int i = 0; i < 64; i++) {
            temps[i] = float(splitString[i]); // Stocke les températures
          }
        }
      }
    }
  }

  // Dessine la matrice thermique
  int x = 0, y = 0, i = 0;
  while (y < 400) {
    while (x < 400) {
      fill(map(temps[i], 20, 40, 240, 360), 100, 100);
      rect(x, y, 50, 50);
      x += 50;
      i++;
    }
    y += 50;
    x = 0;
  }
  filter(BLUR, 10); // Ajoute un flou
}

// Fonction pour dessiner l'échelle de couleurs
void drawColorScale() {
  int scaleX = 450; // Position X de l'échelle
  int scaleY = 10;  // Position Y de l'échelle
  int scaleWidth = 30; // Largeur de l'échelle
  int scaleHeight = 400; // Hauteur de l'échelle
  
  // Dessine l'échelle de couleurs
  for (int i = 0; i < scaleHeight; i++) {
    float temp = map(i, 0, scaleHeight, 40, 20); // Température entre 20°C et 40°C
    float colorValue = map(temp, 20, 40, 240, 360);
    stroke(colorValue, 100, 100);
    line(scaleX, scaleY + i, scaleX + scaleWidth, scaleY + i);
  }

  // Ajoute les annotations de température
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("40°C", scaleX + scaleWidth + 10, scaleY); // Texte en haut
  text("30°C", scaleX + scaleWidth + 10, scaleY + scaleHeight / 2); // Texte au milieu
  text("20°C", scaleX + scaleWidth + 10, scaleY + scaleHeight); // Texte en bas
}

// Fonction pour dessiner le rectangle de statut de détection
void drawDetectionStatus() {
  boolean mineDetected = false;

  // Vérifie si une température dépasse 28°C
  for (int i = 0; i < temps.length; i++) {
    if (temps[i] > 28) {
      mineDetected = true;
      break;
    }
  }

  // Dessine le rectangle
  if (mineDetected) {
    fill(0, 255, 0); // Vert
  } else {
    fill(255, 0, 0); // Rouge
  }
  rect(100, 400, 200, 50); // Rectangle sous l'image

  // Texte dans le rectangle
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  if (mineDetected) {
    text("MINE DETECTED", 200 , 425);
  } else {
    text("NO MINE DETECTED", 200, 425);
  }
}

// Fonction pour dessiner le bouton
void drawButton() {
  fill(50, 80, 100);
  rect(400, 430, 150, 50);
  fill(255);
  textAlign(CENTER, CENTER);
  text("SAVE IMAGE", 480, 455);
}

// Sauvegarde l'image et les données GPS
void mousePressed() {
  if (mouseX > 400 && mouseX < 550 && mouseY > 430 && mouseY < 480) {
    saveHeatmap();
  }
}

void saveHeatmap() {
  // Récupération de la date et de l'heure
  String timestamp = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + 
                     nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
  
  String filename = timestamp + "_" + defaultLat + "_" + defaultLong + ".png";
  
  // Sauvegarde de l'image
  saveFrame(filename);
  println("Image saved: " + filename);
}
