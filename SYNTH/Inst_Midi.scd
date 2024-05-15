//=======================================================================================================
//=========================================INST=MIDI-HANDLING============================================
//=======================================================================================================

MIDIdef.noteOn(\noteOnHandler, { |vel, note, chan|
    var freq, amp;
    freq = note.midicps;
    amp = vel.linexp(0, 127, 0.01, 1);
    "NoteOn.".postln;
    // ----------------------------Strumento Uno----------------------------
    if (~activeNotesOne.at(note).notNil) {
        ~activeNotesOne[note][0].release; // Release the previous note
    };
    ~activeNotesOne.put(note, [Synth(~instOne, [\freq/2, freq, \ampBus, ~busOne, \lpFreqBus, ~lowPassFilterOne]), false]);

    // ----------------------------Strumento Due----------------------------
    if (~activeNotesTwo.at(note).notNil) {
        ~activeNotesTwo[note][0].release; // Release the previous note
    };
    ~activeNotesTwo.put(note, [Synth(~instTwo, [\freq, freq, \ampBus, ~busTwo, \lpFreqBus, ~lowPassFilterTwo]), false]);
}, chan: 0);

MIDIdef.noteOff(\noteOffHandler, { |vel, note, chan|
    var dataOne = ~activeNotesOne.at(note);
    var dataTwo = ~activeNotesTwo.at(note);
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
}, chan: 0);

MIDIdef.cc(\sustainPedalHandler, { |val, num, chan|
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
