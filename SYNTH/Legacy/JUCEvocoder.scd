
s.quit;
s.start;
// Assicurati di cercare i plugin VST prima di avviare il server
// Assicurati di chiudere eventuali server in esecuzione
s.quit;

// Avvia il server
s.waitForBoot {
    // Cerca i plugin VST3 nella directory specificata
    VSTPlugin.search(s, "./VST3vocoder");

    // Definisci un SynthDef che usa un plugin VST3
    SynthDef(\vstTest, {
        |out=0|
        var sig = In.ar(0, 2); // 2 canali audio di input
        var vst;

        // Crea un VSTPlugin
        vst = VSTPlugin.ar(nil, 2, 2); // 2 canali audio di input e output

        // Crea un VSTPluginController per aprire il plugin VST3
        VSTPluginController(Synth.current).open(
            "./VST3vocoder/PolyPhaseVoc2.vst3",
            true,
            {|plugin|
                // Imposta il callback per la configurazione del plugin dopo l'apertura
                plugin.midi(MIDIdef(\midiIn, { |val, num| plugin.noteOn(0, num, val) }).value);
                Out.ar(out, plugin.ar(sig));
            }
        );
        Out.ar(out, vst);
    }).add;

    // Avvia il Synth
    x = Synth(\vstTest);
};

// Invia note MIDI al plugin
MIDIdef.noteOn(\noteOn, {
    |vel, num, chan, src|
    x.set(\midinote, num);
    x.set(\velocity, vel);
});

