/*
  ==============================================================================

  ==============================================================================
*/

#include "BandPassFilter.h"

BandPassFilter::BandPassFilter() {
    // Constructor now empty, actual setup will happen in setSampleRate or prepare
}

void BandPassFilter::setSampleRate(double rate) {
    sampleRate = rate;
    updateFilter();
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
    sampleRate = spec.sampleRate;  // Ensure sample rate is updated
    updateFilter();  // Update filter coefficients with correct sample rate
}

void BandPassFilter::reset() {
    filter.reset();
}

void BandPassFilter::processBlock(const juce::AudioBuffer<float>& inputBuffer, juce::AudioBuffer<float>& outputBuffer, int numSamples) {
    // Assuming that the input and output buffers are already cleared and have the same number of channels
    for (int channel = 0; channel < inputBuffer.getNumChannels(); ++channel) {
        auto* input = inputBuffer.getReadPointer(channel);
        auto* output = outputBuffer.getWritePointer(channel);

        // Copy data from input to output
        std::copy(input, input + numSamples, output);

        // Create an AudioBlock from the output buffer
        juce::dsp::AudioBlock<float> block(outputBuffer);
        block = block.getSingleChannelBlock(channel).getSubBlock(0, numSamples);

        // Process the data in-place in the output buffer
        juce::dsp::ProcessContextReplacing<float> context(block);
        filter.process(context);
    }
}

void BandPassFilter::updateFilter() {
    if (sampleRate > 0) {  // Ensure we have a valid sample rate
        auto newCoefficients = juce::dsp::IIR::Coefficients<float>::makeBandPass(sampleRate, currentFrequency, currentQFactor);
        filter.coefficients = *newCoefficients;
    }
}

