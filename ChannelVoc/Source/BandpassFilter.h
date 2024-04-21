/*
  ==============================================================================

    Applies a band-pass filter to the input audio signal in a specific frequency band.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class BandPassFilter {
public:
    BandPassFilter(double sampleRate);
    ~BandPassFilter() = default;
    BandPassFilter(const BandPassFilter&) = delete;             // Delete copy constructor
    BandPassFilter& operator=(const BandPassFilter&) = delete;  // Delete copy assignment operator
    BandPassFilter(BandPassFilter&&) noexcept = default;        // Default move constructor
    BandPassFilter& operator=(BandPassFilter&&) noexcept = default; // Default move assignment operator

    void setFrequency(double centerFrequency);
    void setQualityFactor(double qFactor);
    void prepare(const juce::dsp::ProcessSpec& spec);
    void reset();
    void processBlock(juce::AudioBuffer<float>& buffer, int numSamples);

private:
    juce::dsp::IIR::Filter<float> filter;
    std::unique_ptr<juce::dsp::IIR::Coefficients<float>> coefficients;
    double sampleRate;
    double currentFrequency = 1000.0;  // default center frequency
    double currentQFactor = 1.0;       // default quality factor

    void updateFilter();
};
