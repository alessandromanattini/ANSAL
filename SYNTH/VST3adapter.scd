// ======================================================================================================
// =========================================== VOCODER ADAPTER ==========================================
// ======================================================================================================
(
s.waitForBoot({
    // ------------------------------ Creation of Synthdef for the Vocoder ------------------------------
    (
        SynthDef.new(\vsti, { arg out = 0, inBus = 0, vocAmpBus;
            var vocAmp = In.kr(vocAmpBus, 1);                      // Reads the value from the ControlBus
            var sound = VSTPlugin.ar(In.ar(inBus, 2), 2);
            Out.ar(out, sound * vocAmp);
        }).add;
    );
    s.sync;

    // ----------------------------------- Loading VSTPlugin --------------------------------------------
    ~vstPath = PathName(thisProcess.nowExecutingPath).parentPath +/+ "VST3vocoder/PolyPhaseVoc2.vst3";
    ~vsti = VSTPluginController(Synth(\vsti, [\inBus, ~vocAudioInBus, \vocAmpBus, ~vocAmpBus]));
    ~vsti.open(~vstPath, editor: true);

    // ------------------------------ Connecting Vocoder Input and Output -------------------------------
    ~micInput = {
        var mic = SoundIn.ar(0);                                   // microphone is on input channel 0
        Out.ar(~vocAudioInBus, mic);
    }.play;
    ~outputProcessedSound = {
        Out.ar(0, In.ar(~vocAudioInBus, 2));                       // Assuming a stereo output
    }.play;
    Routine({
        ~vsti.openMsg({ |plugin|
            // Sends the MIDI event manually
            ~sendNote = {
                ~vsti.midi.noteOn(0, 60, 127);
                2.0.wait;                                          // Keeps note active for 2 seconds
                ~vsti.midi.noteOff(0, 60, 0);
            };

            ~sendNote.value;
        });
    }).play;
});

// ------------------------------------ Vocoder Interface Management ------------------------------------
~editorOpen = false;                                               // true if the editor is open
~toggleEditor = {
    if (~editorOpen) {
        ~vsti.editor(show: false);                                 // Hides the plugin editor
        ~editorOpen = false;
    } {
        ~vsti.editor(show: true);                                  // Shows the plugin editor
        ~editorOpen = true;
    }
};
)
