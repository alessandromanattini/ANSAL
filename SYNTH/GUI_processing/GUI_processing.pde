import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress superCollider;
ControlP5 cp5;

// Useful Variables
boolean mono1On = false;
boolean mono2On = false;
boolean guiOn = false;
String[] instruments = {"None", "everythingrhodes", "distortedTri", "sawtooth", "hammondOrgan", "bass", "violin", "mrostinato", "synchronicity"};
int[] octaves = {0, 1, 2, 3, -3, -2, -1};
String[] controlPedal = {"NIL", "DIR", "INV"};
String[] accelerometer = {"NONE", "INS 1", "INS 2", "BOTH"};

int currentInstrumentIndex1 = 0;
Textlabel instrumentLabel1;
int currentInstrumentIndex2 = 0;
Textlabel instrumentLabel2;

int currentOctaveIndex1 = 0;
Textlabel currentOctaveLabel1;
int currentOctaveIndex2 = 0;
Textlabel currentOctaveLabel2;

int currentPedalIndex1 = 0;
Textlabel currentPedalLabel1;
int currentPedalIndex2 = 0;
Textlabel currentPedalLabel2;

int currentXIndex = 0;
Textlabel currentXLabel;
int currentYIndex = 0;
Textlabel currentYLabel;

Textlabel instrument1Text, instrument2Text, octave1Text, octave2Text, bpmText, 
          vocVolumeText, volume1Text, volume2Text, lpf1Text, lpf2Text, controlPedal1Text, 
          controlPedal2Text, xText, yText;

Knob volume1Knob, lpf1Knob, volume2Knob, lpf2Knob;
Slider bpm, vocoderVolume;

