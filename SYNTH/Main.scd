(

//=======================================================================================================
//==================================================MAIN=================================================
//=======================================================================================================

//------------------------------------------------SETUP--------------------------------------------------

s.quit;  // Fermiamo il server prima di apportare modifiche alle configurazioni
s.options.blockSize = 256;  // Impostiamo la dimensione del buffer a 64 campioni per ridurre la latenza
s.options.numBuffers = 128;  // Numero di buffer disponibili
s.options.numWireBufs = 64;  // Numero di wire buffers (aumentalo se necessario)
s.options.numInputBusChannels = 2;  // Numero di canali input bus
s.options.numOutputBusChannels = 2;  // Numero di canali output bus
s.options.memSize = 8192;  // Dimensione della memoria allocata per il server in kilobytes
s.options.sampleRate = 44100;
s.boot;  // Riavviamo il server per applicare le configurazioni
s.latency = 0;

// Carica i file di configurazione e le definizioni di synth
"Inst_SynthDef.scd".loadRelative;
"Drum_SynthDef.scd".loadRelative;
"Inst_Midi.scd".loadRelative;
"Knobs.scd".loadRelative;
"Drum_Sequences.scd".loadRelative;
"Drum_Midi.scd".loadRelative;

//------------------------------------------BUS-INITIALIZATION-------------------------------------------
// Crea due bus di controllo per l'ampiezza
~busOne = Bus.control(s, 1);  // 's' è il server di SuperCollider, '1' indica un canale
~busTwo = Bus.control(s, 1);
~lowPassFilterOne = Bus.control(s, 1);
~lowPassFilterTwo = Bus.control(s, 1);

~busOne.set(0.1);  // Imposta un valore iniziale di 0.1
~busTwo.set(0.1);  // Imposta un valore iniziale di 0.1
~lowPassFilterOne.set(1000);  // Imposta un valore iniziale di 1000 Hz
~lowPassFilterTwo.set(1000);  // Imposta un valore iniziale di 1000 Hz

//-------------------------------------INST-VARIABLES-INITIALIZATION-------------------------------------
~activeNotesOne = Dictionary.new;
~activeNotesTwo = Dictionary.new;
~sustainOne = false;  // Initialize sustain state
~sustainTwo = false;  // Initialize sustain state
~instOne = \violin;
~instTwo = \everythingrhodes;

//-------------------------------------DRUM-VARIABLES-INITIALIZATION-------------------------------------
~bpmDrum = 250;






)
