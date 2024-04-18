/*
  ==============================================================================

    Represents a single polyphonic voice. Multiple instances can be managed by the VocoderProcessor to allow for polyphony.

  ==============================================================================
*/

#include "VocoderVoice.h"

VocoderVoice::VocoderVoice(double sampleRate) : modulatorFilter(sampleRate) {
    // Other initializations...
}
void VocoderVoice::prepare(const juce::dsp::ProcessSpec& spec) {
    envelopeFollower.prepare(spec);
    carrierOscillator.prepare(spec);
    modulatorFilter.prepare(spec);
    gain.prepare(spec);
}

void VocoderVoice::processBlock(const juce::AudioBuffer<float>& modulator, juce::AudioBuffer<float>& carrier, juce::AudioBuffer<float>& output) {
    // Process modulator through filter
    juce::AudioBuffer<float> filteredModulator;
    filteredModulator.makeCopyOf(modulator);
    modulatorFilter.processBlock(filteredModulator, filteredModulator.getNumSamples());

    // Process envelope follower on the filtered modulator
    for (int sample = 0; sample < filteredModulator.getNumSamples(); ++sample) {
        float env = envelopeFollower.processSample(filteredModulator.getSample(0, sample));
        gain.setGainLinear(env);
    }

    // Apply gain to the carrier
    juce::dsp::AudioBlock<float> block(carrier);
    juce::dsp::ProcessContextReplacing<float> context(block);
    gain.process(context);

    // Process carrier with the sawtooth oscillator
    carrierOscillator.processBlock(carrier, carrier.getNumSamples());

    output.makeCopyOf(carrier);
}

void VocoderVoice::updateParameters(float modulatorFreq, float modulatorQ, float carrierFreq, float carrierLevel) {
    modulatorFilter.setFrequency(modulatorFreq);
    modulatorFilter.setQualityFactor(modulatorQ);
    carrierOscillator.setFrequency(carrierFreq);
    carrierOscillator.setLevel(carrierLevel);
}

void VocoderVoice::reset() {
    envelopeFollower.reset();
    carrierOscillator.reset();
    modulatorFilter.reset();
    gain.reset();  // Ensure this call is appropriate as per juce::dsp::Gain's API
}