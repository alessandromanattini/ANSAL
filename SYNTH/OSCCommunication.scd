//======================================================================================================
//============================================OSC COMMUNICATION=========================================
//======================================================================================================

(
// Crea un indirizzo di rete per Processing (o qualsiasi altro server OSC)
~processingAddr = NetAddr("127.0.0.1", 12000);

// Variabili globali per il sustain, volume e lpf
~sustainOne = false;
~volumeOne = 0.5;
~lpfFreq1 = 440;



// ----------------------------------------------- INSTRUMENT n.1 ----------------------------------------------------

// Gestore OSC per il messaggio di selezione degli strumenti
OSCdef(\selectInstrument1, { |msg, time, addr, recvPort|
    var instrument;
    instrument = msg[1].asString;

    "Strumento n.1 selezionato: ".post; instrument.postln;

    // Arresta eventuali synth in esecuzione
    /*if (~currentSynth.notNil) {
        ~currentSynth.free;
    };*/

    // Seleziona e avvia il synth in base allo strumento selezionato
    if (instrument == "everythingrhodes") {
        ~instOne = \everythingrhodes;
    };
	if(instrument == "distortedTri") {
		~instOne = \distortedTri;
    };
	if(instrument == "sawtooth") {
		~instOne = \sawtooth;
    };
	if(instrument == "hammondOrgan") {
		~instOne = \hammondOrgan;
    };
	if(instrument == "bass") {
		~instOne = \bass;
    };
	if(instrument == "violin") {
		~instOne = \violin;
    };
	if(instrument == "mrostinato") {
		~instOne = \mrostinato;
    };
	if(instrument == "synchronicity") {
		~instOne = \synchronicity;
    };
	if(instrument == "None") {
		~instOne = nil;
        "Nessuno strumento selezionato.".postln;
    };
}, '/selectInstrument1');

// ----------------------------------------------- INSTRUMENT n.2 ----------------------------------------------------

OSCdef(\selectInstrument2, { |msg, time, addr, recvPort|
    var instrument;
    instrument = msg[1].asString;

    "Strumento n.2 selezionato: ".post; instrument.postln;

    // Arresta eventuali synth in esecuzione
    /*if (~currentSynth.notNil) {
        ~currentSynth.free;
    };*/

    // Seleziona e avvia il synth in base allo strumento selezionato
    if (instrument == "everythingrhodes") {
        ~instTwo = \everythingrhodes;
    };
	if(instrument == "distortedTri") {
		~instTwo = \distortedTri;
    };
	if(instrument == "sawtooth") {
		~instTwo = \sawtooth;
    };
	if(instrument == "hammondOrgan") {
		~instTwo = \hammondOrgan;
    };
	if(instrument == "bass") {
		~instTwo = \bass;
    };
	if(instrument == "violin") {
		~instTwo = \violin;
    };
	if(instrument == "mrostinato") {
		~instTwo = \mrostinato;
    };
	if(instrument == "synchronicity") {
		~instTwo = \synchronicity;
    };
	if(instrument == "None") {
		~instTwo = nil;
        "Nessuno strumento selezionato.".postln;
    };
}, '/selectInstrument2');

// ----------------------------------------------------------------------------------------------------------

// Gestore OSC per il mono
OSCdef(\mono1, { |msg|
    var state;
    state = msg[1].asString;

    if (state == "on") {
        ~monoOne = true;
        "Mono Strumento 1 attivato.".postln;
    };
	if(state == "off") {
        ~monoOne = false;
        "Mono Strumento 1 disattivato.".postln;
    }
}, '/mono1');

OSCdef(\mono2, { |msg|
    var state;
    state = msg[1].asString;

    if (state == "on") {
        ~monoTwo = true;
        "Mono Strumento 2 attivato.".postln;
    };
	if(state == "off") {
        ~monoTwo= false;
        "Mono Strumento 2 disattivato.".postln;
    }  {
        "Stato mono 2 non riconosciuto.".postln;
    }
}, '/mono2');

// ------------------------------------------------------------------------------------------------------------------

// Gestore OSC per il volume
OSCdef(\volume1, { |msg|
    ~volumeOne = msg[1].asFloat;
}, '/volume1');

OSCdef(\volume2, { |msg|
    ~volumeTwo = msg[1].asFloat;
}, '/volume2');

// ------------------------------------------------------------------------------------------------------------------

// Gestore OSC per il filtro passa basso (LPF)
OSCdef(\LPF1, { |msg|
    ~lpfFreq1 = msg[1].asFloat;
}, '/LPF1');

OSCdef(\LPF2, { |msg|
    ~lpfFreq2 = msg[1].asFloat;
}, '/LPF2');

// ------------------------------------------------------------------------------------------------------------------

// Gestore OSC per BPM sequenza percussioni
OSCdef(\BPM, { |msg|
    ~bpmDrum = msg[1].asFloat;
	//int value = ~bpmDrum;
	 ~processingAddr.sendMsg('/BPM', ~bpmDrum); // Invia messaggio OSC a Processing
}, '/BPM');

// ------------------------------------------------------------------------------------------------------------------


// Gestore OSC per la selezione dell'ottava
OSCdef(\selectOctave1, { |msg|
	var octave = msg[1].asInt;  // Usa asInt per convertire il valore in intero
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
}, '/selectOctave1');


OSCdef(\selectOctave2, { |msg|
	var octave = msg[1].asInt;  // Usa asInt per convertire il valore in intero
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
}, '/selectOctave2');

// ------------------------------------------------------------------------------------------------------------------

OSCdef(\guiVocoder, { |msg|
	~toggleEditor.value;
}, '/guiVocoder');

OSCdef(\vocoderVolume, { |msg|
	var volume = msg[1].asFloat;  // Usa asInt per convertire il valore in intero
	~vocAmpBus.set(volume/2);
}, '\vocoderVolume');


OSCdef(\selectControlPedal1, { |msg|
	var mode = msg[1].asString;  // Usa asInt per convertire il valore in intero
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
}, '\selectControlPedal1');

OSCdef(\selectControlPedal2, { |msg|
	var mode = msg[1].asString;  // Usa asInt per convertire il valore in intero
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
}, '\selectControlPedal2');


OSCdef(\selectAccelerometerX, { |msg|
	var mode = msg[1].asString;  // Usa asInt per convertire il valore in intero
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
}, '\selectAccelerometerX');


OSCdef(\selectAccelerometerY, { |msg|
	var mode = msg[1].asString;  // Usa asInt per convertire il valore in intero
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
}, '\selectAccelerometerY');




//_________________________________________________________________________________
~updateGUI = {
	~busOne.get { |value|
		~processingAddr.sendMsg('/volume1', value); // Invia messaggio OSC a Processing con il valore del bus
	};
	~busTwo.get { |value|
		~processingAddr.sendMsg('/volume2', value); // Invia messaggio OSC a Processing con il valore del bus
	};
	~lowPassFilterOne.get { |value|
		~processingAddr.sendMsg('/LPF1', value); // Invia messaggio OSC a Processing con il valore del bus
	};
	~lowPassFilterTwo.get { |value|
		~processingAddr.sendMsg('/LPF2', value); // Invia messaggio OSC a Processing con il valore del bus
	};
};

// Routine per eseguire l'aggiornamento GUI a intervalli regolari
~guiRoutine = Routine {
	loop {
		~updateGUI.value;
		0.1.wait; // Intervallo di 0.1 secondi (modifica secondo necessità)
	}
}.play(TempoClock.default);

)