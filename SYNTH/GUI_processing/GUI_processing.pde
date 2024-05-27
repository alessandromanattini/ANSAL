import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress superCollider;
ControlP5 cp5;

// create the logo image
PImage logoRight;
PImage logoLeft;

// boolean variables --> two for the mono buttons, one for the vocoder GUI button
boolean mono1On = false;
boolean mono2On = false;
boolean guiOn = false;

// list of instruments 
String[] instruments = {"NONE", "RHODES1", "RHODES2", "BASSYN1", "BASSYN2", "BASSYN3", 
"BASSIMP", "LEADSCR", "TRIWAVE", "SAWWAVE", "HAMMOND", "VIOLSYN"};

// list of octaves
int[] octaves = {0, 1, 2, 3, -3, -2, -1};

// list of control pedal options
String[] controlPedal = {"NIL", "DIR", "INV"};

// list of accelerometer options
String[] accelerometer = {"NONE", "INS 1", "INS 2", "BOTH"};

// list of presets
String[] presets = {"INTR", "DAFT", "THER", "MONO"};

// Definition of the lists' indeces + text labels
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

int currentPresetIndex = 0;
Textlabel currentPresetLabel;

Textlabel instrument1Text, instrument2Text, octave1Text, octave2Text, bpmText, 
          vocVolumeText, volume1Text, volume2Text, lpf1Text, lpf2Text, controlPedal1Text, 
          controlPedal2Text, xText, yText, presetText;

// Knobs and Sliders definition
Knob volume1Knob, lpf1Knob, volume2Knob, lpf2Knob;
Slider bpm, vocoderVolume;

void setup() {
    size(925, 850);
    
    // define the net address with the IP and the number of the port
    oscP5 = new OscP5(this, 57121);
    superCollider = new NetAddress("127.0.0.1", 57120);

    cp5 = new ControlP5(this);
    
    // load the logo images
    logoRight = loadImage("ANSAL_LOGO.png");
    logoLeft = loadImage("ANSAL_LOGO.png");

    // Position of the Text Labels
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
                        .setPosition(402.5, 255)
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
                        
    xText = cp5.addTextlabel("ACCELEROMETER_X")
            .setPosition(735, 420)
            .setSize(200, 50)
            .setColorValue(color(255, 255, 255))
            .setFont(createFont("Arial", 15))
            .setText("X AXIS");
          
    yText = cp5.addTextlabel("ACCELEROMETER_Y")
                .setPosition(735, 570)
                .setSize(200, 50)
                .setColorValue(color(255, 255, 255))
                .setFont(createFont("Arial", 15))
                .setText("Y AXIS");

// Here there are the definition of the GUI components. The SEND functions are described below this part.

// -------------------- BPM, VOCODER VOLUME & GUI --------------------------------------

    // Bpm of the Drums sequence Slider --> you can control the bpm of the drum sequence
    bpm = cp5.addSlider("bpmDrums")
        .setPosition(675, 75)
        .setSize(50, 250)
        .setLabel("")
        .setRange(60, 300)
        .setValue(128)
        .setColorForeground(color(128, 122, 122))
        .setColorBackground(color(43, 40, 40))
        .setColorCaptionLabel(color(128, 122, 122))
        
        // When there is a change, send the new value to SC. The logic will be the same for every components.
        .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendBPMMessage(value);   
            }
        });

    // Vocoder Volume's Slider --> you can control the volume of the vocoder
    vocoderVolume = cp5.addSlider("VococerVolume")
                  .setPosition(800, 75)
                  .setSize(50, 250)
                  .setLabel("")
                  .setRange(0, 1)
                  .setValue(0.5)
                  .setColorForeground(color(128, 122, 122))
                  .setColorBackground(color(43, 40, 40))
                  .setColorCaptionLabel(color(128, 122, 122))
                  .onChange(new CallbackListener() {
                      public void controlEvent(CallbackEvent event) {
                          float value = event.getController().getValue();
                          sendVocoderVolumeMessage(value);
                      }
                  });
    
    // Vocoder GUI button --> you can turn on/off the GUI of the vocoder
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

