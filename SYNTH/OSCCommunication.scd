//======================================================================================================
//============================================OSC COMMUNICATION=========================================
//======================================================================================================


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
    }  {
        "Stato mono 1 non riconosciuto.".postln;
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
	~busOne.set(msg[1].asFloat);
    "Volume strumento 1 impostato a: ".post; ~volumeOne.postln;
}, '/volume1');

OSCdef(\volume2, { |msg|
    ~busTwo.set(msg[1].asFloat);
    "Volume strumento 2 impostato a: ".post; ~volumeTwo.postln;
}, '/volume2');

// ------------------------------------------------------------------------------------------------------------------

// Gestore OSC per il filtro passa basso (LPF)
OSCdef(\LPF1, { |msg|
	~lowPassFilterOne.set(msg[1].asFloat);
    "Frequenza LPF strumento 1 impostata a: ".post; ~lpfFreq1.postln;
}, '/LPF1');

OSCdef(\LPF2, { |msg|
    ~lowPassFilterTwo.set(msg[1].asFloat);
    "Frequenza LPF strumento 2 impostata a: ".post; ~lpfFreq2.postln;
}, '/LPF2');

// ------------------------------------------------------------------------------------------------------------------

// Gestore OSC per BPM sequenza percussioni
OSCdef(\BPM, { |msg|
    ~bpmDrum = msg[1].asFloat;
	//int value = ~bpmDrum;
    "Volume strumento 1 impostato a: ".post; ~bpmDrum.postln;
	 ~processingAddr.sendMsg('/BPM', ~bpmDrum); // Invia messaggio OSC a Processing
     "Inviato messaggio OSC a Processing: ".postln; ~bpmDrum.postln;
}, '/BPM');

// ------------------------------------------------------------------------------------------------------------------


// Gestore OSC per la selezione dell'ottava
OSCdef(\selectOctave1, { |msg|
	var octave = msg[1].asInt;  // Usa asInt per convertire il valore in intero
	"Ottava 1 selezionata: ".post; octave.postln;
	// Aggiungi qui il codice per gestire la selezione dell'ottava 1
	~octaveOne = octave;
	"Nuova ottava 1: ".postln; ~octaveOne.postln;
}, '/selectOctave1');


OSCdef(\selectOctave2, { |msg|
	var octave = msg[1].asInt;  // Usa asInt per convertire il valore in intero
	"Ottava 2 selezionata: ".post; octave.postln;
	// Aggiungi qui il codice per gestire la selezione dell'ottava 2
	~octaveTwo = octave;
	"Nuova ottava 2: ".postln; ~octaveTwo.postln;
}, '/selectOctave2');

// ------------------------------------------------------------------------------------------------------------------