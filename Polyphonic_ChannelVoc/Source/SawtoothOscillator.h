/*
  ==============================================================================

    SawtoothOscillator.h
    Created: 18 Apr 2024
    Author:  angel

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

private:
    juce::dsp::Oscillator<float> oscillator;
    float level = 1.0f;
};
