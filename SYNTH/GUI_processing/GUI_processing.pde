import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress superCollider;
ControlP5 cp5;
PImage bgImage;

boolean sustainOn = false; // booleana per il sustain
String[] instruments = {"None", "everythingrhodes","distortedTri","sawtooth","hammondOrgan","bass" ,"violin" ,"mrostinato","synchronicity"};
int currentInstrumentIndex1 = 0;
Textlabel instrumentLabel1;
int currentInstrumentIndex2 = 0;
Textlabel instrumentLabel2;

void setup() {
    size(900, 600);

    oscP5 = new OscP5(this, 12000);
    superCollider = new NetAddress("127.0.0.1", 57110);

    cp5 = new ControlP5(this);
    
//--------------- BOTTONI SUSTAIN ------------------------------------ 
    cp5.addButton("Sustain")
       .setPosition(350, 100)
       .setSize(100, 50)
       .setLabel("Sustain")
       .setColorBackground(color(255, 0, 0))
       .onClick(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
                sustainOn = !sustainOn;
                sendSustainMessage(sustainOn ? "on" : "off");
                event.getController().setColorBackground(sustainOn ? color(0, 255, 0) : color(255, 0, 0));
            }
        });
// ------------------------- KNOB VOLUME ------------------------------------
cp5.addKnob("Volume1Knob")
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
        
// ------------------------- KNOB LPF ------------------------------------
cp5.addKnob("LPF1Knob")
       .setPosition(700, 70)
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
                sendLPF1Message(value);
            }
        });


//--------------- SELEZIONE DELLO STRUMENTO ------------------------------------

// --------------- STRUMENTO n.1 ----------------------------------------------------

// Aggiungi etichetta per visualizzare il nome dello strumento attivo
    instrumentLabel1 = cp5.addTextlabel("instrumentLabel1")
                        .setPosition(125, 110)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(instruments[currentInstrumentIndex1]);

    // Pulsante per scorrere avanti nella lista degli strumenti
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

    // Pulsante per scorrere indietro nella lista degli strumenti
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

    // Invia il messaggio OSC per lo strumento iniziale
    sendInstrument1Message(instruments[currentInstrumentIndex1]);

// --------------- STRUMENTO n.2 ----------------------------------------------------

// Aggiungi etichetta per visualizzare il nome dello strumento attivo
    instrumentLabel2 = cp5.addTextlabel("instrumentLabel2")
                        .setPosition(125, 310)
                        .setSize(200, 50)
                        .setColorValue(color(255,255,255))
                        .setFont(createFont("Arial", 15))
                        .setText(instruments[currentInstrumentIndex2]);

    // Pulsante per scorrere avanti nella lista degli strumenti
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

    // Pulsante per scorrere indietro nella lista degli strumenti
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

    // Invia il messaggio OSC per lo strumento iniziale
    sendInstrument2Message(instruments[currentInstrumentIndex2]);
   
}

void draw() {
    background(0);

}

// Funzione per inviare un messaggio OSC con lo strumento selezionato
void sendInstrument1Message(String instrument1) {
    OscMessage msg = new OscMessage("/selectInstrument1");
    msg.add(instrument1);
    msg.add(1); // Aggiungi qui il numero del bus, ad esempio 1
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Instrument1 = " + instrument1 + ", Bus=1");
}

void sendInstrument2Message(String instrument2) {
    OscMessage msg = new OscMessage("/selectInstrument2");
    msg.add(instrument2);
    msg.add(1); // Aggiungi qui il numero del bus, ad esempio 1
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Instrument2 = " + instrument2 + ", Bus=1");
}

// Funzione per inviare un messaggio OSC per il sustain
void sendSustainMessage(String state) {
    OscMessage msg = new OscMessage("/sustain");
    msg.add(state);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Sustain=" + state);
}

void sendVolume1Message(float value) {
    OscMessage msg = new OscMessage("/volume1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: Volume=" + value);
}
void sendLPF1Message(float value) {
    OscMessage msg = new OscMessage("/LPF1");
    msg.add(value);
    oscP5.send(msg, superCollider);
    println("Messaggio OSC inviato a SuperCollider: LPF 1=" + value);
}
