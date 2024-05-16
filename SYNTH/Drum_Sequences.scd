//=======================================================================================================
//=============================================DRUM=SEQUENCIES===========================================
//=======================================================================================================

// Funzione per calcolare il tempo in secondi da un valore BPM
~bpmToSeconds = { |bpm| (60 / bpm)/2 };

// Variabili per i Task che gestiscono le sequenze
~drumTasks = IdentityDictionary.new;

// Funzione per fermare tutte le sequenze
~stopAllSequences = {
    ~drumTasks.keysValuesDo { |key, task|
        task.stop;
        ~drumTasks[key] = nil;
    };
};

// Funzione per avviare/fermare una sequenza di batteria
~toggleDrumSequence = { |seqName, pattern|
    if (~drumTasks[seqName].isNil or: { ~drumTasks[seqName].isPlaying.not }) {
        ~stopAllSequences.();
        ~drumTasks[seqName] = Task({
            loop {
                pattern.do { |synthEntry|
                    if (synthEntry.isArray) {
                        // Se synthEntry è un array, suona ogni elemento dell'array
                        synthEntry.do { |synthName|
                            Synth(synthName);
                        };
                    } {
                        // Altrimenti, suona il singolo synth
                        Synth(synthEntry);
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

// Sequenze di batteria ispirate ai Daft Punk
~sequences = (
    daftPunk1: [\kick, \hihat],
    daftPunk2: [\kick, \hihat, [\snare, \kick], \hihat],
    daftPunk3: [\kick, \hihat, \kick, \snare, \kick, \hihat, \snare, \hihat],
    daftPunk4: [\kick, \clap, \hihat, \snare, \kick, \hihat, \clap, \snare]
);
