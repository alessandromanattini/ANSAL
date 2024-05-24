// ============================================================================================================================
// ================================================= KEYBOARD MIDI MANAGEMENT =================================================
// ============================================================================================================================

(

// -------------------------------------------- Note ON, Note OFF and Sustain Pedal -------------------------------------------

~activeNotesVoc = IdentityDictionary.new;
~activeNotesOne = IdentityDictionary.new;
~activeNotesTwo = IdentityDictionary.new;

MIDIdef.noteOn(\noteOnHandler, { |vel, note, chan|
    var freq, freqOne, freqTwo, amp, activateNoteOne, activateNoteTwo;
    if (~waitingForKeySplit) {}                                                   // Key split management in progress, do nothing
     {
        freq = note.midicps;
        amp = vel.linexp(0, 127, 0.01, 1);

        activateNoteOne = {                                                       // Function to manage note activation for instOne and vocoder
			if (~gloveXOne){
				freqOne=freq* ~pitchBendToFreq.value(~currentPitchBend);          // Apply pitch bend
			}{
				freqOne=freq;
			};
            if (~monoOne) {
                ~activeNotesOne.do({ |data|
                    data[0].release;
                    ~vsti.midi.noteOff(chan, data[2], 0);                         // Release vocoder note
                });
                ~activeNotesOne.clear;
                ~activeNotesVoc.clear;
            } {
                if (~activeNotesOne.at(note).notNil) {
                    ~activeNotesOne[note][0].release;                             // Release the previous note
					~vsti.midi.noteOff(chan, note, 0);                            // Release vocoder note
                };
            };
            ~activeNotesOne.put(note, [Synth(~instOne, [\freq, freq * ~octaveOne, \ampBus, ~busOne, \lpFreqBus, ~lowPassFilterOne]), false, note]);
            ~vsti.midi.noteOn(chan, note, vel);
            ~activeNotesVoc.put(note, false);
        };

        activateNoteTwo = {                                                       // Function to manage note activation for instTwo
			if (~gloveXTwo){
				freqTwo=freq* ~pitchBendToFreq.value(~currentPitchBend);          // Apply pitch bend
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
                    ~activeNotesTwo[note][0].release;                             // Release the previous note
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

    if (~waitingForKeySplit){}                                                    // Key split management in progress, do nothing
    {
        releaseNoteOne = {                                                        // Function to manage note release for instOne and vocoder
            dataOne.notNil.if({
                (~sustainOne == false).if({
                    dataOne[0].release;
                    ~activeNotesOne.removeAt(note);
                    ~vsti.midi.noteOff(chan, note, vel);                          // Release vocoder note
                    ~activeNotesVoc.removeAt(note);
                }, {
                    dataOne[1] = true;                                            // ready to release
                    ~activeNotesVoc[note] = true;                                 // ready to release vocoder note
                });
            }, {
            });
        };

        releaseNoteTwo = {                                                        // Function to manage note release for instTwo
            dataTwo.notNil.if({
                (~sustainTwo == false).if({
                    dataTwo[0].release;
                    ~activeNotesTwo.removeAt(note);
                }, {
                    dataTwo[1] = true;                                            // ready to release
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
            };
        };
    };
}, chan: 0);

MIDIdef.cc(\sustainPedalHandler, { |val, num, chan|
    var oldSustainOne, oldSustainTwo, handleSustainOne, handleSustainTwo;
    if (~waitingForKeySplit) { ^nil };                                            // Exit if in keySplit waiting mode
    if (num == 64) {
        oldSustainOne = ~sustainOne;
        oldSustainTwo = ~sustainTwo;
        ~sustainOne = (val >= 64);
        ~sustainTwo = (val >= 64);

        handleSustainOne = {                                                      // Function to manage sustain for instOne and vocoder
            if (oldSustainOne && (~sustainOne == false)) {
                ~activeNotesOne.keysValuesDo({ |note, data|
                    if (data[1] && (~activeNotesOne.at(note).isNil == false)) {   // Check if the note is still pressed
                        data[0].release;
                        ~activeNotesOne.removeAt(note);
                        ~vsti.midi.noteOff(chan, note, 0);                        // Release vocoder note
                        ~activeNotesVoc.removeAt(note);
                    }
                });
            };
        };

        handleSustainTwo = {                                                      // Function to manage sustain for instTwo
            if (oldSustainTwo && (~sustainTwo == false)) {
                ~activeNotesTwo.keysValuesDo({ |note, data|
                    if (data[1] && (~activeNotesTwo.at(note).isNil == false)) {   // Check if the note is still pressed
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


// ------------------------------------------------------ Pitch "Wheel" ----------------------------------------------------

~currentPitchBend = 0;
~pitchBendRange = 2;                                                              // Define the pitch bend range in semitones

~pitchBendToFreq = { |val|                                                        // Function to calculate the frequency multiplier from the pitch wheel value
    var semitones;
    semitones = (val / 8192) * ~pitchBendRange;                                   // Pitch wheel value ranges from -8192 to 8191
    2 ** (semitones / 12);
};

MIDIdef.bend(\pitchWheelHandler, { |val, chan|                                    // Add pitch wheel management
    var freqMultiplier;
    ~currentPitchBend = val;
    freqMultiplier = ~pitchBendToFreq.value(val);

	if(~gloveXOne){                                                               // Update frequencies of instOne
		~activeNotesOne.keysValuesDo({ |note, data|
			data[0].set(\freq, note.midicps * ~octaveOne * freqMultiplier);
		});
	};

	if(~gloveXTwo){                                                               // Update frequencies of instTwo
		~activeNotesTwo.keysValuesDo({ |note, data|
			data[0].set(\freq, note.midicps * ~octaveTwo * freqMultiplier);
		});
	};
}, chan: 0);

)
