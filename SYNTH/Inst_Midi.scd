(
~activeNotesVoc = IdentityDictionary.new;

MIDIdef.noteOn(\noteOnHandler, { |vel, note, chan|
    var freq, amp;
    if (~waitingForKeySplit) {
        // Gestione del key split in corso, non fare nulla
    } {
        freq = note.midicps;
        amp = vel.linexp(0, 127, 0.01, 1);
        "NoteOn.".postln;

        if (~keySplit == -1) {
            // ----------------------------Strumento Uno----------------------------
            if (~monoOne) {
                ~activeNotesOne.do({ |data|
                    data[0].release;
                });
                ~activeNotesOne.clear;
            } {
                if (~activeNotesOne.at(note).notNil) {
                    ~activeNotesOne[note][0].release; // Release the previous note
                };
            };
            ~activeNotesOne.put(note, [Synth(~instOne, [\freq, freq*~octaveOne, \ampBus, ~busOne, \lpFreqBus, ~lowPassFilterOne]), false]);

            // Aggiungi qui per inviare l'evento NoteOn al vocoder e aggiorna activeNotesVoc
            ~vsti.midi.noteOn(chan, note, vel);
            ~activeNotesVoc.put(note, false);

            // ----------------------------Strumento Due----------------------------
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
            ~activeNotesTwo.put(note, [Synth(~instTwo, [\freq, freq*~octaveTwo, \ampBus, ~busTwo, \lpFreqBus, ~lowPassFilterTwo]), false]);
        } {
            // ----------------------------Strumento Uno----------------------------
            if (note >= ~keySplit) {
                if (~monoOne) {
                    ~activeNotesOne.do({ |data|
                        data[0].release;
                    });
                    ~activeNotesOne.clear;
                } {
                    if (~activeNotesOne.at(note).notNil) {
                        ~activeNotesOne[note][0].release; // Release the previous note
                    };
                };
                ~activeNotesOne.put(note, [Synth(~instOne, [\freq, freq*~octaveOne, \ampBus, ~busOne, \lpFreqBus, ~lowPassFilterOne]), false]);

                // Aggiungi qui per inviare l'evento NoteOn al vocoder e aggiorna activeNotesVoc
                ~vsti.midi.noteOn(chan, note, vel);
                ~activeNotesVoc.put(note, false);
            } {
                // ----------------------------Strumento Due----------------------------
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
                ~activeNotesTwo.put(note, [Synth(~instTwo, [\freq, freq*~octaveTwo, \ampBus, ~busTwo, \lpFreqBus, ~lowPassFilterTwo]), false]);
            }
        }
    }
}, chan: 0);


MIDIdef.noteOff(\noteOffHandler, { |vel, note, chan|
    var dataOne = ~activeNotesOne.at(note);
    var dataTwo = ~activeNotesTwo.at(note);
    var dataVoc = ~activeNotesVoc.at(note);

    if (~waitingForKeySplit) {
        // Gestione del key split in corso, non fare nulla
    } {
        if (~keySplit == -1) {
            // ----------------------------Strumento Uno----------------------------
            dataOne.notNil.if({
                (~sustainOne == false).if({
                    dataOne[0].release;
                    ~activeNotesOne.removeAt(note);
                }, {
                    dataOne[1] = true;  // ready to release
                });
            }, {
                "Note1 data not found.".postln;
            });

            // Aggiungi qui per inviare l'evento NoteOff al vocoder e aggiorna activeNotesVoc
            dataVoc.notNil.if({
                (~sustainOne == false).if({
                    ~vsti.midi.noteOff(chan, note, vel);
                    ~activeNotesVoc.removeAt(note);
                }, {
                    ~activeNotesVoc[note] = true;  // ready to release
                });
            });

            // ----------------------------Strumento Due----------------------------
            dataTwo.notNil.if({
                (~sustainTwo == false).if({
                    dataTwo[0].release;
                    ~activeNotesTwo.removeAt(note);
                }, {
                    dataTwo[1] = true;  // ready to release
                });
            }, {
                "Note2 data not found.".postln;
            });
        } {
            // ----------------------------Strumento Uno----------------------------
            if (note >= ~keySplit) {
                dataOne.notNil.if({
                    (~sustainOne == false).if({
                        dataOne[0].release;
                        ~activeNotesOne.removeAt(note);
                    }, {
                        dataOne[1] = true;  // ready to release
                    });
                }, {
                    "Note1 data not found.".postln;
                });

                // Aggiungi qui per inviare l'evento NoteOff al vocoder e aggiorna activeNotesVoc
                dataVoc.notNil.if({
                    (~sustainOne == false).if({
                        ~vsti.midi.noteOff(chan, note, vel);
                        ~activeNotesVoc.removeAt(note);
                    }, {
                        ~activeNotesVoc[note] = true;  // ready to release
                    });
                });
            } {
                // ----------------------------Strumento Due----------------------------
                dataTwo.notNil.if({
                    (~sustainTwo == false).if({
                        dataTwo[0].release;
                        ~activeNotesTwo.removeAt(note);
                    }, {
                        dataTwo[1] = true;  // ready to release
                    });
                }, {
                    "Note2 data not found.".postln;
                });
            }
        }
    }
}, chan: 0);



MIDIdef.cc(\sustainPedalHandler, { |val, num, chan|
    if (~waitingForKeySplit) { ^nil }; // Esce se in modalità di attesa per keySplit
    if (num == 64) {
        var oldSustainOne = ~sustainOne;
        var oldSustainTwo = ~sustainTwo;
        ~sustainOne = (val >= 64);
        ~sustainTwo = (val >= 64);

        // --------------------------Strumento Uno--------------------------
        if (oldSustainOne && (~sustainOne == false)) {
            ~activeNotesOne.keysValuesDo({ |note, data|
                if (data[1] && (~activeNotesOne.at(note).isNil == false)) { // Controlla se la nota è ancora premuta
                    data[0].release;
                    ~activeNotesOne.removeAt(note);
                }
            });

            // Rilascia le note pronte per essere rilasciate nel vocoder
            ~activeNotesVoc.keysValuesDo({ |note, sustain|
                if (sustain && (~activeNotesVoc.at(note).isNil == false)) { // Controlla se la nota è ancora premuta
                    ~vsti.midi.noteOff(chan, note, 0);
                    ~activeNotesVoc.removeAt(note);
                }
            });
        };

        // --------------------------Strumento Due--------------------------
        if (oldSustainTwo && (~sustainTwo == false)) {
            ~activeNotesTwo.keysValuesDo({ |note, data|
                if (data[1] && (~activeNotesTwo.at(note).isNil == false)) { // Controlla se la nota è ancora premuta
                    data[0].release;
                    ~activeNotesTwo.removeAt(note);
                }
            });
        };
    }
}, chan: 0);

)
