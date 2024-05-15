//=======================================================================================================
//=============================================MIDI=CONTROLS=============================================
//=======================================================================================================

//---------------------------------------------Keyboard-Knobs--------------------------------------------

~setKnobValue = { |val, num|
    var value;
    switch(num,
        16, {
            value = val.linlin(0, 127, 0, 1);
            ~busOne.set(value);
            ("AmpOne: " ++ value).postln;
        },
        17, {
            value = val.linlin(0, 127, 0, 1);
            ~busTwo.set(value);
            ("AmpTwo: " ++ value).postln;
        },
        20, {
            value = val.linlin(0, 127, 200, 6000);
            ~lowPassFilterOne.set(value);
            ("LPF One Cutoff: " ++ value).postln;
        },
        21, {
            value = val.linlin(0, 127, 200, 6000);
            ~lowPassFilterTwo.set(value);
            ("LPF Two Cutoff: " ++ value).postln;
        }
    );
};

// Funzione di callback per i messaggi di Control Change dalla tastiera
MIDIdef.cc(\knobHandler, { |val, num, chan, src|
    if (chan == 0) {
        ~setKnobValue.value(val, num);
    };
}, chan: 0);

//---------------------------------------------Control-Pedal---------------------------------------------

~handleCCpedal = { |val|
    var cc1, cc2;
	cc1= ~ccPedalOne;
	cc2= ~ccPedalTwo;
    switch(cc1,
        -1, { //inverse pedal connection
			~setKnobValue.value(128-val, 20)
        },
        0, { //no pedal connection
        },
        1, { //direct pedal connection
			~setKnobValue.value(val, 20)
        }
    );
	switch(cc2,
        -1, { //inverse pedal connection
			~setKnobValue.value(128-val, 21)
        },
        0, { //no pedal connection
        },
        1, { //direct pedal connection
			~setKnobValue.value(val, 21)
        }
    );
};




// Funzione di callback per i messaggi di Control Change dal pedale di controllo
MIDIdef.cc(\controlPedalHandler, { |val, num, chan, src|
    if (chan == 7 && num == 1) {
        ~handleCCpedal.value(val);
    };
}, chan: 7);