void setup() {
    size(925, 700);
    
    oscP5 = new OscP5(this, 12000);
    superCollider = new NetAddress("127.0.0.1", 57120);

    cp5 = new ControlP5(this);
    
    // Etichette di testo
    instrument1Text = cp5.addTextlabel("INSTRUMENT1")
                        .setPosition(92.5, 55)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("INSTRUMENT 1");

    octave1Text = cp5.addTextlabel("OCTAVE1")
                        .setPosition(107.5, 155)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("OCTAVE 1");
                  
    controlPedal1Text = cp5.addTextlabel("CONTROL 1")
                        .setPosition(102.5, 255)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("CONTROL 1");

    instrument2Text = cp5.addTextlabel("INSTRUMENT2")
                        .setPosition(392.5, 55)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("INSTRUMENT 2");

    octave2Text = cp5.addTextlabel("OCTAVE2")
                        .setPosition(410, 155)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("OCTAVE 2");

    controlPedal2Text = cp5.addTextlabel("CONTROL 2")
                        .setPosition(407.5, 255)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("CONTROL 2");

    bpmText = cp5.addTextlabel("BPM")
                        .setPosition(680, 50)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("BPM");

    vocVolumeText = cp5.addTextlabel("VOCVOLUME")
                        .setPosition(805, 50)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("VOC");

    volume1Text = cp5.addTextlabel("VOLUME1")
                        .setPosition(113, 440)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("VOLUME 1");

    lpf1Text = cp5.addTextlabel("LPF1")
                        .setPosition(130, 565)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("LPF 1");

    volume2Text = cp5.addTextlabel("VOLUME2")
                        .setPosition(415, 440)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("VOLUME 2");

    lpf2Text = cp5.addTextlabel("LPF2")
                        .setPosition(435, 565)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText("LPF 2");

    // Slider bpm drums
    bpm = cp5.addSlider("bpmDrums")
        .setPosition(675, 75)
        .setSize(50, 250)
        .setLabel("")
        .setRange(80, 300)
        .setValue(128)
        .setColorForeground(color(128, 122, 122))
        .setColorBackground(color(43, 40, 40))
        .setColorCaptionLabel(color(128, 122, 122))
        .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendBPMMessage(value);
            }
        });

    vocoderVolume = cp5.addSlider("VococerVolume")
                  .setPosition(800, 75)
                  .setSize(50, 250)
                  .setLabel("")
                  .setRange(0, 5)
                  .setValue(50)
                  .setColorForeground(color(128, 122, 122))
                  .setColorBackground(color(43, 40, 40))
                  .setColorCaptionLabel(color(128, 122, 122))
                  .onChange(new CallbackListener() {
                      public void controlEvent(CallbackEvent event) {
                          float value = event.getController().getValue();
                          sendVocoderVolumeMessage(value);
                      }
                  });

    cp5.addButton("GUI")
       .setPosition(800, 330)
       .setSize(50, 20)
       .setLabel("GUI")
       .setColorBackground(color(124, 18, 18))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                guiOn = !guiOn;
                sendGUIMessage(guiOn ? "on" : "off");
                event.getController().setColorBackground(guiOn ? color(0, 205, 70) : color(124, 18, 18));
            }
        });

    // Bottoni Mono1
    cp5.addButton("Mono1")
       .setPosition(100, 365)
       .setSize(100, 30)
       .setLabel("Mono 1")
       .setColorBackground(color(124, 18, 18))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                mono1On = !mono1On;
                sendMono1Message(mono1On ? "on" : "off");
                event.getController().setColorBackground(mono1On ? color(0, 205, 70) : color(124, 18, 18));
            }
        });

    // Knob Volume 1
    volume1Knob = cp5.addKnob("Volume1Knob")
       .setPosition(120, 470)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(0, 1)
       .setValue(0.5)
       .setLabel("")
       .setColorForeground(color(128, 122, 122))
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(128, 122, 122))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendVolume1Message(value);
            }
        });

    // Knob LPF 1
    lpf1Knob = cp5.addKnob("LPF1Knob")
       .setPosition(120, 590)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(20, 6000) // Frequenza in Hz
       .setValue(3000)
       .setLabel("")
       .setColorForeground(color(128, 122, 122))
       .setColorBackground(color(43, 40, 40))
       .setColorCaptionLabel(color(128, 122, 122))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendLPF1Message(value);
            }
        });

    // Bottoni Mono2
    cp5.addButton("Mono2")
       .setPosition(400, 365)
       .setSize(100, 30)
       .setLabel("Mono 2")
       .setColorBackground(color(124, 18, 18))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                mono2On = !mono2On;
                sendMono2Message(mono2On ? "on" : "off");
                event.getController().setColorBackground(mono2On ? color(0, 205, 70) : color(124, 18, 18));
            }
        });

    // Knob Volume 2
    volume2Knob = cp5.addKnob("Volume2Knob")
       .setPosition(425, 470)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(0, 1)
       .setValue(0.5)
       .setLabel("")
       .setColorForeground(color(128, 122, 122))
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(128, 122, 122))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendVolume2Message(value);
            }
        });

    // Knob LPF 2
    lpf2Knob = cp5.addKnob("LPF2Knob")
       .setPosition(425, 590)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(200, 6000) // Frequenza in Hz
       .setValue(3000)
       .setLabel("")
       .setColorForeground(color(128, 122, 122))
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(128, 122, 122))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendLPF2Message(value);
            }
        });

    // Selezione dello strumento n.1
    instrumentLabel1 = cp5.addTextlabel("instrumentLabel1")
                        .setPosition(100, 96)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 12))
                        .setText(instruments[currentInstrumentIndex1]);
                    
    cp5.addButton("Avanti1")
       .setPosition(200, 75)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex1 = (currentInstrumentIndex1 + 1) % instruments.length;
                instrumentLabel1.setText(instruments[currentInstrumentIndex1]);
                sendInstrument1Message(instruments[currentInstrumentIndex1]);
            }
        });

    cp5.addButton("Indietro1")
       .setPosition(50, 75)
       .setSize(50, 50)
       .setLabel("PREV")
       .setColorCaptionLabel(color(43, 40, 40))
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex1 = (currentInstrumentIndex1 - 1 + instruments.length) % instruments.length;
                instrumentLabel1.setText(instruments[currentInstrumentIndex1]);
                sendInstrument1Message(instruments[currentInstrumentIndex1]);
            }
        });

    sendInstrument1Message(instruments[currentInstrumentIndex1]);

    // Selezione dello strumento n.2
    instrumentLabel2 = cp5.addTextlabel("instrumentLabel2")
                        .setPosition(400, 95)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 12))
                        .setText(instruments[currentInstrumentIndex2]);

    cp5.addButton("Avanti2")
       .setPosition(500, 75)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex2 = (currentInstrumentIndex2 + 1) % instruments.length;
                instrumentLabel2.setText(instruments[currentInstrumentIndex2]);
                sendInstrument2Message(instruments[currentInstrumentIndex2]);
            }
        });

    cp5.addButton("Indietro2")
       .setPosition(350, 75)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("PREV")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex2 = (currentInstrumentIndex2 - 1 + instruments.length) % instruments.length;
                instrumentLabel2.setText(instruments[currentInstrumentIndex2]);
                sendInstrument2Message(instruments[currentInstrumentIndex2]);
            }
        });

    sendInstrument2Message(instruments[currentInstrumentIndex2]);

    // Selezione dell'ottava n.1
    currentOctaveLabel1 = cp5.addTextlabel("currentOctaveLabel1")
                        .setPosition(140, 190)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex1]));

    cp5.addButton("AvantiOctave1")
       .setPosition(200, 175)
       .setSize(50, 50)
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("+")
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex1 = (currentOctaveIndex1 + 1) % octaves.length;
                currentOctaveLabel1.setText(str(octaves[currentOctaveIndex1]));
                sendOctave1Message(octaves[currentOctaveIndex1]);
            }
        });

    cp5.addButton("IndietroOctave1")
       .setPosition(50, 175)
       .setSize(50, 50)
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("-")
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex1 = (currentOctaveIndex1 - 1 + octaves.length) % octaves.length;
                currentOctaveLabel1.setText(str(octaves[currentOctaveIndex1]));
                sendOctave1Message(octaves[currentOctaveIndex1]);
            }
        });

    sendOctave1Message(octaves[currentOctaveIndex1]);

    // Selezione dell'ottava n.2
    currentOctaveLabel2 = cp5.addTextlabel("currentOctaveLabel2")
                        .setPosition(440, 190)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex2]));

    cp5.addButton("AvantiOctave2")
       .setPosition(500, 175)
       .setSize(50, 50)
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("+")
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex2 = (currentOctaveIndex2 + 1) % octaves.length;
                currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
                sendOctave2Message(octaves[currentOctaveIndex2]);
            }
        });

    cp5.addButton("IndietroOctave2")
       .setPosition(350, 175)
       .setSize(50, 50)
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("-")
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex2 = (currentOctaveIndex2 - 1 + octaves.length) % octaves.length;
                currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
                sendOctave2Message(octaves[currentOctaveIndex2]);
            }
        });

    sendOctave2Message(octaves[currentOctaveIndex2]);

    // Selezione del control pedal n.1
    currentPedalLabel1 = cp5.addTextlabel("ControlPedal1")
                        .setPosition(132.5, 292.5)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(controlPedal[currentPedalIndex1]);
                    
    cp5.addButton("NextControlPedal1")
       .setPosition(200, 275)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPedalIndex1 = (currentPedalIndex1 + 1) % controlPedal.length;
                currentPedalLabel1.setText(controlPedal[currentPedalIndex1]);
                sendControlPedal1Message(controlPedal[currentPedalIndex1]);
            }
        });

    cp5.addButton("PrevControlPedal1")
       .setPosition(50, 275)
       .setSize(50, 50)
       .setLabel("PREV")
       .setColorCaptionLabel(color(43, 40, 40))
       .setColorBackground(color(128, 122, 122))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPedalIndex1 = (currentPedalIndex1 - 1 + controlPedal.length) % controlPedal.length;
                currentPedalLabel1.setText(controlPedal[currentPedalIndex1]);
                sendControlPedal1Message(controlPedal[currentPedalIndex1]);
            }
        });

    sendControlPedal1Message(controlPedal[currentPedalIndex1]);

    // Selezione del control pedal n.2
    currentPedalLabel2 = cp5.addTextlabel("ControlPedal2")
                        .setPosition(432.5, 292.5)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(controlPedal[currentPedalIndex2]);

    cp5.addButton("NextControlPedal2")
       .setPosition(500, 275)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPedalIndex2 = (currentPedalIndex2 + 1) % controlPedal.length;
                currentPedalLabel2.setText(controlPedal[currentPedalIndex2]);
                sendControlPedal2Message(controlPedal[currentPedalIndex2]);
            }
        });

    cp5.addButton("PrevControlPedal2")
       .setPosition(350, 275)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("PREV")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPedalIndex2 = (currentPedalIndex2 - 1 + controlPedal.length) % controlPedal.length;
                currentPedalLabel2.setText(controlPedal[currentPedalIndex2]);
                sendControlPedal2Message(controlPedal[currentPedalIndex2]);
            }
        });

    sendControlPedal2Message(controlPedal[currentPedalIndex2]);
    
    // Selezione accelerometer X
    xText = cp5.addTextlabel("ACCELEROMETER_X")
                .setPosition(735, 420)
                .setSize(200, 50)
                .setColorValue(color(255, 255, 255))
                .setFont(createFont("Arial", 15))
                .setText("X AXIS");

    currentXLabel = cp5.addTextlabel("currentXLabel")
                    .setPosition(740, 470)
                    .setSize(200, 50)
                    .setColorValue(color(255, 255, 255))
                    .setFont(createFont("Arial", 15))
                    .setText(accelerometer[currentXIndex]);

    cp5.addButton("NextX")
       .setPosition(825, 455)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentXIndex = (currentXIndex + 1) % accelerometer.length;
                currentXLabel.setText(accelerometer[currentXIndex]);
                sendAccelerometerXMessage(accelerometer[currentXIndex]);
            }
        });

    cp5.addButton("PrevX")
       .setPosition(650, 455)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("PREV")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentXIndex = (currentXIndex - 1 + accelerometer.length) % accelerometer.length;
                currentXLabel.setText(accelerometer[currentXIndex]);
                sendAccelerometerXMessage(accelerometer[currentXIndex]);
            }
        });

    sendAccelerometerXMessage(accelerometer[currentXIndex]);

    // Selezione accelerometer Y
    yText = cp5.addTextlabel("ACCELEROMETER_Y")
                .setPosition(735, 570)
                .setSize(200, 50)
                .setColorValue(color(255, 255, 255))
                .setFont(createFont("Arial", 15))
                .setText("Y AXIS");

    currentYLabel = cp5.addTextlabel("currentYLabel")
                    .setPosition(740, 620)
                    .setSize(200, 50)
                    .setColorValue(color(255, 255, 255))
                    .setFont(createFont("Arial", 15))
                    .setText(accelerometer[currentYIndex]);

    cp5.addButton("NextY")
       .setPosition(825, 605)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentYIndex = (currentYIndex + 1) % accelerometer.length;
                currentYLabel.setText(accelerometer[currentYIndex]);
                sendAccelerometerYMessage(accelerometer[currentYIndex]);
            }
        });

    cp5.addButton("PrevY")
       .setPosition(650, 605)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("PREV")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentYIndex = (currentYIndex - 1 + accelerometer.length) % accelerometer.length;
                currentYLabel.setText(accelerometer[currentYIndex]);
                sendAccelerometerYMessage(accelerometer[currentYIndex]);
            }
        });

    sendAccelerometerYMessage(accelerometer[currentYIndex]);

    noFill(); // Disable the filling of shapes
    stroke(color(255, 255, 255)); // Set the stroke (border) color to black
    strokeWeight(2); // Set the stroke weight to 2 pixels
}

