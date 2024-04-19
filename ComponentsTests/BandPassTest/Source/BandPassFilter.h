/*
  ==============================================================================

    Applies a band-pass filter to the input audio signal in a specific frequency band.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class BandPassFilter {
public:
    BandPassFilter();
    void setSampleRate(double rate);
    void setFrequency(double centerFrequency);
    void setQualityFactor(double qFactor);
    void prepare(const juce::dsp::ProcessSpec& spec);
    void reset();
    // Updated method signature
    void processBlock(const juce::AudioBuffer<float>& inputBuffer, juce::AudioBuffer<float>& outputBuffer, int numSamples);

private:
    juce::dsp::IIR::Filter<float> filter;
    std::unique_ptr<juce::dsp::IIR::Coefficients<float>> coefficients;
    double sampleRate = 0;
    double currentFrequency = 1000.0;
    double currentQFactor = 1.0;

    void updateFilter();
};
