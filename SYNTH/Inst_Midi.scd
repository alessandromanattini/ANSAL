(
~activeNotesVoc = IdentityDictionary.new;
~activeNotesOne = IdentityDictionary.new;
~activeNotesTwo = IdentityDictionary.new;

~pitchBendRange = 2; // Definisci il range del pitch bend in semitoni

// Funzione per calcolare il moltiplicatore di frequenza dal valore del pitch wheel
~pitchBendToFreq = { |val|
    var semitones;
    // Valore del pitch wheel va da -8192 a 8191
    semitones = (val / 8192) * ~pitchBendRange;
    2 ** (semitones / 12);
};

// Valore attuale del pitch bend
~currentPitchBend = 0;

MIDIdef.noteOn(\noteOnHandler, { |vel, note, chan|
    var freq, freqOne, freqTwo, amp, activateNoteOne, activateNoteTwo;
    if (~waitingForKeySplit) {
        // Gestione del key split in corso, non fare nulla
    } {
        freq = note.midicps;
        amp = vel.linexp(0, 127, 0.01, 1);

        // Funzione per gestire l'attivazione delle note per instOne e vocoder
        activateNoteOne = {
			if (~gloveXOne){
				freqOne=freq* ~pitchBendToFreq.value(~currentPitchBend); // Applica il pitch bend
			}{
				freqOne=freq;
			};
            if (~monoOne) {
                ~activeNotesOne.do({ |data|
                    data[0].release;
                    ~vsti.midi.noteOff(chan, data[2], 0); // Release vocoder note
                });
                ~activeNotesOne.clear;
                ~activeNotesVoc.clear;
            } {
                if (~activeNotesOne.at(note).notNil) {
                    ~activeNotesOne[note][0].release; // Release the previous note
                    ~vsti.midi.noteOff(chan, note, 0); // Release vocoder note
                };
            };
            ~activeNotesOne.put(note, [Synth(~instOne, [\freq, freq * ~octaveOne, \ampBus, ~busOne, \lpFreqBus, ~lowPassFilterOne]), false, note]);
            ~vsti.midi.noteOn(chan, note, vel);
            ~activeNotesVoc.put(note, false);
        };

        // Funzione per gestire l'attivazione delle note per instTwo
        activateNoteTwo = {
			if (~gloveXTwo){
				freqTwo=freq* ~pitchBendToFreq.value(~currentPitchBend); // Applica il pitch bend
			}{
				freqTwo=freq;
			};
            if (~monoTwo) {
                ~activeNotesTwo.do({ |data|
                    data[0].release;
                });
                ~activeNotesTwo.clear;
            } {
                if (~activeNotesTwo.at(note).notNil) {
                    ~activeNotesTwo[note][0].release; // Release the previous note
                };
            };
            ~activeNotesTwo.put(note, [Synth(~instTwo, [\freq, freq * ~octaveTwo, \ampBus, ~busTwo, \lpFreqBus, ~lowPassFilterTwo]), false]);
        };

        if (~keySplit.isNil or: { ~keySplit == -1 }) {
            activateNoteOne.value();
            activateNoteTwo.value();
        } {
            if (note >= ~keySplit) {
                activateNoteOne.value();
            } {
                activateNoteTwo.value();
            }
        }
    }
}, chan: 0);

MIDIdef.noteOff(\noteOffHandler, { |vel, note, chan|
    var dataOne, dataTwo, releaseNoteOne, releaseNoteTwo;
    dataOne = ~activeNotesOne.at(note);
    dataTwo = ~activeNotesTwo.at(note);

    if (~waitingForKeySplit) {
        // Gestione del key split in corso, non fare nulla
    } {
        // Funzione per gestire il rilascio delle note per instOne e vocoder
        releaseNoteOne = {
            dataOne.notNil.if({
                (~sustainOne == false).if({
                    dataOne[0].release;
                    ~activeNotesOne.removeAt(note);
                    ~vsti.midi.noteOff(chan, note, vel); // Release vocoder note
                    ~activeNotesVoc.removeAt(note);
                }, {
                    dataOne[1] = true;  // ready to release
                    ~activeNotesVoc[note] = true; // ready to release vocoder note
                });
            }, {
            });
        };

        // Funzione per gestire il rilascio delle note per instTwo
        releaseNoteTwo = {
            dataTwo.notNil.if({
                (~sustainTwo == false).if({
                    dataTwo[0].release;
                    ~activeNotesTwo.removeAt(note);
                }, {
                    dataTwo[1] = true;  // ready to release
                });
            }, {
            });
        };

        if (~keySplit.isNil or: { ~keySplit == -1 }) {
            releaseNoteOne.value();
            releaseNoteTwo.value();
        } {
            if (note >= ~keySplit) {
                releaseNoteOne.value();
            } {
                releaseNoteTwo.value();
            }
        }
    }
}, chan: 0);

MIDIdef.cc(\sustainPedalHandler, { |val, num, chan|
    var oldSustainOne, oldSustainTwo, handleSustainOne, handleSustainTwo;
    if (~waitingForKeySplit) { ^nil }; // Esce se in modalità di attesa per keySplit
    if (num == 64) {
        oldSustainOne = ~sustainOne;
        oldSustainTwo = ~sustainTwo;
        ~sustainOne = (val >= 64);
        ~sustainTwo = (val >= 64);

        // Funzione per gestire il sustain per instOne e vocoder
        handleSustainOne = {
            if (oldSustainOne && (~sustainOne == false)) {
                ~activeNotesOne.keysValuesDo({ |note, data|
                    if (data[1] && (~activeNotesOne.at(note).isNil == false)) { // Controlla se la nota è ancora premuta
                        data[0].release;
                        ~activeNotesOne.removeAt(note);
                        ~vsti.midi.noteOff(chan, note, 0); // Release vocoder note
                        ~activeNotesVoc.removeAt(note);
                    }
                });
            };
        };

        // Funzione per gestire il sustain per instTwo
        handleSustainTwo = {
            if (oldSustainTwo && (~sustainTwo == false)) {
                ~activeNotesTwo.keysValuesDo({ |note, data|
                    if (data[1] && (~activeNotesTwo.at(note).isNil == false)) { // Controlla se la nota è ancora premuta
                        data[0].release;
                        ~activeNotesTwo.removeAt(note);
                    }
                });
            };
        };

        handleSustainOne.value();
        handleSustainTwo.value();
    }
}, chan: 0);

// Aggiungi la gestione del pitch wheel
MIDIdef.bend(\pitchWheelHandler, { |val, chan|
    var freqMultiplier;
    ~currentPitchBend = val;
    freqMultiplier = ~pitchBendToFreq.value(val);

    // Aggiorna le frequenze di instOne e vocoder
	if(~gloveXOne){
		~activeNotesOne.keysValuesDo({ |note, data|
			data[0].set(\freq, note.midicps * ~octaveOne * freqMultiplier);
			// Assumiamo che il vocoder non richieda modifiche
		});
	};

	// Aggiorna le frequenze di instTwo
	if(~gloveXTwo){
		~activeNotesTwo.keysValuesDo({ |note, data|
			data[0].set(\freq, note.midicps * ~octaveTwo * freqMultiplier);
		});
	};
}, chan: 0);

)
