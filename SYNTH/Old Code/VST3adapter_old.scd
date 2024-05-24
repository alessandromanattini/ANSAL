// Imposta il dispositivo di input e output
(
s.quit;

Server.default.options.device = "MME : IN 1-2 (3- BEHRINGER UMC 202HD)";
Server.default.options.outDevice = "MME : OUT 1-2 (3- BEHRINGER UMC 202HD)";

s.boot;
)

// Definisci il SynthDef per il vocoder
(
SynthDef.new(\vsti, { arg out = 0, inBus = 0;
    var sound = VSTPlugin.ar(In.ar(inBus, 2), 2); // VSTPlugin.ar per creare un synth con VST
    Out.ar(out, sound*0.1);
}).add;
)

// Crea il Synth con il VST instrument
~vsti = VSTPluginController(Synth(\vsti, [\inBus, ~audioInBus]));
// Apri il plugin
~vsti.open("PolyPhaseVoc2.vst3", editor: true);

// Configura il proxy MIDI per inviare eventi MIDI al plugin
(
MIDIClient.init;
MIDIIn.connectAll;

MIDIFunc.noteOn({ |vel, pitch, chan, src|
    ["Note On:", pitch, "Velocity:", vel, "Channel:", chan].postln;
    ~vsti.midi.noteOn(chan, pitch, vel);
});

MIDIFunc.noteOff({ |vel, pitch, chan, src|
    ["Note Off:", pitch, "Channel:", chan].postln;
    ~vsti.midi.noteOff(chan, pitch, vel);
});

MIDIFunc.cc({ |val, num, chan, src|
    ["CC:", num, "Value:", val, "Channel:", chan].postln;
    ~vsti.midi.cc(chan, num, val);
});

MIDIFunc.program({ |val, chan, src|
    ["Program Change:", val, "Channel:", chan].postln;
    ~vsti.midi.program(chan, val);
});
)

// Connessione dell'input audio al bus audio e poi al plugin
(
~audioInBus = Bus.audio(s, 2);

~micInput = {
    var mic = SoundIn.ar(0); // Assumendo che il microfono sia sul canale di input 0
    mic.poll(1, "Microphone to Bus"); // Monitoraggio dell'input del microfono
    Out.ar(~audioInBus, mic);
}.play;
)

// Routing dell'output del plugin agli altoparlanti
(
~outputProcessedSound = {
    Out.ar(0, In.ar(~audioInBus, 2)); // Assumendo un'uscita stereo
}.play;
)

// Stampa i parametri del plugin e invia una nota MIDI manualmente
(
Routine({
    ~vsti.openMsg({ |plugin|
        plugin.numParameters.postln;
        (0..(plugin.numParameters - 1)).do { |i|
            plugin.get(i, { |value|
                ["Parameter", i, "Value", value].postln;
            });
        };

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

~vsti.editor;

