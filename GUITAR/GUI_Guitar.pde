import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress superCollider;

PImage bgImage;
PImage logo;

PFont customFont;
PFont defaultFont;

int buttonX_1 = 113;
int buttonY_1 = 250;

int buttonX_2 = 231;
int buttonY_2 = 312;

int buttonX_3 = 326;
int buttonY_3 = 394;
int buttonRadius = 23;

boolean isButtonPressed_Inst1 = false;
boolean isButtonPressed_Inst2 = false;
boolean isButtonPressed_Inst3 = false;

String[] instruments = {"Chorus", "Guitar & Bass", "Dry Guitar"};
String selectedInstrument = "";

void setup(){
  size(500, 700);
  bgImage = loadImage("GUI_guitar.jpg");
  logo = loadImage("ANSAL_LOGO.png");

  // Load custom font
  customFont = createFont("Jersey25Charted-Regular.ttf", 16);  

  // Load default font (optional, if you want to ensure a specific default font)
  defaultFont = createFont("Arial", 10);  

  oscP5 = new OscP5(this, 12000);
  superCollider = new NetAddress("127.0.0.1", 57120);
}

void draw(){
  background(0);
  image(bgImage, 0, 0, width, height);
  
  // Draw the top rectangle (screen)
  fill(0);
  rect(65, 60, width - 130, 50);
  
  // Draw the selected instrument name in the rectangle using the custom font
  textFont(customFont);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(selectedInstrument, width / 2, 82.5);
  
  // Draw button 1
  if (isButtonPressed_Inst1) {
    fill(233, 227, 219); // Color when pressed
  } else {
    fill(238, 240, 226); // Default color
  }
  noStroke(); // Remove border
  ellipse(buttonX_1, buttonY_1, buttonRadius * 2, buttonRadius * 2);
  if (isButtonPressed_Inst1) {
    fill(255, 71, 71); // Text color when pressed
  } else {
    fill(0); // Default text color
  }
  textFont(defaultFont);
  textAlign(CENTER, CENTER);
  textSize(10);
  text("CHR", buttonX_1, buttonY_1); 
  
  // Draw button 2
  if (isButtonPressed_Inst2) {
    fill(233, 227, 219); // Color when pressed
  } else {
    fill(238, 240, 226); // Default color
  }
  noStroke(); // Remove border
  ellipse(buttonX_2, buttonY_2, buttonRadius * 2, buttonRadius * 2);
  if (isButtonPressed_Inst2) {
    fill(83, 121, 255); // Text color when pressed
  } else {
    fill(0); // Default text color
  }
  textFont(defaultFont);
  text("G & B", buttonX_2, buttonY_2); 
  
  // Draw button 3
  if (isButtonPressed_Inst3) {
    fill(233, 227, 219); // Color when pressed
  } else {
    fill(238, 240, 226); // Default color
  }
  noStroke(); // Remove border
  ellipse(buttonX_3, buttonY_3, buttonRadius * 2, buttonRadius * 2);
  if (isButtonPressed_Inst3) {
    fill(6, 196, 127); // Text color when pressed
  } else {
    fill(0); // Default text color
  }
  textFont(defaultFont);
  text("DRY", buttonX_3, buttonY_3); 
  
  // Draw logo in the bottom-left corner and resize it
  float logoWidth = logo.width * 0.2;  // Scale down the width to 25%
  float logoHeight = logo.height * 0.2;  // Scale down the height to 25%
  image(logo, width/2 - 60, height - logoHeight + 10, logoWidth, logoHeight); // Adjust the position and size as needed
}

void mousePressed() {
  // Calculate the distance between the mouse and the center of each button
  float distance1 = dist(mouseX, mouseY, buttonX_1, buttonY_1);
  float distance2 = dist(mouseX, mouseY, buttonX_2, buttonY_2);
  float distance3 = dist(mouseX, mouseY, buttonX_3, buttonY_3);

  // Check if the distance is less than the radius (inside the button)
  if (distance1 < buttonRadius) {
    isButtonPressed_Inst1 = true;
    isButtonPressed_Inst2 = false;
    isButtonPressed_Inst3 = false;
    selectedInstrument = instruments[0];
    sendOscMessage("Mode1");
  } else if (distance2 < buttonRadius) {
    isButtonPressed_Inst1 = false;
    isButtonPressed_Inst2 = true;
    isButtonPressed_Inst3 = false;
    selectedInstrument = instruments[1];
    sendOscMessage("Mode2");
  } else if (distance3 < buttonRadius) {
    isButtonPressed_Inst1 = false;
    isButtonPressed_Inst2 = false;
    isButtonPressed_Inst3 = true;
    selectedInstrument = instruments[2];
    sendOscMessage("Mode3");
  }
}

void sendOscMessage(String message) {
  OscMessage oscMsg = new OscMessage("/selectMode");
  oscMsg.add(message);
  oscP5.send(oscMsg, superCollider);
  println("OSC Message sent: " + message);
}