// ----------------------- INSTRUMENT 1 --------------------------------------------------

    // Mono 1 button --> you can put on/off the mono 1 mode
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

    // Volume 1 Knob --> you can control the volume of the first instrument
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

    // Low Pass Filter 1 Knob --> you can control the LPF of the first instrument
    lpf1Knob = cp5.addKnob("LPF1Knob")
       .setPosition(120, 590)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(20, 6000) 
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


    // Instrument 1 selector
    
    // This label allows us you to see the selected instrument
    instrumentLabel1 = cp5.addTextlabel("instrumentLabel1")
                        .setPosition(116, 96)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 12))
                        .setText(instruments[currentInstrumentIndex1]);
     
    // Next instrument button                 
    cp5.addButton("Avanti1")
       .setPosition(200, 75)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       
       // When there is a change, show the next element in the list and send the value to SC. The logic will be the same for 
       // every selector.
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex1 = (currentInstrumentIndex1 + 1) % instruments.length;
                instrumentLabel1.setText(instruments[currentInstrumentIndex1]);
                sendInstrument1Message(instruments[currentInstrumentIndex1]);
            }
        });
    
    // Previous instrument button
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


    // Instrument 1 octave selector
    
    // This label allows us you to see the selected octave
    currentOctaveLabel1 = cp5.addTextlabel("currentOctaveLabel1")
                        .setPosition(140, 193)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex1]));

    // Next octave button
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
    
    // Previous octave button
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


     // Control pedal selector of the first instrument 
    
    // This label allows us you to see the selected control of the pedal
    currentPedalLabel1 = cp5.addTextlabel("ControlPedal1")
                        .setPosition(132.5, 292.5)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(controlPedal[currentPedalIndex1]);
    
    // Next control pedal button
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
    
    // Previous control pedal button
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


    
// ------------------------- INSTRUMENT 2 ---------------------------------------

    // Mono 2 button --> you can put on/off the mono 2 mode
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

    // Volume 2 Knob --> you can control the volume of the second instrument
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

    // Low Pass Filter 2 Knob --> you can control the LPF of the second instrument
    lpf2Knob = cp5.addKnob("LPF2Knob")
       .setPosition(425, 590)
       .setSize(50, 50)
       .setRadius(35)
       .setRange(200, 6000) 
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

    // Instrument 2 selector
    
    // This label allows us you to see the selected instrument 
    instrumentLabel2 = cp5.addTextlabel("instrumentLabel2")
                        .setPosition(416, 95)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 12))
                        .setText(instruments[currentInstrumentIndex2]);
                        
    // Next instrument button
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
        
    // Previous instrument button
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

    // Instrument 2 octave selector
    
    // This label allows us you to see the selected octave
    currentOctaveLabel2 = cp5.addTextlabel("currentOctaveLabel2")
                        .setPosition(440, 193)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex2]));

    // Next octave button
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

    // Previous instrument button
    cp5.addButton("IndietroOctave2")
       .setPosition(350, 175)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("-")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex2 = (currentOctaveIndex2 - 1 + octaves.length) % octaves.length;
                currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
                sendOctave2Message(octaves[currentOctaveIndex2]);
            }
        });

    sendOctave2Message(octaves[currentOctaveIndex2]);

    // Control pedal selector of the second instrument 
    
    // This label allows us you to see the selected control of the pedal
    currentPedalLabel2 = cp5.addTextlabel("ControlPedal2")
                        .setPosition(432.5, 292.5)
                        .setSize(200, 50)
                        .setColorValue(color(255, 255, 255))
                        .setFont(createFont("Arial", 15))
                        .setText(controlPedal[currentPedalIndex2]);

    // Next control pedal button
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

    // Previous control pedal button
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
    
