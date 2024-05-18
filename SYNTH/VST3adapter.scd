
s.waitForBoot({
	// Definisci il SynthDef per il vocoder
	(
		~vstPath;
		SynthDef.new(\vsti, { arg out = 0, inBus = 0, vocAmpBus;
			var vocAmp = In.kr(vocAmpBus, 1);  // Legge il valore del ControlBus
			var sound = VSTPlugin.ar(In.ar(inBus, 2), 2);
			Out.ar(out, sound * vocAmp);
		}).add;

		~vsti;
		// Crea il Synth con il VST instrument usando il ControlBus per il volume
		~vsti = VSTPluginController(Synth(\vsti, [\inBus, ~vocAudioInBus, \vocAmpBus, ~vocAmpBus]));
		// Ottieni il percorso relativo al plugin VST
		~vstPath = PathName(thisProcess.nowExecutingPath).parentPath +/+ "VST3vocoder/PolyPhaseVoc2.vst3";

		// Apri il plugin usando il percorso relativo
		~vsti.open(~vstPath, editor: true);


		// Connessione dell'input audio al bus audio e poi al plugin
		~micInput = {
			var mic = SoundIn.ar(0); // Assumendo che il microfono sia sul canale di input 0
			Out.ar(~vocAudioInBus, mic);
		}.play;

		// Routing dell'output del plugin agli altoparlanti
		~outputProcessedSound = {
			Out.ar(0, In.ar(~vocAudioInBus, 2)); // Assumendo un'uscita stereo
		}.play;
		// Stampa i parametri del plugin e invia una nota MIDI manualmente
		Routine({
			~vsti.openMsg({ |plugin|
				// Invia l'evento MIDI manualmente
				~sendNote = {
					~vsti.midi.noteOn(0, 60, 127);
					2.0.wait; // Mantiene la nota attiva per 2 secondi
					~vsti.midi.noteOff(0, 60, 0);
				};

				~sendNote.value;
			});
		}).play;
	)
});



// Variabile di stato per tenere traccia se l'editor è aperto o chiuso
~editorOpen = false;

// Funzione per alternare lo stato dell'editor
~toggleEditor = {
	if (~editorOpen) {
		~vsti.editor(show: false); // Nasconde l'editor del plugin
		~editorOpen = false;
		"Editor chiuso".postln;
	} {
		~vsti.editor(show: true); // Mostra l'editor del plugin
		~editorOpen = true;
		"Editor aperto".postln;
	}
};