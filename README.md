# CMLS - VOCODER

## Overview
This repository contains implementations for two different vocoder: a **ChannelVocoder** and a **AutocorrelationVocoder**.

## Autocorrelation Vocoder Section
The plugin employs a set of internally managed vocoder instances, each capable of processing a monophonic signal. When a MIDI note is played, a vocoder instance is allocated to that note, and the corresponding pitch transformation is applied. The outputs of all active vocoder instances are then mixed together to form a polyphonic output.

Autocorrelation is used to analyze the input signal and identify its periodicity, which informs the pitch shifting process. The windowing function within the phase vocoder ensures that phase coherence is maintained, resulting in a smooth and continuous output signal.

### Features
* Polyphonic Capabilities: Unlike a monophonic vocoder, which processes a single note at a time, the PolyPhase Vocoder can handle multiple notes simultaneously, allowing for complex soundscapes and harmonies.
* Phase Vocoder Processing: At the core of the plugin is the phase vocoder process, which performs pitch shifting and time stretching without affecting the other characteristics of the sound.
* Leaky Autocorrelation: This feature ensures that the signal retains a degree of temporal coherence, resulting in a more natural and less 'robotic' sound than traditional vocoders.
* Dynamic MIDI Control: The plugin can be controlled via MIDI, allowing for dynamic pitch manipulation during a performance.
* Stereo Processing: While the internal processing is monophonic, the output is stereo, ensuring compatibility with conventional music production workflows.

## Classes Status

| Class                     | Status                                                                |
|---------------------------|-----------------------------------------------------------------------|
| PhaseVoc                  | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| PluginProcessor           | ![yellow_circle](https://via.placeholder.com/15/FFEB3B/000000?text=+) |

## Legend
- ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+) : Not implemented
- ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+) : Implemented
- ![yellow_circle](https://via.placeholder.com/15/FFEB3B/000000?text=+) : Implementing



## Channel Vocoder Section
### UML Editor Link
[Polyphonic Vocoder UML Editor](https://lucid.app/lucidchart/ab4a26a6-fc86-46e5-888e-316cc1204135/edit?viewport_loc=-1135%2C-415%2C3913%2C1628%2C0_0&invitationId=inv_0c0c533d-3a09-4dd8-8d4a-a29dd9f9e304)

## Classes Status

| Class                     | Status                                                                |
|---------------------------|-----------------------------------------------------------------------|
| SawtoothOscillator        | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| BandPassFilter            | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| EnvelopeFollower          | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| ZCR noise/osc selector    | ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+)     |
| VocoderVoice              | ![yellow_circle](https://via.placeholder.com/15/FFEB3B/000000?text=+)  |

## Legend
- ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+) : Not implemented
- ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+) : Implemented
- ![yellow_circle](https://via.placeholder.com/15/FFEB3B/000000?text=+) : Implementing

## Components Explanation
### VocoderVoice
**Role:**  Manages the vocoding process by allocating and controlling multiple BPF, EnvFoll. and SawOsc. instances, each corresponding to different MIDI notes.  
**Functionality:**
- **Inputs:** A voiceSignal and a MIDI note.
- **Components:**
  - **SawtoothOscillator:** Generates a sawtooth wave at the given frequency.
  - **BandPassFilter:** Filters the voiceSignal around the frequency provided, allowing only a specific frequency band to pass.
  - **EnvelopeFollower:** Tracks the amplitude envelope of the voiceSignal in the specified band.
- **Process:**
  - The SawtoothOscillator provides a continuous tone at the MIDI note frequency.
  - The BandPassFilter processes the voiceSignal to extract frequency components near the MIDI note.
  - The EnvelopeFollower modulates the amplitude of the sawtooth wave based on the dynamics of the filtered voiceSignal.
- **Output:** The modulated sawtooth waves.

## Test Classes
### SawtoothOscillatorTest
Uses the SawtoothOscillator Class to implement a simple midi polyphonic synthesizer plugin using the JUCE framework, which can generate sawtooth waveforms.

### BandPassFilterTest
* **Audio Processing**: The primary function of this plugin is to apply a band-pass filter to an audio signal. This type of filter allows frequencies within a certain range to pass through while attenuating frequencies outside that range.
* **User Interactivity**: Through a GUI, the plugin offers a slider allowing users to dynamically adjust the center frequency of the band-pass filter.

### EnvelopeFollowerTest
* **MIDI Input Handling**: The plugin processes MIDI messages to control the frequency of the sine wave oscillator. Each time a MIDI note-on message is received, the oscillator's frequency is set based on the MIDI note number, translating it into a frequency using a standard formula.
* **Audio Processing**: During the audio processing block, **the plugin modulates the output of the sine wave oscillator with the envelope extracted from the input audio signal**. This means the loudness of the synthesized sound is dynamically shaped by the loudness characteristics of the incoming audio, creating an interesting effect where the synthesized sound reflects the dynamics of the input.

### VocVoiceTest
It's a test version of the complete vocoder. It doesn't support noise generation, so it's a vocoder devoid of word intelligibility.



## Contributors
- Angelo Antona
- Alessandro Manattini
- Salvatore Benvenuto Zocco