void draw() {
    background(0);
    rect(25, 25, 250, 650);
    rect(325, 25, 250, 650);
    rect(625, 25, 275, 350);
    rect(625, 400, 275, 125);
    rect(625, 550, 275, 125);
}

// --------------------------------- METODI DI INVIO MESSAGGI OSC -------------------------------------------

// Funzione per inviare un messaggio OSC con lo strumento selezionato
void sendInstrument1Message(String instrument1) {
    OscMessage msg = new OscMessage("/selectInstrument1");
    msg.add(instrument1);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Instrument1 = " + instrument1);
}

void sendInstrument2Message(String instrument2) {
    OscMessage msg = new OscMessage("/selectInstrument2");
    msg.add(instrument2);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Instrument2 = " + instrument2);
}

// Funzione per inviare un messaggio OSC per il mono
void sendMono1Message(String state) {
    OscMessage msg = new OscMessage("/mono1");
    msg.add(state);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Mono 1 = " + state);
}

void sendMono2Message(String state) {
    OscMessage msg = new OscMessage("/mono2");
    msg.add(state);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Mono 2 = " + state);
}

void sendVolume1Message(float value) {
    OscMessage msg = new OscMessage("/volume1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Volume1 = " + value);
}

void sendVolume2Message(float value) {
    OscMessage msg = new OscMessage("/volume2");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Volume2 = " + value);
}

