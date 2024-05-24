// =========================================================================================================
// ================================================== MAIN =================================================
// =========================================================================================================

(
//------------------------------------------------- SETUP --------------------------------------------------
s.quit;                                      // Stop the server before making configuration changes
s.options.blockSize = 1024;                  // Set buffer size to 1024 samples to reduce latency
s.options.numBuffers = 64;                   // Number of available buffers
s.options.numWireBufs = 128;                 // Number of wire buffers (increase if necessary)
s.options.hardwareBufferSize = 2048;         // Set hardware buffer size

s.options.numInputBusChannels = 2;           // Number of input bus channels
s.options.numOutputBusChannels = 2;          // Number of output bus channels
s.options.memSize = 8192;                    // Memory size allocated for the server in kilobytes
s.options.sampleRate = 48000;
s.latency = 0;

Server.default.options.device = "MME : IN 1-2 (3- BEHRINGER UMC 202HD)";
Server.default.options.outDevice = "MME : OUT 1-2 (3- BEHRINGER UMC 202HD)";
// Start the server
s.boot;

s.waitForBoot({
    if (~port.notNil and: { ~port.isOpen }) {
        ~port.close;
        "Port closed successfully".postln;
    } {
        "Port was not open or failed to close".postln;
    };
	s.sync;
    // Load configuration files and synth definitions
    "Inst_SynthDef.scd".loadRelative;
    "Drum_SynthDef.scd".loadRelative;
    "Midi_Init.scd".loadRelative;
    "Inst_Midi.scd".loadRelative;
    "Knobs.scd".loadRelative;
    "Drum_Sequences.scd".loadRelative;
    "Drum_Midi.scd".loadRelative;
    "ArduinoAdapter.scd".loadRelative;
    "PresetsManaging.scd".loadRelative;
    "VST3adapter.scd".loadRelative;
    "OSCCommunication.scd".loadRelative;


    ~currentPreset = \INTR;
    //------------------------------------------ BUS DECLARATION --------------------------------------------
    ~busOne = Bus.control(s, 1);
    ~busTwo = Bus.control(s, 1);
    ~lowPassFilterOne = Bus.control(s, 1);
    ~lowPassFilterTwo = Bus.control(s, 1);

    //------------------------------------- INST VARIABLES DECLARATION --------------------------------------
    ~activeNotesOne = Dictionary.new;
    ~activeNotesTwo = Dictionary.new;
    ~sustainOne = false;                     // Initialize sustain state
    ~sustainTwo = false;                     // Initialize sustain state
    ~instOne = \NONE;
    ~instTwo = \NONE;
    ~monoOne = false;
    ~monoTwo = false;
    ~octaveOne = 1;
    ~octaveTwo = 1;

    //------------------------------------- DRUM VARIABLES DECLARATION --------------------------------------
    ~bpmDrum = 100;

    //------------------------------------ VOCODER VARIABLES DECLARATION ------------------------------------
    ~vocAudioInBus = Bus.audio(s, 2);
    ~vocAmpBus = Bus.control(s, 1);
    ~vocoderVolume = 0;

    //-------------------------------------- CC VARIABLES DECLARATION ---------------------------------------
    ~ccPedalOne = 1;
    ~ccPedalTwo = 1;

    //------------------------------------ GLOVE VARIABLES DECLARATION --------------------------------------
    ~gloveXOne = true;
    ~gloveXTwo = false;

    ~gloveYOne = true;
    ~gloveYTwo = false;

    //--------------------------------------- GLOBAL INITIALIZATION -----------------------------------------
});
)
