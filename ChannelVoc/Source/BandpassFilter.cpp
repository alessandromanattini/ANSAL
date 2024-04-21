/*
  ==============================================================================

  ==============================================================================
*/

#include "BandPassFilter.h"

BandPassFilter::BandPassFilter(double sampleRate) : sampleRate(sampleRate) {
    updateFilter();  // Initialize filter coefficients
}

void BandPassFilter::setFrequency(double centerFrequency) {
    currentFrequency = centerFrequency;
    updateFilter();
}

void BandPassFilter::setQualityFactor(double qFactor) {
    currentQFactor = qFactor;
    updateFilter();
}

void BandPassFilter::prepare(const juce::dsp::ProcessSpec& spec) {
    filter.prepare(spec);
}

void BandPassFilter::reset() {
    filter.reset();
}

void BandPassFilter::processBlock(juce::AudioBuffer<float>& buffer, int numSamples) {
    juce::dsp::AudioBlock<float> block(buffer);
    juce::dsp::ProcessContextReplacing<float> context(block);
    filter.process(context);
}

void BandPassFilter::updateFilter() {
    auto newCoefficients = juce::dsp::IIR::Coefficients<float>::makeBandPass(sampleRate, currentFrequency, currentQFactor);
    filter.coefficients = *newCoefficients;
}

