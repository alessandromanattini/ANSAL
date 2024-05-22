(
var processSerialData, previous, previousRoll, numPrevious, numPreviousRoll, averageOrder, buffer;
numPrevious = 0;
numPreviousRoll = 0;
averageOrder = 5;
previous = Array.fill(averageOrder, 0);
previousRoll = Array.fill(averageOrder, 0);
buffer = "";  // Inizializza il buffer come una stringa vuota

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

    if (average < -30) {
		value=1;
    } {
        if (average < 10) {
            value = average.linexp(-30, 10, 1, 127);
        } {
            value = 127;
        };
    };
	if (~gloveYOne){
		~setKnobValue.value(value, 20);
	};
	if (~gloveYTwo){
		~setKnobValue.value(value, 21);
	}
};

// Funzione per mappare il roll al valore del pitch wheel
~mapRollToPitchWheel = { |roll|
    var average, pitchWheelValue;

    // Shift elements in the 'previousRoll' array to make room for the new roll
    (1..averageOrder - 1).do { |i|
        previousRoll[i - 1] = previousRoll[i];
    };

    previousRoll[averageOrder - 1] = roll;  // Assegna il roll all'ultimo elemento dell'array

    // Update the count of valid elements in the 'previousRoll' array
    if (numPreviousRoll < averageOrder) {
        numPreviousRoll = numPreviousRoll + 1;
    };

    // Calculate the average of the valid elements in the 'previousRoll' array
    average = previousRoll[0..(numPreviousRoll - 1)].sum / numPreviousRoll;

    if (average < -40) {
        pitchWheelValue = -8192;  // Pitch wheel a -2 semitoni
    } {
        if (average < -20) {
            pitchWheelValue = average.linlin(-40, -20, -8192, 0);  // Mappa tra -2 e 0 semitoni
        } {
            if (average < 20) {
                pitchWheelValue = 0;  // Pitch wheel a 0 semitoni
            } {
                if (average < 40) {
                    pitchWheelValue = average.linlin(20, 40, 0, 8191);  // Mappa tra 0 e +2 semitoni
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
    var angles;
    // I dati sono ricevuti come una stringa, quindi separiamo gli angoli usando la virgola
    angles = data.split($,) ;
    if (angles.size == 2) {
        ~mapPitchToFrequency.value(angles[0].asFloat);
        ~mapRollToPitchWheel.value(angles[1].asFloat);
    };
};

// Apri la porta seriale
~port = SerialPort("COM8", baudrate: 9600);  // Specifica la porta seriale corretta e il baud rate

// Legge continuamente i dati dalla porta seriale
~routine = Routine {
    inf.do {
        var byte;
        byte = ~port.read;
        if (byte != Char.nl.asInteger) {
            buffer = buffer ++ byte.asAscii;
        } {
            processSerialData.(buffer);
            buffer = "";
        };
    };
}.play;
)
