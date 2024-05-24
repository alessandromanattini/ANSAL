// =======================================================================================================
// ============================================ MIDI CONTROLS ============================================
// =======================================================================================================
(
//--------------------------------------------- MIDI SETUP ----------------------------------------------
~keySplit = -1;
~waitingForKeySplit = false;

~captureMIDINote = {                                             // Define a function to handle MIDI notes and update ~keySplit
    ~keySplit.postln;
    if (~keySplit == -1) {
        ~waitingForKeySplit = true;
        MIDIdef.noteOn(\captureNote, { |vel, num|                // Clear any previous definition of MIDIdef named \captureNote
            ~keySplit = num;
            ~waitingForKeySplit = false;
            MIDIdef.noteOn(\captureNote).free;                   // Remove the definition after receiving a note to prevent further captures
        });
    } {                                                          // If ~keySplit is not -1, reset it to -1
        ~keySplit = -1;
        "keySplit set to -1".postln;
        ~waitingForKeySplit = false;
    }
};

// ------------------------------------------- Keyboard Knobs --------------------------------------------

~setKnobValue = { |val, num|
    var value;
    switch(num,
        16, {
            value = val.linexp(0, 127, 0.01, 1);
            ~busOne.set(value);
        },
        17, {
            value = val.linexp(0, 127, 0.01, 1);
            ~busTwo.set(value);
        },
        20, {
            value = val.linexp(0, 127, 200, 6000);
            ~lowPassFilterOne.set(value);
        },
        21, {
            value = val.linexp(0, 127, 200, 6000);
            ~lowPassFilterTwo.set(value);
        },
        70, {
            if (num == 70 && val > 0) {
                ~captureMIDINote.value;
            }
        },
        69, {
            if (num == 69 && val > 0) {
                ~toggleEditor.value;
            }
        },
        22, {                                                      // ratio
            val.postln;
            ~vsti.midi.control(0, 22, val);
        },
        23, {                                                      // corr_k
            val.postln;
            ~vsti.midi.control(0, 23, val);
        },
        24, {                                                      // highPassCutoff
            val.postln;
            ~vsti.midi.control(0, 24, val);
        },
        26, {                                                      // attack
            ~vsti.midi.control(0, 26, val);
        },
        27, {                                                      // decay
            ~vsti.midi.control(0, 27, val);
        },
        28, {                                                      // sustain
            ~vsti.midi.control(0, 28, val);
        },
        29, {                                                      // release
            ~vsti.midi.control(0, 29, val);
        }
    );
};

MIDIdef.cc(\knobHandler, { |val, num, chan, src|                   // Callback function for Control Change messages from the keyboard
    if (chan == 0) {
        ~setKnobValue.value(val, num);
    };
}, chan: 0);

// -------------------------------------------- Control Pedal --------------------------------------------

~handleCCpedal = { |val|
    var cc1, cc2;
    cc1 = ~ccPedalOne;
    cc2 = ~ccPedalTwo;
    switch(cc1,
        -1, {                                                     // inverse pedal connection
            ~setKnobValue.value(128-val, 20)
        },
        0, {                                                      // no pedal connection
        },
        1, {                                                      // direct pedal connection
            ~setKnobValue.value(val, 20)
        }
    );
    switch(cc2,
        -1, {                                                     // inverse pedal connection
            ~setKnobValue.value(128-val, 21)
        },
        0, {                                                      // no pedal connection
        },
        1, {                                                      // direct pedal connection
            ~setKnobValue.value(val, 21)
        }
    );
};

MIDIdef.cc(\controlPedalHandler, { |val, num, chan, src|          // Callback function for Control Change messages from the control pedal
    if (chan == 7 && num == 1) {
        ~handleCCpedal.value(val);
    };
}, chan: 7);
)
