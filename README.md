# ANSAL CMLS PROJECT
## Summary of the functionalities
The aim of our project is to provide small groups of musicians with a comprehensive tool to expand their musical possibilities and perform as if they were a full band. To achieve this, we have implemented the following modules:
1. **Polyphonic MIDI Phase Vocoder (JUCE)**: This allows for the simulation of vocal harmonies, enriching the musical landscape.
2. **Polyphonic Synthesizer**: Features numerous functionalities including mono mode, keyboard split, low-pass filter (LPF), octave shift, pitch shift, and drum sequences, which will be detailed later.
   Note: These two instruments are interconnected. The Vocoder is accessible via the Synth interface, and the notes received by the Synth are forwarded to the Vocoder. This setup enables a single person to play both instruments effortlessly.
3. **Guitar Effects Suite**: Enhances the guitar sound and uses pitch recognition to identify the fundamental note of the chord being played. This allows the simulation of doubling on that note, enabling a single guitarist to "play two guitars or a guitar and a bass."

The functionalities of the modules can be modified either through the graphical interface or via MIDI command mappings, as will be illustrated later.

# Vocoder Module
![Vocoder GUI](ReadmeFiles/VocoderGUI.png)

The polyphonic vocoder implemented in this project is a K-voice polyphonic vocoder (where K is a parameter that can be easily modified in the private variables in PluginProcessor) controlled via MIDI. The operation is as follows:

1. **Audio Input**: The audio enters through the microphone input into the PluginProcessor. Here, it is normalized (using the SimpleCompressor class) to ensure a stable input signal level.
2. **Audio and MIDI Processing**: The processBlock reads the incoming audio buffer and MIDI input. For each MIDI note read, it activates one of the K voices and assigns it to process the audio buffer at the specific MIDI note frequency.
3. **Voice Processing**: Each vocoder voice (PhaseVoc class) processes the audio buffer using the following "leaky autocorrelation" formula:

$$ R_{l,n} = (1 - k) R_{l,n-1} + k x_n x_{n-l} $$

   Where: 
   - **$R_{l,n}$**: Leaky autocorrelation at lag $l$ and time $n$.
   - **$R_{l,n-1}$**: Leaky autocorrelation at lag $l$ and previous time step $n-1$.
   - **$x_n$**: Input signal at time $n$.
   - **$x_{n-l}$**: Input signal $l$ steps before $n$.
   - **$k$**: Leakiness constant, typically around $0.001$.

  This formula balances past autocorrelation values with new data, allowing the vocoder to adapt to changes in the speech signal over time.

4. **Envelope Application**: To ensure the notes have a pleasant envelope, PhaseVoc applies methods from the EnvelopeGenerator class to the processed audio. Once this is done, it returns the buffer containing the processed result to PluginProcessor.
5. **High-Pass Filtering**: Before outputting the audio, PluginProcessor applies a High-Pass Filter (HighPassFilter class) to the outgoing audio to remove the lowest frequencies and enhance audio intelligibility if necessary.

The following steps and the class hierarchy related to audio processing are easily deducible from the following diagram:

![Vocoder Audio Path and Dependencies Scheme](ReadmeFiles/VocoderChain.png)

# Synth Module
![Synth GUI](ReadmeFiles/SynthGUI.png)

The synth module includes numerous functions available to the user, all controllable via both the graphical interface and MIDI. Additionally, the Vocoder described in the previous section is integrated within the Synth module. This setup ensures that the MIDI notes used to play the synthesizer are also forwarded to the Vocoder, allowing it to modulate the voice with the same harmonies.

## Synth Hardware Configuration
The hardware setup for the synth module is as follows:
### MIDI Input Devices
You can modify and control the system parameters using various MIDI controllers (details on how this is achieved will be provided in subsequent sections). The devices include:
* MIDI keyboard (Arturia Minilab configured with [this preset](ReadmeFiles/MIDIMapConfig.minilabmk2)).
* Sustain pedal.
* Volume control pedal (not used for volume control).
* Analog control pedal to MIDI signal adapter (I used [this one](https://beatbars.com/en/dual-to-midi.html)).
### Hand Inclination Input
The system also takes input from the hand inclination of the keyboardist. The reason and method for using this to aid in system control will be explained later. The necessary hardware devices are:
* Accelerometer: Mounted on a glove to be worn while playing (I used [this one](https://wiki.dfrobot.com/Triple_Axis_Accelerometer_MMA7361_SKU_DFR0143)).
* Arduino Uno: Required to derive angle data from the accelerometer coordinates and interface the accelerometer with the system.

The system components are connected as illustrated in the figure below:

![Hardware Connections](ReadmeFiles/SynthHardwareConnections_noLab.png)

## Synth Functionalities
![Synth Block Scheme](ReadmeFiles/SynthClassScheme.png)
![Key Midi Mapping](ReadmeFiles/KeyMidiMapping_noLab.png)


# Guitar Module
![Guitar GUI](ReadmeFiles/GuitarGUI.png)
