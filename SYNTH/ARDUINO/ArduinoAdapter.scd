// Inizia la comunicazione seriale
SerialPort.listDevices;  // Elenca tutte le porte seriali disponibili

(
var processSerialData;

~port;

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