void sendLPF1Message(float value) {
    OscMessage msg = new OscMessage("/LPF1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: LPF1 = " + value);
}

void sendLPF2Message(float value) {
    OscMessage msg = new OscMessage("/LPF2");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: LPF2 = " + value);
}

void sendBPMMessage(float value) {
    OscMessage msg = new OscMessage("/BPM");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: BPM = " + value);
}

void sendVocoderVolumeMessage(float value) {
    OscMessage msg = new OscMessage("/vocoderVolume");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Vocoder Volume = " + value);
}

void sendGUIMessage(String state) {
    OscMessage msg = new OscMessage("/guiVocoder");
    msg.add(state);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: GUI Vocoder = " + state);
}

// Funzione per inviare un messaggio OSC con l'ottava selezionata
void sendOctave1Message(int octave1) {
    OscMessage msg = new OscMessage("/selectOctave1");
    msg.add(octave1);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Octave 1 = " + octave1);
}

void sendOctave2Message(int octave2) {
    OscMessage msg = new OscMessage("/selectOctave2");
    msg.add(octave2);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Octave 2 = " + octave2);
}

void sendControlPedal1Message(String controlPedal1) {
    OscMessage msg = new OscMessage("/selectControlPedal1");
    msg.add(controlPedal1);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Control Pedal 1 = " + controlPedal1);
}

