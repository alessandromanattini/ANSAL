// Inizia la comunicazione seriale
SerialPort.listDevices;  // Elenca tutte le porte seriali disponibili

(
var processSerialData;

~port;
~lpfFrequency = 3000;  // Valore iniziale della frequenza di taglio del filtro

// Funzione per mappare il pitch alla frequenza di taglio del filtro passa-basso
~mapPitchToFrequency = { |pitch|
    if (pitch < 20) {
        ^3000;
    } {
        ^((pitch - 20).linexp(20, 30, 3000, 6000));
    };
};

// Funzione per processare i dati seriali ricevuti
processSerialData = { |data|
    var angles, angleX, angleY;
    "Data received: ".post; data.postln; // Debug: stampa i dati ricevuti
    // I dati sono ricevuti come una stringa, quindi separiamo gli angoli usando la virgola
    angles = data.split($,) ;
    if (angles.size == 2) {
        angleX = angles[0].asFloat;
        angleY = angles[1].asFloat;
        // Stampa gli angoli nella post window di SuperCollider
        ("Pitch: " ++ angleX).postln;
        ("Roll: " ++ angleY).postln;

        // Mappa il pitch alla frequenza di taglio del filtro
        ~lpfFrequency = ~mapPitchToFrequency.value(angleX);
        ("LPF Cutoff Frequency: " ++ ~lpfFrequency).postln;

        // Imposta la frequenza di taglio del filtro
        ~lowPassFilterOne.set(~lpfFrequency);
        ~processingAddr.sendMsg('/LPF1', ~lpfFrequency); // Invia messaggio OSC a Processing
        "Inviato messaggio OSC a Processing: /LPF1".postln;
    } {
        ("Invalid data received: " ++ data).postln;
    };
};

// Apri la porta seriale
~port = SerialPort("COM8", baudrate: 9600);  // Specifica la porta seriale corretta e il baud rate

// Legge continuamente i dati dalla porta seriale
~routine = Routine {
    var byte, str;
    inf.do {
        if(~port.read == Char.nl.asInteger) {
            str = "";
            while({
                byte = ~port.read;
                byte != Char.ret.asInteger
            }, {
                str = str ++ byte.asAscii
            });
            processSerialData.(str);
        }
    };
}.play;
)

// Questo avvia la lettura (handshaking con Arduino)
~port.put(0);

// Codice per chiudere la porta seriale
(
if (~port.notNil and: { ~port.isOpen }) {
    ~port.close;
    "Port closed successfully".postln;
} {
    "Port was not open or failed to close".postln;
};
)
