import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress superCollider;
ControlP5 cp5;

boolean sustainOn = false; // Booleana per il sustain
boolean mono1On = false;
boolean mono2On = false;
String[] instruments = {"None", "everythingrhodes", "distortedTri", "sawtooth", "hammondOrgan", "bass", "violin", "mrostinato", "synchronicity"};
int[] octaves = {0, 1, 2, 3, -1, -2, -3};

int currentInstrumentIndex1 = 0;
Textlabel instrumentLabel1;
int currentInstrumentIndex2 = 0;
Textlabel instrumentLabel2;

int currentOctaveIndex1 = 0;
Textlabel currentOctaveLabel1;
int currentOctaveIndex2 = 0;
Textlabel currentOctaveLabel2;

Knob volume1Knob, lpf1Knob, volume2Knob, lpf2Knob;
Slider bpm;

void setup() {
    size(900, 700);

    oscP5 = new OscP5(this, 12000);
    superCollider = new NetAddress("127.0.0.1", 57120);

    cp5 = new ControlP5(this);
    
    // Slider bpm drums
    bpm = cp5.addSlider("bpmDrums")
        .setPosition(50, 500)
        .setSize(400, 50)
        .setLabel("BPM")
        .setRange(80, 300)
        .setValue(128)
        .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendBPMMessage(value);
            }
        });
    
    // Bottoni Mono1
    cp5.addButton("Mono1")
       .setPosition(350, 100)
       .setSize(100, 50)
       .setLabel("Mono1")
       .setColorBackground(color(255, 0, 0))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                mono1On = !mono1On;
                sendMono1Message(mono1On ? "on" : "off");
                event.getController().setColorBackground(mono1On ? color(0, 255, 0) : color(255, 0, 0));
            }
        });
        
    // Knob Volume 1
    volume1Knob = cp5.addKnob("Volume1Knob")
       .setPosition(550, 70)
       .setSize(200, 20)
       .setRadius(50)
       .setRange(0, 1)
       .setValue(0.5)
       .setColorForeground(color(211, 112, 112))
       .setColorBackground(color(240, 201, 201))
       .setColorCaptionLabel(color(20, 20, 20))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendVolume1Message(value);
            }
        });
        
    // Knob LPF 1
    lpf1Knob = cp5.addKnob("LPF1Knob")
       .setPosition(700, 70)
       .setSize(200, 20)
       .setRadius(50)
       .setRange(20, 6000) // Frequenza in Hz
       .setValue(440)
       .setColorForeground(color(211, 112, 112))
       .setColorBackground(color(240, 201, 201))
       .setColorCaptionLabel(color(20, 20, 20))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendLPF1Message(value);
            }
        });

    // Knob Volume 2
    volume2Knob = cp5.addKnob("Volume2Knob")
       .setPosition(550, 270)
       .setSize(200, 20)
       .setRadius(50)
       .setRange(0, 1)
       .setValue(0.5)
       .setColorForeground(color(211, 112, 112))
       .setColorBackground(color(240, 201, 201))
       .setColorCaptionLabel(color(20, 20, 20))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendVolume2Message(value);
            }
        });
        
    // Knob LPF 2
    lpf2Knob = cp5.addKnob("LPF2Knob")
       .setPosition(700, 270)
       .setSize(200, 20)
       .setRadius(50)
       .setRange(200, 6000) // Frequenza in Hz
       .setValue(440)
       .setColorForeground(color(211, 112, 112))
       .setColorBackground(color(240, 201, 201))
       .setColorCaptionLabel(color(20, 20, 20))
       .setColorBackground(color(0, 0, 0))
       .onChange(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                float value = event.getController().getValue();
                sendLPF2Message(value);
            }
        });

    // Selezione dello strumento n.1
    instrumentLabel1 = cp5.addTextlabel("instrumentLabel1")
                        .setPosition(125, 110)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(instruments[currentInstrumentIndex1]);

    cp5.addButton("Avanti1")
       .setPosition(250, 100)
       .setSize(50, 50)
       .setLabel(">")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex1 = (currentInstrumentIndex1 + 1) % instruments.length;
                instrumentLabel1.setText(instruments[currentInstrumentIndex1]);
                sendInstrument1Message(instruments[currentInstrumentIndex1]);
            }
        });

    cp5.addButton("Indietro1")
       .setPosition(50, 100)
       .setSize(50, 50)
       .setLabel("<")
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
                        .setPosition(125, 310)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(instruments[currentInstrumentIndex2]);

    cp5.addButton("Avanti2")
       .setPosition(250, 300)
       .setSize(50, 50)
       .setLabel(">")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex2 = (currentInstrumentIndex2 + 1) % instruments.length;
                instrumentLabel2.setText(instruments[currentInstrumentIndex2]);
                sendInstrument2Message(instruments[currentInstrumentIndex2]);
            }
        });

    cp5.addButton("Indietro2")
       .setPosition(50, 300)
       .setSize(50, 50)
       .setLabel("<")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentInstrumentIndex2 = (currentInstrumentIndex2 - 1 + instruments.length) % instruments.length;
                instrumentLabel2.setText(instruments[currentInstrumentIndex2]);
                sendInstrument2Message(instruments[currentInstrumentIndex2]);
            }
        });

    sendInstrument2Message(instruments[currentInstrumentIndex2]);
    
    // Bottoni Mono2
    cp5.addButton("Mono2")
       .setPosition(350, 300)
       .setSize(100, 50)
       .setLabel("Mono2")
       .setColorBackground(color(255, 0, 0))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                mono2On = !mono2On;
                sendMono2Message(mono2On ? "on" : "off");
                event.getController().setColorBackground(mono2On ? color(0, 255, 0) : color(255, 0, 0));
            }
        });
    
    // Selezione dell'ottava n.1
    currentOctaveLabel1 = cp5.addTextlabel("currentOctaveLabel1")
                        .setPosition(125, 160)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex1]));

    cp5.addButton("AvantiOctave1")
       .setPosition(250, 150)
       .setSize(50, 50)
       .setLabel(">")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex1 = (currentOctaveIndex1 + 1) % octaves.length;
                currentOctaveLabel1.setText(str(octaves[currentOctaveIndex1]));
                sendOctave1Message(octaves[currentOctaveIndex1]);
            }
        });

    cp5.addButton("IndietroOctave1")
       .setPosition(50, 150)
       .setSize(50, 50)
       .setLabel("<")
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
                        .setPosition(125, 360)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(str(octaves[currentOctaveIndex2]));

    cp5.addButton("AvantiOctave2")
       .setPosition(250, 350)
       .setSize(50, 50)
       .setLabel(">")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex2 = (currentOctaveIndex2 + 1) % octaves.length;
                currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
                sendOctave2Message(octaves[currentOctaveIndex2]);
            }
        });

    cp5.addButton("IndietroOctave2")
       .setPosition(50, 350)
       .setSize(50, 50)
       .setLabel("<")
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                currentOctaveIndex2 = (currentOctaveIndex2 - 1 + octaves.length) % octaves.length;
                currentOctaveLabel2.setText(str(octaves[currentOctaveIndex2]));
                sendOctave2Message(octaves[currentOctaveIndex2]);
            }
        });

    sendOctave2Message(octaves[currentOctaveIndex2]);
}

void draw() {
    background(0);
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
