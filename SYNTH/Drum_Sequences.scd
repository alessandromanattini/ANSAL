// =========================================================================================================
// ============================================== DRUM SEQUENCES ===========================================
// =========================================================================================================

(

~bpmToSeconds = { |bpm| (60 / bpm)/2 };                                             // Function to calculate time in seconds from a BPM value

~drumTasks = IdentityDictionary.new;                                                // Variables for the Tasks that manage the sequences

~stopAllSequences = {                                                               // Function to stop all sequences
    ~drumTasks.keysValuesDo { |key, task|
        task.stop;
        ~drumTasks[key] = nil;
    };
};

~toggleDrumSequence = { |seqName, pattern|                                          // Function to start/stop a drum sequence
    if (~drumTasks[seqName].isNil or: { ~drumTasks[seqName].isPlaying.not }) {
        ~stopAllSequences.();
        ~drumTasks[seqName] = Task({
            loop {
                pattern.do { |synthEntry|
                    if (synthEntry.isArray) {
                        synthEntry.do { |synthName|                                 // If synthEntry is an array, play each element of the array
                            Synth(synthName);
                        };
                    } {
                        Synth(synthEntry);                                          // Otherwise, play the single synth
                    };
                    ~bpmToSeconds.(~bpmDrum).wait;
                }
            }
        }).play;
        ("Drum sequence " ++ seqName ++ " started.").postln;
    }  {
        ~drumTasks[seqName].stop;
        ~drumTasks[seqName] = nil;
        ("Drum sequence " ++ seqName ++ " stopped.").postln;
    }
};

~sequences = (                                                                      // Drum sequences
    daftPunk1: [\kick, \hihat],
    daftPunk2: [\kick, \hihat, [\snare, \kick], \hihat],
    daftPunk3: [\kick, \hihat, \kick, \snare, \kick, \hihat, \snare, \hihat],
    daftPunk4: [\kick, \clap, \hihat, \snare, \kick, \hihat, \clap, \snare]
);

)