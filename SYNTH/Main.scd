//=======================================================================================================
//==================================================MAIN=================================================
//=======================================================================================================

(
//------------------------------------------------SETUP--------------------------------------------------
s.quit;  // Fermiamo il server prima di apportare modifiche alle configurazioni
s.options.blockSize = 512;  // Impostiamo la dimensione del buffer a 256 campioni per ridurre la latenza
s.options.numBuffers = 64;  // Numero di buffer disponibili
s.options.numWireBufs = 64;  // Numero di wire buffers (aumentalo se necessario)
s.options.hardwareBufferSize = 1024; // Imposta una dimensione del buffer hardware

s.options.numInputBusChannels = 2;  // Numero di canali input bus
s.options.numOutputBusChannels = 2;  // Numero di canali output bus
s.options.memSize = 8192;  // Dimensione della memoria allocata per il server in kilobytes
s.options.sampleRate = 48000;
s.latency = 0;

Server.default.options.device = "MME : IN 1-2 (3- BEHRINGER UMC 202HD)";
Server.default.options.outDevice = "MME : OUT 1-2 (3- BEHRINGER UMC 202HD)";
// Avvio del server
s.boot;

if (~port.notNil and: { ~port.isOpen }) {
    ~port.close;
    "Port closed successfully".postln;
} {
    "Port was not open or failed to close".postln;
};

// Carica i file di configurazione e le definizioni di synth
"Inst_SynthDef.scd".loadRelative;
"Drum_SynthDef.scd".loadRelative;
"Midi_Init.scd".loadRelative;
"Inst_Midi.scd".loadRelative;
"Knobs.scd".loadRelative;
"Drum_Sequences.scd".loadRelative;
"Drum_Midi.scd".loadRelative;
"ArduinoAdapter2.scd".loadRelative;
"PresetsManaging.scd".loadRelative;
"VST3adapter.scd".loadRelative;

~currentPreset = \INTR;
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
~bpmDrum = 100;

//-------------------------------------VOCODER-VARIABLES-DECLARATION----------------------------------
~vocAudioInBus = Bus.audio(s, 2);
~vocAmpBus = Bus.control(s, 1);
~vocoderVolume = 0;

//--------------------------------------CC-VARIABLES-DECLARATION--------------------------------------
~ccPedalOne = 1;
~ccPedalTwo =1;

//------------------------------------GLOVE-VARIABLES-DECLARATION-------------------------------------
~gloveXOne = true;
~gloveXTwo =false;

~gloveYOne = true;
~gloveYTwo =false;

//----------------------------------------GLOBAL-INITIALIZATION---------------------------------------
Routine({
	"Inizio".postln;
	5.0.wait;  // Attende 10 secondi
	"OSCCommunication.scd".loadRelative;

	"Esegui dopo 5 secondi".postln;
	~vsti.editor(show: false);
}).play;

)

~vsti.editor(show: true);


// Codice per chiudere la porta seriale
(
if (~port.notNil and: { ~port.isOpen }) {
    ~port.close;
    "Port closed successfully".postln;
} {
    "Port was not open or failed to close".postln;
};
)