// ----------------------- ACCELEROMETER ----------------------------------------    

    // Accelerometer X axis selector
    
    // This label allows you to see the selected X axis parameter
    currentXLabel = cp5.addTextlabel("currentXLabel")
                    .setPosition(740, 470)
                    .setSize(200, 50)
                    .setColorValue(color(255, 255, 255))
                    .setFont(createFont("Arial", 15))
                    .setText(accelerometer[currentXIndex]);

    // Next X axis parameter button
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

    // previous X axis parameter button
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

    // Accelerometer X axis selector
    
    // This label allows you to see the selected Y axis parameter
    currentYLabel = cp5.addTextlabel("currentYLabel")
                    .setPosition(740, 620)
                    .setSize(200, 50)
                    .setColorValue(color(255, 255, 255))
                    .setFont(createFont("Arial", 15))
                    .setText(accelerometer[currentYIndex]);

    // Next Y axis parameter button
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

    // Previous Y axis parameter button
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
    
    
// ---------------------------- PRESET ----------------------------------------
    
    // Preset selector
    
    // This label allows you to see the selected preset
    currentPresetLabel = cp5.addTextlabel("currentPresetLabel")
                            .setPosition(423, 757.5)
                            .setSize(200, 50)
                            .setColorValue(color(255, 255, 255))
                            .setFont(createFont("Arial", 15))
                            .setText(presets[currentPresetIndex]);
    
    // Next preset button
    cp5.addButton("NextPreset")
       .setPosition(500, 737.5)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("NEXT")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPresetIndex = (currentPresetIndex + 1) % presets.length;
                currentPresetLabel.setText(presets[currentPresetIndex]);
                sendPresetMessage(presets[currentPresetIndex]);
            }
        });
    
    // Previous preset button
    cp5.addButton("PrevPreset")
       .setPosition(350, 737.5)
       .setSize(50, 50)
       .setColorBackground(color(128, 122, 122))
       .setColorCaptionLabel(color(43, 40, 40))
       .setLabel("PREV")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentPresetIndex = (currentPresetIndex - 1 + presets.length) % presets.length;
                currentPresetLabel.setText(presets[currentPresetIndex]);
                sendPresetMessage(presets[currentPresetIndex]);
            }
        });
    
    sendPresetMessage(presets[currentPresetIndex]);

    // white rectangles around the components
    noFill(); // Disable the filling of shapes
    stroke(color(255, 255, 255)); // Set the stroke (border) color to black
    strokeWeight(2); // Set the stroke weight to 2 pixels
}

void draw() {
    background(0);
    
    // Draw the rectangles with given coordinates
    rect(25, 25, 250, 650);
    rect(325, 25, 250, 650);
    rect(625, 25, 275, 350);
    rect(625, 400, 275, 125);
    rect(625, 550, 275, 125);
    rect(325, 700, 250, 125);
    
    // Scale the images and add it in the GUI
    float logoWidthRight = logoRight.width * 0.3;  // Scale down the width to 30%
    float logoHeightRight = logoRight.height * 0.3;  // Scale down the height to 30%
    image(logoRight, 65, 675, logoWidthRight, logoHeightRight);
    
    float logoWidthLeft = logoRight.width * 0.3;  
    float logoHeightLeft = logoRight.height * 0.3;  
    image(logoLeft, 680, 675, logoWidthLeft, logoHeightLeft);
}

// --------------------------------- SEND OSC MESSAGES FUNCTIONS -------------------------------------------

// These functions allow you to change the sound by changing the value from the GUI. When a parameter changes, these functions send an OSC
//  message to SC with the chosen value.

// This function sends an OSC message to SC with the selected first instrument
void sendInstrument1Message(String instrument1) {
    if (instrument1 != null && instrument1.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_instOne");
        msg.add(instrument1);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Instrument1 = " + instrument1);
    } else {
        println("Errore: Instrument1 non è valido");
    }
}

// This function sends an OSC message to SC with the selected second instrument
void sendInstrument2Message(String instrument2) {
    if (instrument2 != null && instrument2.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_instTwo");
        msg.add(instrument2);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Instrument2 = " + instrument2);
    } else {
        println("Errore: Instrument2 non è valido");
    }
}

