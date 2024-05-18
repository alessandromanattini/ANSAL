//=======================================================================================================
//=============================================MIDI=CONTROLS=============================================
//=======================================================================================================

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
			"Nota MIDI ricevuta".postln;
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
            ("AmpOne: " ++ value).postln;
            ~processingAddr.sendMsg('/volume1', value); // Invia messaggio OSC a Processing
            "Inviato messaggio OSC a Processing: /volume1".postln;
        },
        17, {
            value = val.linexp(0, 127, 0.01, 1);
            ~busTwo.set(value);
            ("AmpTwo: " ++ value).postln;
            ~processingAddr.sendMsg('/volume2', value); // Invia messaggio OSC a Processing
            "Inviato messaggio OSC a Processing: /volume2".postln;
        },
        20, {
            value = val.linexp(0, 127, 200, 6000);
            ~lowPassFilterOne.set(value);
            ("LPF One Cutoff: " ++ value).postln;
            ~processingAddr.sendMsg('/LPF1', value); // Invia messaggio OSC a Processing
            "Inviato messaggio OSC a Processing: /LPF1".postln;
        },
        21, {
            value = val.linexp(0, 127, 200, 6000);
            ~lowPassFilterTwo.set(value);
            ("LPF Two Cutoff: " ++ value).postln;
            ~processingAddr.sendMsg('/LPF2', value); // Invia messaggio OSC a Processing
            "Inviato messaggio OSC a Processing: /LPF2".postln;
        },
		70, {
			if (num == 70 && val > 0) {
				"Comando CC 70 ON ricevuto".postln;
				~captureMIDINote.value;
			}
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