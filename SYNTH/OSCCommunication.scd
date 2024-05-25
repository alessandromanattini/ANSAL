// ============================================================================================================================
// ============================================== SC GUI COMMUNICATION MANAGEMENT =============================================
// ============================================================================================================================

(

// ----------------------------------------- Create a network address for Processing -----------------------------------------

~processingAddr = NetAddr("127.0.0.1", 57121);

// ---------------------------------------------------- Receiving Messages ----------------------------------------------------

OSCdef(\cmd_instOne, { |msg, time, addr, recvPort|                   // OSC handler for instrument selection message
    var instrument;
    instrument = msg[1].asString;
    ~instOne = case
    { instrument == "RHODES1" } { \RHODES1 }
    { instrument == "RHODES2" } { \RHODES2 }
    { instrument == "BASSYN1" } { \BASSYN1 }
    { instrument == "LEADSCR" } { \LEADSCR }
    { instrument == "TRIWAVE" } { \TRIWAVE }
    { instrument == "SAWWAVE" } { \SAWWAVE }
    { instrument == "HAMMOND" } { \HAMMOND }
    { instrument == "VIOLSYN" } { \VIOLSYN }
    { instrument == "BASSYN2" } { \BASSYN2 }
    { instrument == "BASSIMP" } { \BASSIMP }
    { \NONE  };
}, '/cmd_instOne');

OSCdef(\cmd_instTwo, { |msg, time, addr, recvPort|
    var instrument;
    instrument = msg[1].asString;
    ~instTwo = case
    { instrument == "RHODES1" } { \RHODES1 }
    { instrument == "RHODES2" } { \RHODES2 }
    { instrument == "BASSYN1" } { \BASSYN1 }
	{ instrument == "BASSYN2" } { \BASSYN2 }
	{ instrument == "BASSYN3" } { \BASSYN3 }
    { instrument == "LEADSCR" } { \LEADSCR }
    { instrument == "TRIWAVE" } { \TRIWAVE }
    { instrument == "SAWWAVE" } { \SAWWAVE }
    { instrument == "HAMMOND" } { \HAMMOND }
    { instrument == "VIOLSYN" } { \VIOLSYN }
    { instrument == "BASSIMP" } { \BASSIMP }
    { \NONE };
}, '/cmd_instTwo');


OSCdef(\cmd_monoOne, { |msg|                                         // OSC handler for mono
    var state;
    state = msg[1].asString;
    if (state == "on") {
        ~monoOne = true;
    } {
        if(state == "off") {
            ~monoOne = false;
        };
    };
}, '/cmd_monoOne');

OSCdef(\cmd_monoTwo, { |msg|
    var state;
    state = msg[1].asString;

    if (state == "on") {
        ~monoTwo = true;
    } {
        if(state == "off") {
            ~monoTwo= false;
        };
    };
}, '/cmd_monoTwo');


OSCdef(\cmd_volume1, { |msg|                                         // OSC handler for volume
    ~volumeOne = msg[1].asFloat;
}, '/cmd_volume1');

OSCdef(\cmd_volume2, { |msg|
    ~volumeTwo = msg[1].asFloat;
}, '/cmd_volume2');


OSCdef(\cmd_LPF1, { |msg|                                            // OSC handler for low-pass filter (LPF)
    ~lpfFreq1 = msg[1].asFloat;
}, '/cmd_LPF1');

OSCdef(\cmd_LPF2, { |msg|
    ~lpfFreq2 = msg[1].asFloat;
}, '/cmd_LPF2');


OSCdef(\cmd_bpmDrum, { |msg|                                         // OSC handler for BPM drum sequence
    ~bpmDrum = msg[1].asFloat;
    ~processingAddr.sendMsg('/BPM', ~bpmDrum);
}, '/cmd_bpmDrum');


OSCdef(\cmd_octaveOne, { |msg|                                       // OSC handler for octave selection
    var octave = msg[1].asInt;
    switch(octave,
        0, {
            ~octaveOne = 1;
        },
        1, {
            ~octaveOne = 2;
        },
        2, {
            ~octaveOne = 4;
        },
        3, {
            ~octaveOne = 8;
        },
        -1, {
            ~octaveOne = 1/2;
        },
        -2, {
            ~octaveOne = 1/4;
        },
        -3,{
            ~octaveOne = 1/8;
        }
    );
}, '/cmd_octaveOne');

OSCdef(\cmd_octaveTwo, { |msg|
    var octave = msg[1].asInt;
    switch(octave,
        0, {
            ~octaveTwo = 1;
        },
        1, {
            ~octaveTwo = 2;
        },
        2, {
            ~octaveTwo = 4;
        },
        3, {
            ~octaveTwo = 8;
        },
        -1, {
            ~octaveTwo = 1/2;
        },
        -2, {
            ~octaveTwo = 1/4;
        },
        -3,{
            ~octaveTwo = 1/8;
        }
    );
}, '/cmd_octaveTwo');


OSCdef(\cmd_editorOpen, { |msg|                                      // OSC handler for the Vocoder
    ~toggleEditor.value;
}, '/cmd_editorOpen');

OSCdef(\cmd_vocAmpBus, { |msg|
    var volume = msg[1].asFloat;
    ~vocAmpBus.set(volume/2);
	~vocoderVolume=volume;
}, '/cmd_vocAmpBus');


OSCdef(\cmd_ccPedalOne, { |msg|                                      // OSC handler for control pedal mapping
    var mode = msg[1].asString;
    switch(mode,
        "NIL", {
            ~ccPedalOne = 0;
        },
        "DIR", {
            ~ccPedalOne = 1;
        },
        "INV", {
            ~ccPedalOne = -1;
        }
    );
}, '/cmd_ccPedalOne');

OSCdef(\cmd_ccPedalTwo, { |msg|
    var mode = msg[1].asString;
    switch(mode,
        "NIL", {
            ~ccPedalTwo = 0;
        },
        "DIR", {
            ~ccPedalTwo = 1;
        },
        "INV", {
            ~ccPedalTwo = -1;
        }
    );
}, '/cmd_ccPedalTwo');


OSCdef(\cmd_gloveX, { |msg|                                          // OSC handler for glove mapping
    var mode = msg[1].asString;
    switch(mode,
        "NONE", {
            ~gloveXOne = false;
            ~gloveXTwo = false;
        },
        "INS 1", {
            ~gloveXOne = true;
            ~gloveXTwo = false;
        },
        "INS 2", {
            ~gloveXOne = false;
            ~gloveXTwo = true;
        },
        "BOTH", {
            ~gloveXOne = true;
            ~gloveXTwo = true;
        }
    );
}, '/cmd_gloveX');

OSCdef(\cmd_gloveY, { |msg|
    var mode = msg[1].asString;
    switch(mode,
        "NONE", {
            ~gloveYOne = false;
            ~gloveYTwo = false;
        },
        "INS 1", {
            ~gloveYOne = true;
            ~gloveYTwo = false;
        },
        "INS 2", {
            ~gloveYOne = false;
            ~gloveYTwo = true;
        },
        "BOTH", {
            ~gloveYOne = true;
            ~gloveYTwo = true;
        }
    );
}, '/cmd_gloveY');


OSCdef(\cmd_currentPreset, { |msg|                                   // OSC handler for preset selection
    var mode = msg[1].asString;
    switch(mode,
        "INTR", {
            ~setModelParameters.value(~intro);
        },
		"MONO", {
            ~setModelParameters.value(~mono);
        },
		"THER", {
            ~setModelParameters.value(~ther);
        },
        "DAFT", {
            ~setModelParameters.value(~daftPunk);
        };
    );
}, '/cmd_currentPreset');


// ---------------------------------------------------- Sending Messages ----------------------------------------------------


~updateGUI = {
    var message;

    ~busOne.get { |value| ~processingAddr.sendMsg('/cmd_volume1', value);};          	// Sending instrument volumes
    ~busTwo.get { |value| ~processingAddr.sendMsg('/cmd_volume2', value);};

    ~lowPassFilterOne.get { |value| ~processingAddr.sendMsg('/cmd_LPF1', value);};    	// Sending LPF cutoff frequencies
    ~lowPassFilterTwo.get { |value| ~processingAddr.sendMsg('/cmd_LPF2', value);};

    ~processingAddr.sendMsg('/cmd_currentPreset', ~currentPreset); 	                    // Sending the currently selected preset

    ~processingAddr.sendMsg('/cmd_instOne', ~instOne);                              	// Sending selected instruments
    ~processingAddr.sendMsg('/cmd_instTwo', ~instTwo);

	if(~monoOne){~processingAddr.sendMsg('/cmd_monoOne', "on".asString);}               // Sending Mono status for both instruments
	{~processingAddr.sendMsg('/cmd_monoOne', "off".asString);};
	if(~monoTwo){~processingAddr.sendMsg('/cmd_monoTwo', "on".asString);}
	{~processingAddr.sendMsg('/cmd_monoTwo', "off".asString);};

	~processingAddr.sendMsg('/cmd_bpmDrum', ~bpmDrum.asFloat);                          // Sending BPM of the drum

    message = if (~gloveXOne and: ~gloveXTwo) {                                         // Sending current glove mapping
        "BOTH".asString;
    } {
        if (~gloveXOne) {
            "INS 1".asString;
        } {
            if (~gloveXTwo) {
                "INS 2".asString;
            } {
                "NONE".asString;
            };
        };
    };
    ~processingAddr.sendMsg('/cmd_gloveX', message);

    message = if (~gloveYOne and: ~gloveYTwo) {
        "BOTH".asString;
    } {
        if (~gloveYOne) {
            "INS 1".asString;
        } {
            if (~gloveYTwo) {
                "INS 2".asString;
            } {
                "NONE".asString;
            };
        };
    };
    ~processingAddr.sendMsg('/cmd_gloveY', message);

    ~processingAddr.sendMsg('/cmd_vocAmpBus', ~vocoderVolume);                          // Sending current Vocoder status

	if(~editorOpen){
		~processingAddr.sendMsg('/cmd_editorOpen', "on".asString);

	}{
		~processingAddr.sendMsg('/cmd_editorOpen', "off".asString);
	};

    message = case                                                                      // Sending control pedal mapping
    { ~ccPedalOne == 0 } { "NIL".asString }
    { ~ccPedalOne == 1 } { "DIR".asString }
    { ~ccPedalOne == -1 } { "INV".asString }
    { "UNKNOWN" };
    ~processingAddr.sendMsg('/cmd_ccPedalOne', message);

    message = case
    { ~ccPedalTwo == 0 } { "NIL".asString }
    { ~ccPedalTwo == 1 } { "DIR".asString }
    { ~ccPedalTwo == -1 } { "INV".asString }
    { "UNKNOWN" };
    ~processingAddr.sendMsg('/cmd_ccPedalTwo', message);

    message = case                                                                      // Sending selected octave shift
    { ~octaveOne == 1 } { 0.asInteger }
    { ~octaveOne == 2 } { 1.asInteger }
    { ~octaveOne == 4 } { 2.asInteger }
    { ~octaveOne == 8 } { 3.asInteger }
    { ~octaveOne == 0.5 } { -1.asInteger }
    { ~octaveOne == 0.25 } { -2.asInteger }
    { ~octaveOne == 0.125 } { -3.asInteger }
    { -99 };
    ~processingAddr.sendMsg('/cmd_octaveOne', message);

    message = case
    { ~octaveTwo == 1 } { 0.asInteger }
    { ~octaveTwo == 2 } { 1.asInteger }
    { ~octaveTwo == 4 } { 2.asInteger }
    { ~octaveTwo == 8 } { 3.asInteger }
    { ~octaveTwo == 0.5 } { -1.asInteger }
    { ~octaveTwo == 0.25 } { -2.asInteger }
    { ~octaveTwo == 0.125 } { -3.asInteger }
    { -99 };
    ~processingAddr.sendMsg('/cmd_octaveTwo', message);
};

~guiRoutine = Routine {                                              // Routine to perform GUI update at regular intervals
    loop {
        ~updateGUI.value;
        0.1.wait;
    }
}.play(TempoClock.default);

)