// This function sends an OSC message to SC with the mono 1 state
void sendMono1Message(String state) {
    if (state != null && (state.equals("on") || state.equals("off"))) {
        OscMessage msg = new OscMessage("/cmd_monoOne");
        msg.add(state);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Mono 1 = " + state);
    } else {
        println("Errore: Stato Mono 1 non valido");
    }
}

// This function sends an OSC message to SC with the mono 2 state
void sendMono2Message(String state) {
    if (state != null && (state.equals("on") || state.equals("off"))) {
        OscMessage msg = new OscMessage("/cmd_monoTwo");
        msg.add(state);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Mono 2 = " + state);
    } else {
        println("Errore: Stato Mono 2 non valido");
    }
}

// This function sends an OSC message to SC with the volume value of the first instrument
void sendVolume1Message(float value) {
    OscMessage msg = new OscMessage("/cmd_volume1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Volume1 = " + value);
}

// This function sends an OSC message to SC with the volume value of the second instrument
void sendVolume2Message(float value) {
    OscMessage msg = new OscMessage("/cmd_volume2");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Volume2 = " + value);
}

// This function sends an OSC message to SC with the LPF value of the first instrument
void sendLPF1Message(float value) {
    OscMessage msg = new OscMessage("/cmd_LPF1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: LPF1 = " + value);
}

// This function sends an OSC message to SC with the LPF value of the second instrument
void sendLPF2Message(float value) {
    OscMessage msg = new OscMessage("/cmd_LPF2");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: LPF2 = " + value);
}

// This function sends an OSC message to SC with the BPM value 
void sendBPMMessage(float value) {
    OscMessage msg = new OscMessage("/cmd_bpmDrum");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: BPM = " + value);
}

// This function sends an OSC message to SC with the vocoder's volume value
void sendVocoderVolumeMessage(float value) {
    OscMessage msg = new OscMessage("/cmd_vocAmpBus");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Vocoder Volume = " + value);
}

// This function sends an OSC message to SC with the Vocoder's GUI state
void sendGUIMessage(String state) {
    if (state != null && (state.equals("on") || state.equals("off"))) {
        OscMessage msg = new OscMessage("/cmd_editorOpen");
        msg.add(state);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: GUI Vocoder = " + state);
    } else {
        println("Errore: Stato GUI non valido");
    }
}

// This function sends an OSC message to SC with the selected octave of the first instrument
void sendOctave1Message(int octave1) {
    OscMessage msg = new OscMessage("/cmd_octaveOne");
    msg.add(octave1);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Octave 1 = " + octave1);
}

// This function sends an OSC message to SC with the selected octave of the second instrument
void sendOctave2Message(int octave2) {
    OscMessage msg = new OscMessage("/cmd_octaveTwo");
    msg.add(octave2);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Octave 2 = " + octave2);
}

// This function sends an OSC message to SC with the selected control pedal of the first instrument
void sendControlPedal1Message(String controlPedal1) {
    if (controlPedal1 != null && controlPedal1.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_ccPedalOne");
        msg.add(controlPedal1);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Control Pedal 1 = " + controlPedal1);
    } else {
        println("Errore: Control Pedal 1 non valido");
    }
}

// This function sends an OSC message to SC with the selected control pedal of the second instrument
void sendControlPedal2Message(String controlPedal2) {
    if (controlPedal2 != null && controlPedal2.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_ccPedalTwo");
        msg.add(controlPedal2);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Control Pedal 2 = " + controlPedal2);
    } else {
        println("Errore: Control Pedal 2 non valido");
    }
}

// This function sends an OSC message to SC with the selected X axis parameter of the accelerometer
void sendAccelerometerXMessage(String accelerometerX) {
    if (accelerometerX != null && accelerometerX.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_gloveX");
        msg.add(accelerometerX);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Accelerometer X = " + accelerometerX);
    } else {
        println("Errore: Accelerometer X non valido");
    }
}

