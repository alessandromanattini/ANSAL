// Inizia la comunicazione seriale
SerialPort.listDevices;  // Elenca tutte le porte seriali disponibili

(
var processSerialData, previous, numPrevious, averageOrder;
numPrevious= 0;
averageOrder = 2;
previous = Array.fill(averageOrder, 0);

~port;
~lpfFrequency = 3000;  // Valore iniziale della frequenza di taglio del filtro

// Funzione per mappare il pitch alla frequenza di taglio del filtro passa-basso
~mapPitchToFrequency = { |pitch|
    var average, value;

    // Shift elements in the 'previous' array to make room for the new pitch
	// Eseguire il ciclo per spostare gli elementi dell'array
	(1..averageOrder-1).do { |i|
		previous[i-1] = previous[i];
	};

	previous[averageOrder-1] = pitch;  // Assegna il pitch all'ultimo elemento dell'array


    // Update the count of valid elements in the 'previous' array
    if (numPrevious < averageOrder) {
        numPrevious = numPrevious + 1;
    };

    // Calculate the average of the valid elements in the 'previous' array
    average = previous[0..(numPrevious-1)].sum / numPrevious;

    if (average < -11) {
        ~setKnobValue.value(1, 21);
    } {
        if (average < 15) {
            value = average.linexp(-12, 15, 1, 127);
            ~setKnobValue.value(value, 21);
        } {
            ~setKnobValue.value(127, 21);
        };
    };
};

// Inizia la comunicazione seriale
SerialPort.listDevices;  // Elenca tutte le porte seriali disponibili

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
		~mapPitchToFrequency.value(angleX);
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
