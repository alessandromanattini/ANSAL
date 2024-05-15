//======================================================================================================
//============================================OSC COMMUNICATION=========================================
//======================================================================================================

// Debugging OSC Messages
OSCFunc.trace(true);

// ----------------------------------------------- INSTRUMENT n.1 ----------------------------------------------------
OSCdef(\selectInstrument1, { |msg, time, addr, recvPort|
    var instrument;
    instrument = msg[1].asString;

    "Strumento n.1 selezionato: ".post; instrument.postln;

    // Seleziona e avvia il synth in base allo strumento selezionato
    switch(instrument,
        "everythingrhodes", { ~instOne = \everythingrhodes },
        "distortedTri", { ~instOne = \distortedTri },
        "sawtooth", { ~instOne = \sawtooth },
        "hammondOrgan", { ~instOne = \hammondOrgan },
        "bass", { ~instOne = \bass },
        "violin", { ~instOne = \violin },
        "mrostinato", { ~instOne = \mrostinato },
        "synchronicity", { ~instOne = \synchronicity },
        "None", {
            ~instOne = nil;
            "Nessuno strumento selezionato.".postln;
        }
    );
}, '/selectInstrument1');

// ----------------------------------------------- INSTRUMENT n.2 ----------------------------------------------------
OSCdef(\selectInstrument2, { |msg, time, addr, recvPort|
    var instrument;
    instrument = msg[1].asString;

    "Strumento n.2 selezionato: ".post; instrument.postln;

    // Seleziona e avvia il synth in base allo strumento selezionato
    switch(instrument,
        "everythingrhodes", { ~instTwo = \everythingrhodes },
        "distortedTri", { ~instTwo = \distortedTri },
        "sawtooth", { ~instTwo = \sawtooth },
        "hammondOrgan", { ~instTwo = \hammondOrgan },
        "bass", { ~instTwo = \bass },
        "violin", { ~instTwo = \violin },
        "mrostinato", { ~instTwo = \mrostinato },
        "synchronicity", { ~instTwo = \synchronicity },
        "None", {
            ~instTwo = nil;
            "Nessuno strumento selezionato.".postln;
        }
    );
}, '/selectInstrument2');

// Gestore OSC per il sustain
OSCdef(\sustain, { |msg|
    var state;
    state = msg[1].asString;

    switch(state,
        "on", {
            ~sustainOne = true;
            "Sustain attivato.".postln;
        },
        "off", {
            ~sustainOne = false;
            "Sustain disattivato.".postln;
        }
    );
}, '/sustain');

// Gestore OSC per il volume
OSCdef(\volume1, { |msg|
    ~volume = msg[1].asFloat;
    ~busOne.set(~volume);
    "Volume strumento 1 impostato a: ".post; ~volume.postln;
}, '/volume1');

// Gestore OSC per il filtro passa basso (LPF)
OSCdef(\LPF1, { |msg|
    ~lpfFreq1 = msg[1].asFloat;
    ~lowPassFilterOne.set(~lpfFreq1);
    "Frequenza LPF strumento 1 impostata a: ".post; ~lpfFreq1.postln;
}, '/LPF1');