// This function sends an OSC message to SC with the selected Y axis parameter of the accelerometer
void sendAccelerometerYMessage(String accelerometerY) {
    if (accelerometerY != null && accelerometerY.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_gloveY");
        msg.add(accelerometerY);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Accelerometer Y = " + accelerometerY);
    } else {
        println("Errore: Accelerometer Y non valido");
    }
}

// This function sends an OSC message to SC with the selected preset
void sendPresetMessage(String preset) {
    if (preset != null && preset.length() > 0) {
        OscMessage msg = new OscMessage("/cmd_currentPreset");
        msg.add(preset);
        oscP5.send(msg, superCollider);
        println("Messaggio OSC inviato a SuperCollider: Preset = " + preset);
    } else {
        println("Errore: Preset non valido");
    }
}

// ----------------------- RECEIVE OSC MESSAGES FUNCTIONS ----------------------------------

// This functions allow the GUI to change dynamically. The logic is the same for every function : 
//Processing receive an OSC message from SC, read the message and the value contained in it,
// and set the value in the GUI component in order to change it.

// This is useful when you move a knob/fader and when you change the preset.

void oscEvent(OscMessage theOscMessage) {
    String addr = theOscMessage.addrPattern();
    println("Messaggio OSC ricevuto: " + addr);
    
    if (addr.equals("/cmd_volume1")) {
        float value = theOscMessage.get(0).floatValue();
        volume1Knob.setValue(value);
        println("Ricevuto volume1: " + value);
        
    } else if (addr.equals("/cmd_volume2")) {
        float value = theOscMessage.get(0).floatValue();
        volume2Knob.setValue(value);
        println("Ricevuto volume2: " + value);
        
    } else if (addr.equals("/cmd_LPF1")) {
        float value = theOscMessage.get(0).floatValue();
        lpf1Knob.setValue(value);
        println("Ricevuto LPF1: " + value);
        
    } else if (addr.equals("/cmd_LPF2")) {
        float value = theOscMessage.get(0).floatValue();
        lpf2Knob.setValue(value);
        println("Ricevuto LPF2: " + value);
        
    } else if (addr.equals("/cmd_bpmDrum")) {
        float value = theOscMessage.get(0).floatValue();
        bpm.setValue(value);
        println("Ricevuto BPM: " + value);
        
    } else if (addr.equals("/cmd_vocAmpBus")) {
        float value = theOscMessage.get(0).floatValue();
        vocoderVolume.setValue(value);
        println("Ricevuto Vocoder Volume: " + value);
        
    } else if (addr.equals("/cmd_instOne")) {
        String instrument1 = theOscMessage.get(0).stringValue();
        currentInstrumentIndex1 = findInstrumentIndex(instrument1);
        instrumentLabel1.setText(instruments[currentInstrumentIndex1]);
        println("Ricevuto Instrument 1: " + instrument1);
        
    } else if (addr.equals("/cmd_instTwo")) {
        String instrument2 = theOscMessage.get(0).stringValue();
        currentInstrumentIndex2 = findInstrumentIndex(instrument2);
        instrumentLabel2.setText(instruments[currentInstrumentIndex2]);
        println("Ricevuto Instrument 2: " + instrument2);
        
    } else if (addr.equals("/cmd_octaveOne")) {
        int octave1 = theOscMessage.get(0).intValue();
        currentOctaveIndex1 = findOctaveIndex(octave1);
        currentOctaveLabel1.setText(str(octaves[currentOctaveIndex1]));
        println("Ricevuto Octave 1: " + octave1);
        
    } else if (addr.equals("/cmd_octaveTwo")) {
        int octave2 = theOscMessage.get(0).intValue();
        currentOctaveIndex2 = findOctaveIndex(octave2);
        currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
        println("Ricevuto Octave 2: " + octave2);
        
    } else if (addr.equals("/cmd_ccPedalOne")) {
        String controlPedal1 = theOscMessage.get(0).stringValue();
        currentPedalIndex1 = findControlPedalIndex(controlPedal1);
        currentPedalLabel1.setText(controlPedal[currentPedalIndex1]);
        println("Ricevuto Control Pedal 1: " + controlPedal1);
        
    } else if (addr.equals("/cmd_ccPedalTwo")) {
        String controlPedal2 = theOscMessage.get(0).stringValue();
        currentPedalIndex2 = findControlPedalIndex(controlPedal2);
        currentPedalLabel2.setText(controlPedal[currentPedalIndex2]);
        println("Ricevuto Control Pedal 2: " + controlPedal2);
        
    } else if (addr.equals("/cmd_gloveX")) {
        String accelerometerX = theOscMessage.get(0).stringValue();
        currentXIndex = findAccelerometerIndex(accelerometerX);
        currentXLabel.setText(accelerometer[currentXIndex]);
        println("Ricevuto Accelerometer X: " + accelerometerX);
        
    } else if (addr.equals("/cmd_gloveY")) {
        String accelerometerY = theOscMessage.get(0).stringValue();
        currentYIndex = findAccelerometerIndex(accelerometerY);
        currentYLabel.setText(accelerometer[currentYIndex]);
        println("Ricevuto Accelerometer Y: " + accelerometerY);
        
    } else if (addr.equals("/cmd_monoOne")) {
        String state = theOscMessage.get(0).stringValue();
        mono1On = state.equals("on");
        println("Ricevuto Mono 1: " + state);
        cp5.getController("Mono1").setColorBackground(mono1On ? color(0, 205, 70) : color(124, 18, 18));
        
    } else if (addr.equals("/cmd_monoTwo")) {
        String state = theOscMessage.get(0).stringValue();
        mono2On = state.equals("on");
        println("Ricevuto Mono 2: " + state);
        cp5.getController("Mono2").setColorBackground(mono2On ? color(0, 205, 70) : color(124, 18, 18));
        
    } else if (addr.equals("/cmd_editorOpen")) {
        String state = theOscMessage.get(0).stringValue();
        guiOn = state.equals("on");
        println("Ricevuto Gui Vocoder: " + state);  
        cp5.getController("GUI").setColorBackground(guiOn ? color(0, 205, 70) : color(124, 18, 18));
        
    } else if (addr.equals("/cmd_currentPreset")) {
        String preset = theOscMessage.get(0).stringValue();
        currentPresetIndex = findPresetIndex(preset);
        currentPresetLabel.setText(presets[currentPresetIndex]);
        println("Ricevuto Preset: " + preset);
    }
}

