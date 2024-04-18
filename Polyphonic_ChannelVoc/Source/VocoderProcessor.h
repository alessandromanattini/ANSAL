/*
  ==============================================================================

  Handles the digital signal processing part of the vocoder. This class manages the audio data flow and processing.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "VocoderVoice.h"
#include <vector>

class VocoderProcessor {
public:
    VocoderProcessor(int numVoices, double sampleRate);
    void prepare(const juce::dsp::ProcessSpec& spec);
    void processBlock(juce::AudioBuffer<float>& modulator, juce::AudioBuffer<float>& carrier, juce::AudioBuffer<float>& output);
    void reset();

private:
    std::vector<VocoderVoice> voices;
    juce::dsp::ProcessSpec spec;
};
