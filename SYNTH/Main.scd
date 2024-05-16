//=======================================================================================================
//==================================================MAIN=================================================
//=======================================================================================================

(
//------------------------------------------------SETUP--------------------------------------------------
s.quit;  // Fermiamo il server prima di apportare modifiche alle configurazioni
s.options.blockSize = 256;  // Impostiamo la dimensione del buffer a 256 campioni per ridurre la latenza
s.options.numBuffers = 128;  // Numero di buffer disponibili
s.options.numWireBufs = 64;  // Numero di wire buffers (aumentalo se necessario)
s.options.numInputBusChannels = 2;  // Numero di canali input bus
s.options.numOutputBusChannels = 2;  // Numero di canali output bus
s.options.memSize = 8192;  // Dimensione della memoria allocata per il server in kilobytes
s.options.sampleRate = 44100;
s.latency = 0;
s.boot;  // Riavviamo il server per applicare le configurazioni

// Carica i file di configurazione e le definizioni di synth
"Inst_SynthDef.scd".loadRelative;
"Drum_SynthDef.scd".loadRelative;

"Midi_Init.scd".loadRelative;
"Inst_Midi.scd".loadRelative;
"Knobs.scd".loadRelative;
"Drum_Sequences.scd".loadRelative;
"Drum_Midi.scd".loadRelative;
"OSCCommunication.scd".loadRelative;

//------------------------------------------BUS-INITIALIZATION-------------------------------------------
~busOne = Bus.control(s, 1);
~busTwo = Bus.control(s, 1);
~lowPassFilterOne = Bus.control(s, 1);
~lowPassFilterTwo = Bus.control(s, 1);

~busOne.set(0.1);
~busTwo.set(0.1);
~lowPassFilterOne.set(1000);
~lowPassFilterTwo.set(1000);

//-------------------------------------INST-VARIABLES-INITIALIZATION-------------------------------------
~activeNotesOne = Dictionary.new;
~activeNotesTwo = Dictionary.new;
~sustainOne = false;  // Initialize sustain state
~sustainTwo = false;  // Initialize sustain state
~instOne = \none;
~instTwo = \none;
~monoOne = false;
~monoTwo = false;
~octaveOne = 1;
~octaveTwo = 1;
//-------------------------------------DRUM-VARIABLES-INITIALIZATION-------------------------------------
~bpmDrum = 120;

//--------------------------------------CC-VARIABLES-INITIALIZATION--------------------------------------
~ccPedalOne = 1;
~ccPedalTwo =1;
)

~octaveOne = 1/2;
~monoOne = true;
~ccPedalTwo = 1;

~instOne = \bass;
~instTwo = \violin;

