/*
  ==============================================================================

  ==============================================================================
*/

#include "VocoderProcessor.h"

VocoderProcessor::VocoderProcessor(int numVoices, double sampleRate) {
    voices.reserve(numVoices);
    for (int i = 0; i < numVoices; ++i) {
        voices.emplace_back(sampleRate);
    }
}


void VocoderProcessor::prepare(const juce::dsp::ProcessSpec& spec) {
    this->spec = spec;
    for (auto& voice : voices) {
        voice.prepare(spec);
    }
}

void VocoderProcessor::processBlock(juce::AudioBuffer<float>& modulator, juce::AudioBuffer<float>& carrier, juce::AudioBuffer<float>& output) {
    output.clear(); // Clear output buffer

    for (auto& voice : voices) {
        juce::AudioBuffer<float> tempOutput(carrier.getNumChannels(), carrier.getNumSamples());
        voice.processBlock(modulator, carrier, tempOutput);

        // Mix the output from each voice into the main output buffer
        for (int channel = 0; channel < output.getNumChannels(); ++channel) {
            output.addFrom(channel, 0, tempOutput, channel, 0, tempOutput.getNumSamples());
        }
    }
}

void VocoderProcessor::reset() {
    for (auto& voice : voices) {
        voice.reset();
    }
}