//=======================================================================================================
//=============================================MIDI=CONTROLS=============================================
//=======================================================================================================
(
~keySplit = -1;
~waitingForKeySplit = false;

// Definisci una funzione per gestire la nota MIDI e aggiornare ~keySplit
~captureMIDINote = {
	~keySplit.postln;
    if (~keySplit == -1) {
		~waitingForKeySplit=true;
        // Cancella qualsiasi definizione precedente di MIDIdef chiamata \captureNote
        MIDIdef.noteOn(\captureNote, { |vel, num|
            ~keySplit = num;
		    ~waitingForKeySplit=false; // Esce se in modalità di attesa per keySplit
            // Dopo aver ricevuto una nota, cancella la definizione per evitare ulteriori catture
            MIDIdef.noteOn(\captureNote).free;
        });
    } {
        // Se ~keySplit non è -1, reimpostalo a -1
        ~keySplit = -1;
        "keySplit impostato a -1".postln;
		~waitingForKeySplit = false;

    }
};



//---------------------------------------------Keyboard-Knobs--------------------------------------------

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
        22, { // ratio
            ~vsti.midi.control(0, 22, val);
        },
        23, { // corr_k
            ~vsti.midi.control(0, 23, val);
        },
        24, { // highPassCutoff
            ~vsti.midi.control(0, 24, val);
        },
        26, { // attack
            ~vsti.midi.control(0, 26, val);
        },
        27, { // decay
            ~vsti.midi.control(0, 27, val);
        },
        28, { // sustain
            ~vsti.midi.control(0, 28, val);
        },
        29, { // release
            ~vsti.midi.control(0, 29, val);
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
)