(
// Inizia la comunicazione seriale
var processSerialData, previous, numPrevious, averageOrder;
numPrevious = 0;
averageOrder = 2;
previous = Array.fill(averageOrder, 0);

~port;
~lpfFrequency = 3000;  // Valore iniziale della frequenza di taglio del filtro
~currentPitchBend = 0;

// Funzione per mappare il pitch alla frequenza di taglio del filtro passa-basso
~mapPitchToFrequency = { |pitch|
    var average, value;

    // Shift elements in the 'previous' array to make room for the new pitch
    (1..averageOrder - 1).do { |i|
        previous[i - 1] = previous[i];
    };

    previous[averageOrder - 1] = pitch;  // Assegna il pitch all'ultimo elemento dell'array

    // Update the count of valid elements in the 'previous' array
    if (numPrevious < averageOrder) {
        numPrevious = numPrevious + 1;
    };

    // Calculate the average of the valid elements in the 'previous' array
    average = previous[0..(numPrevious - 1)].sum / numPrevious;

    if (average < -15) {
        ~setKnobValue.value(1, 21);
    } {
        if (average < 10) {
            value = average.linexp(-12, 15, 1, 127);
            ~setKnobValue.value(value, 21);
        } {
            ~setKnobValue.value(127, 21);
        };
    };
};

// Funzione per mappare il roll al valore del pitch wheel
~mapRollToPitchWheel = { |roll|
    var pitchWheelValue;
    if (roll < -20) {
        pitchWheelValue = -8192;  // Pitch wheel a -2 semitoni
    } {
        if (roll < -15) {
            pitchWheelValue = ((roll).linlin(-20, -15, -8192, 0));  // Mappa tra -2 e 0 semitoni
        } {
            if (roll < 20) {
                pitchWheelValue = 0;  // Pitch wheel a 0 semitoni
            } {
                if (roll < 40) {
                    pitchWheelValue = ((roll).linlin(20, 40, 0, 8191));  // Mappa tra 0 e +2 semitoni
                } {
                    pitchWheelValue = 8191;  // Pitch wheel a +2 semitoni
                };
            };
        };
    };

    // Chiama la funzione MIDIdef.bend per aggiornare il pitch bend
    MIDIdef.bend(\pitchWheelHandler).func.value(pitchWheelValue, 0);
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
        ~mapPitchToFrequency.value(angleX);
        ~mapRollToPitchWheel.value(angleY);
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