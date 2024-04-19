# CMLS - VOCODER

## Overview
This repository contains implementations for two different vocoder: a **Polyphonic ChannelVocoder** and a **Monophonic AutocorrelationVocoder**.

## Polyphonic Channel Vocoder Section
### UML Editor Link
[Polyphonic Vocoder UML Editor](https://lucid.app/lucidchart/ab4a26a6-fc86-46e5-888e-316cc1204135/edit?viewport_loc=-1135%2C-415%2C3913%2C1628%2C0_0&invitationId=inv_0c0c533d-3a09-4dd8-8d4a-a29dd9f9e304)

## Classes Status

| Class               | Status         |
|---------------------|----------------|
| SawtoothOscillator  | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| BandPassFilter      | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| EnvelopeFollower    | ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+)  |
| VocoderVoice        | ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+)     |
| VocoderProcessor    | ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+)     |
| PluginProcessor     | ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+)     |

## Legend
- ![red_circle](https://via.placeholder.com/15/F44336/000000?text=+) : Not implemented
- ![green_circle](https://via.placeholder.com/15/4CAF50/000000?text=+) : Implemented
- ![yellow_circle](https://via.placeholder.com/15/FFEB3B/000000?text=+) : Implementing

## Explanation

### 1. PluginProcessor
**Role:** This is the core of your Vocoder plugin. It interacts with the host DAW (Digital Audio Workstation) and manages audio processing.  
**Functionality:**
- **Inputs:** MIDI data and a voiceSignal (the carrier, e.g., a human voice).
- **Process:**
  - Converts MIDI note data into corresponding frequencies.
  - Sends these frequencies along with the voiceSignal to the VocoderProcessor.

### 2. VocoderProcessor
**Role:** Manages the vocoding process by allocating and controlling multiple VocoderVoice instances, each corresponding to different MIDI notes.  
**Functionality:**
- **Inputs:** Frequencies from MIDI notes and an audio signal (the modulator).
- **Process:**
  - For each active MIDI note, it instantiates or updates a corresponding VocoderVoice with the frequency of the MIDI note and the voiceSignal.
  - Collects outputs from all active VocoderVoice instances and mixes them into a single output stream.

### 3. VocoderVoice
**Role:** Represents a single vocoding voice corresponding to a specific MIDI note.  
**Functionality:**
- **Inputs:** A voiceSignal and the frequency of a MIDI note.
- **Components:**
  - **SawtoothOscillator:** Generates a sawtooth wave at the given frequency.
  - **BandPassFilter:** Filters the voiceSignal around the frequency provided, allowing only a specific frequency band to pass.
  - **EnvelopeFollower:** Tracks the amplitude envelope of the voiceSignal in the specified band.
- **Process:**
  - The SawtoothOscillator provides a continuous tone at the MIDI note frequency.
  - The BandPassFilter processes the voiceSignal to extract frequency components near the MIDI note.
  - The EnvelopeFollower modulates the amplitude of the sawtooth wave based on the dynamics of the filtered voiceSignal.
- **Output:** The modulated sawtooth wave, which is a component of the final vocoded output.

## Test Classes
### SawtoothOscillatorTest
Uses the SawtoothOscillator Class to implement a simple midi polyphonic synthesizer plugin using the JUCE framework, which can generate sawtooth waveforms.

### BandPassFilterTest
* **Audio Processing**: The primary function of this plugin is to apply a band-pass filter to an audio signal. This type of filter allows frequencies within a certain range to pass through while attenuating frequencies outside that range.
* **User Interactivity**: Through a GUI, the plugin offers a slider allowing users to dynamically adjust the center frequency of the band-pass filter.

### EnvelopeFollowerTest
* **MIDI Input Handling**: The plugin processes MIDI messages to control the frequency of the sine wave oscillator. Each time a MIDI note-on message is received, the oscillator's frequency is set based on the MIDI note number, translating it into a frequency using a standard formula.
* **Audio Processing**: During the audio processing block, **the plugin modulates the output of the sine wave oscillator with the envelope extracted from the input audio signal**. This means the loudness of the synthesized sound is dynamically shaped by the loudness characteristics of the incoming audio, creating an interesting effect where the synthesized sound reflects the dynamics of the input.


## Autocorrelation Vocoder Section
The autocorrelation vocoder offers high-quality vocoding but lacks polyphony due to its nature.

## Usage
...

## Contributors
- Angelo Antona
- Alessandro Manattini
