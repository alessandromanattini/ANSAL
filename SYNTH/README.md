# SYNTH

## Overview
In this part there is the implementation of **SuperCollider** and **Processing**. 

# SuperCollider
Here is an overview of the functions:
1) **Drum_Midi** : sets up a MIDI control change handler that listens for control change messages on channel 0. Depending on the control number, it either triggers individual drum sounds (\kick, \snare, etc.) or toggles predefined drum sequences
2) **Drum_Sequences** : sets up a system for managing and playing drum sequences. It includes functions to start and stop sequences based on BPM, and predefined drum patterns inspired by Daft Punk. The sequences are managed as tasks, and the system ensures only one sequence runs at a time.
3) **Drum_SynthDef** : defines a set of synthesizer definitions for various drum sounds, which can be used in a drum machine or sequencer.
4) **Inst_Midi** : handles MIDI events for playing and controlling synthesizers. It includes three main handlers: noteOn, noteOff, and sustainPedal.
5) **Inst_SynthDef** : defines several synthesizer definitions for various instruments.
6) **Knobs** : provides a comprehensive system for controlling synthesizer parameters in SuperCollider using MIDI control changes, with real-time updates to the Processing GUI via OSC messages. It includes functionality for capturing key split points, managing volumes, and low-pass filter cutoffs for two instruments, as well as handling control pedal inputs.
7) **Midi_Init** : initializes the MIDI system, connects all available MIDI devices, and provides options for debugging incoming MIDI messages.
8) **OSCCommunication** : sets up OSC (Open Sound Control) communication for managing instruments, volume, low-pass filters, mono mode, BPM, and octave selection and more.
9) **Main** : configures and initializes a SuperCollider server with custom settings for buffer sizes, memory allocation, sample rate, and latency. It then loads various configuration files and SynthDefs necessary for the project, which include definitions for instruments and drum sounds. Buses are created and initialized for controlling parameters such as volume and low-pass filters for two instruments. The script sets up dictionaries for tracking active notes and states for sustain, instrument selection, mono modes, and octave settings. Additionally, it establishes initial values for control pedal states and BPM for drum sequences. Finally, the script manually sets some initial values for octave, mono mode, control pedal state, and the instruments selected for the setup. This comprehensive initialization ensures that all components are ready for real-time audio processing and interaction.

