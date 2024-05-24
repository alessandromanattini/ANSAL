// =========================================================================================================
// ========================================= ARDUINO COMMUNICATION =========================================
// =========================================================================================================


(

// ------------------------------------------ Initialize Variables -----------------------------------------

var processSerialData, previous, previousRoll, numPrevious, numPreviousRoll, averageOrder, buffer;
numPrevious = 0;
numPreviousRoll = 0;
averageOrder = 5;
previous = Array.fill(averageOrder, 0);
previousRoll = Array.fill(averageOrder, 0);
buffer = "";
~port;
~lpfFrequency = 3000;
~currentPitchBend = 0;

// ---------------------------------------- Glove X and Y axis Mapping --------------------------------------

~mapPitchToFrequency = { |pitch|                                          // Map pitch to the LPF cut freq
    var average, value;

    (1..averageOrder - 1).do { |i|                                        // Shift elements in the 'previous' array to make room for the new pitch
        previous[i - 1] = previous[i];
    };
    previous[averageOrder - 1] = pitch;                                   // Assign the pitch to the last element of the array

    if (numPrevious < averageOrder) {                                     // Update the count of valid elements in the 'previous' array
        numPrevious = numPrevious + 1;
    };
    average = previous[0..(numPrevious - 1)].sum / numPrevious;           // Calculate the average of the valid elements in the 'previous' array
    if (average < -30) {
		value = 1;
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


~mapRollToPitchWheel = { |roll|                                           // Function to map roll to the pitch wheel value
    var average, pitchWheelValue;


    (1..averageOrder - 1).do { |i|                                        // Shift elements in the 'previousRoll' array to make room for the new roll
        previousRoll[i - 1] = previousRoll[i];
    };

    previousRoll[averageOrder - 1] = roll;                                // Assign the roll to the last element of the array


    if (numPreviousRoll < averageOrder) {                                 // Update the count of valid elements in the 'previousRoll' array
        numPreviousRoll = numPreviousRoll + 1;
    };


    average = previousRoll[0..(numPreviousRoll - 1)].sum / numPreviousRoll;      // Calculate the average of the valid elements in the 'previousRoll' array

    if (average < -40) {
        pitchWheelValue = -8192;                                          // Pitch wheel at -2 semitones
    } {
        if (average < -20) {
            pitchWheelValue = average.linlin(-40, -20, -8192, 0);         // Map between -2 and 0 semitones
        } {
            if (average < 20) {
                pitchWheelValue = 0;                                      // Pitch wheel at 0 semitones
            } {
                if (average < 40) {
                    pitchWheelValue = average.linlin(20, 40, 0, 8191);    // Map between 0 and +2 semitones
                } {
                    pitchWheelValue = 8191;                               // Pitch wheel at +2 semitones
                };
            };
        };
    };
    MIDIdef.bend(\pitchWheelHandler).func.value(pitchWheelValue, 0);      // Call the MIDIdef.bend function to update the pitch bend
};

processSerialData = { |data|                                              // Function to process the received serial data
    var angles;

    angles = data.split($,) ;                                             // Data is received as a string, so split the angles using a comma
    if (angles.size == 2) {
        ~mapPitchToFrequency.value(angles[0].asFloat);
        ~mapRollToPitchWheel.value(angles[1].asFloat);
    };
};

// ---------------------------------------- Arduino Connection Management --------------------------------------

~port = SerialPort("COM8", baudrate: 9600);                               // Specify the correct serial port and baud rate

~routine = Routine {                                                      // Continuously read data from the serial port

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
