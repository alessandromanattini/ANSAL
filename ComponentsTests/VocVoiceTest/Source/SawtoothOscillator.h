/*
  ==============================================================================

    SawtoothOscillator.h

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class SawtoothOscillator {
public:
    SawtoothOscillator();
    void prepare(const juce::dsp::ProcessSpec& spec);
    void setFrequency(float frequency);
    void setLevel(float level);
    void reset();
    void processBlock(juce::AudioBuffer<float>& buffer, int numSamples);
    float getFreq();

private:
    juce::dsp::Oscillator<float> oscillator;
    float level = 1.0f;
    float freq = 0;
};