void sendControlPedal2Message(String controlPedal2) {
    OscMessage msg = new OscMessage("/selectControlPedal2");
    msg.add(controlPedal2);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Control Pedal 2 = " + controlPedal2);
}

void sendAccelerometerXMessage(String accelerometerX) {
    OscMessage msg = new OscMessage("/selectAccelerometerX");
    msg.add(accelerometerX);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Accelerometer X = " + accelerometerX);
}

void sendAccelerometerYMessage(String accelerometerY) {
    OscMessage msg = new OscMessage("/selectAccelerometerY");
    msg.add(accelerometerY);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Accelerometer Y = " + accelerometerY);
}

// ----------------------- RICEZIONE MESSAGGI OSC DA SUPERCOLLIDER ----------------------------------
void oscEvent(OscMessage theOscMessage) {
    String addr = theOscMessage.addrPattern();
    println("Messaggio OSC ricevuto: " + addr); // Log per vedere se il messaggio viene ricevuto
    if (addr.equals("/volume1")) {
        float value = theOscMessage.get(0).floatValue();
        volume1Knob.setValue(value);
        println("Ricevuto volume1: " + value);
    } else if (addr.equals("/volume2")) {
        float value = theOscMessage.get(0).floatValue();
        volume2Knob.setValue(value);
        println("Ricevuto volume2: " + value);
    } else if (addr.equals("/LPF1")) {
        float value = theOscMessage.get(0).floatValue();
        lpf1Knob.setValue(value);
        println("Ricevuto LPF1: " + value);
    } else if (addr.equals("/LPF2")) {
        float value = theOscMessage.get(0).floatValue();
        lpf2Knob.setValue(value);
        println("Ricevuto LPF2: " + value);
    }
}
