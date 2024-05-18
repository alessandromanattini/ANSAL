//=======================================================================================================
//==================================================MAIN=================================================
//=======================================================================================================

(
//------------------------------------------------SETUP--------------------------------------------------
s.quit;  // Fermiamo il server prima di apportare modifiche alle configurazioni
s.options.blockSize = 32;  // Impostiamo la dimensione del buffer a 256 campioni per ridurre la latenza
s.options.numBuffers = 64;  // Numero di buffer disponibili
s.options.numWireBufs = 64;  // Numero di wire buffers (aumentalo se necessario)
s.options.numInputBusChannels = 2;  // Numero di canali input bus
s.options.numOutputBusChannels = 2;  // Numero di canali output bus
s.options.memSize = 8192;  // Dimensione della memoria allocata per il server in kilobytes
s.options.sampleRate = 44100;
s.latency = 0;
Server.default.options.device = "MME : IN 1-2 (3- BEHRINGER UMC 202HD)";
Server.default.options.outDevice = "MME : OUT 1-2 (3- BEHRINGER UMC 202HD)";
// Avvio del server
s.boot;

// Carica i file di configurazione e le definizioni di synth
"Inst_SynthDef.scd".loadRelative;
"Drum_SynthDef.scd".loadRelative;

"Midi_Init.scd".loadRelative;
"Inst_Midi.scd".loadRelative;
"Knobs.scd".loadRelative;
"Drum_Sequences.scd".loadRelative;
"Drum_Midi.scd".loadRelative;
"OSCCommunication.scd".loadRelative;
"VST3adapter.scd".loadRelative;
//------------------------------------------BUS-DECLARATION-------------------------------------------
~busOne = Bus.control(s, 1);
~busTwo = Bus.control(s, 1);
~lowPassFilterOne = Bus.control(s, 1);
~lowPassFilterTwo = Bus.control(s, 1);

//-------------------------------------INST-VARIABLES-DECLARATION-------------------------------------
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
//-------------------------------------DRUM-VARIABLES-DECLARATION-------------------------------------
~bpmDrum = 120;

//-------------------------------------VOCODER-VARIABLES-DECLARATION----------------------------------
~vocAudioInBus = Bus.audio(s, 2);
~vocAmpBus = Bus.control(s, 1);

//--------------------------------------CC-VARIABLES-DECLARATION--------------------------------------
~ccPedalOne = 1;
~ccPedalTwo =1;

//----------------------------------------GLOBAL-INITIALIZATION---------------------------------------
Routine({
	"Inizio".postln;
	7.0.wait;  // Attende 5 secondi
	"Esegui dopo 5 secondi".postln;
	~octaveOne = 1/2;
	~octaveTwo = 1;
	~monoOne = false;
	~ccPedalTwo = 1;

	~instOne = \violin ;
	~instTwo = \violin;
	~bpmDrum = 110;

	~ccPedalOne = 0;
	~ccPedalTwo =1;

	~busOne.set(0.2);
	~busTwo.set(0.2);
	~lowPassFilterOne.set(1000);
	~lowPassFilterTwo.set(1000);
	~vocAmpBus.set(0.3);
	~vsti.editor(show: false);
}).play;

)