// This function allows you to find the index of the instrument in the list
int findInstrumentIndex(String instrument) {
    for (int i = 0; i < instruments.length; i++) {
        if (instruments[i].equals(instrument)) {
            return i;
        }
    }
    return 0; // Default to the first instrument if not found
}

// This function allows you to find the index of the octave in the list
int findOctaveIndex(int octave) {
    for (int i = 0; i < octaves.length; i++) {
        if (octaves[i] == octave) {
            return i;
        }
    }
    return 0; // Default to the first octave if not found
}

// This function allows you to find the index of the control pedal in the list
int findControlPedalIndex(String controlPedalValue) {
    for (int i = 0; i < controlPedal.length; i++) {
        if (controlPedal[i].equals(controlPedalValue)) {
            return i;
        }
    }
    return 0; // Default to the first control pedal parameter if not found
}

// This function allows you to find the index of the accelerometer parameter in the list
int findAccelerometerIndex(String accelerometerValue) {
    for (int i = 0; i < accelerometer.length; i++) {
        if (accelerometer[i].equals(accelerometerValue)) {
            return i;
        }
    }
    return 0; // Default to the first accelerometer parameter if not found
}

// This function allows you to find the index of the preset in the list
int findPresetIndex(String preset) {
    for (int i = 0; i < presets.length; i++) {
        if (presets[i].equals(preset)) {
            return i;
        }
    }
    return 0; // Default to the first preset if not found
}
