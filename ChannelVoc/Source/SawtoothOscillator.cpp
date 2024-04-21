/*
  ==============================================================================

    SawtoothOscillator.cpp
    Created: 18 Apr 2024 4:21:58pm
    Author:  angel

  ==============================================================================
*/

#include "SawtoothOscillator.h"

SawtoothOscillator::SawtoothOscillator() : oscillator([](float x) { return 2.0f * (x / juce::MathConstants<float>::pi - 1.0f); }) {
    // Initialize the oscillator with a sawtooth function
}

void SawtoothOscillator::prepare(const juce::dsp::ProcessSpec& spec) {
    oscillator.prepare(spec);
}

void SawtoothOscillator::setFrequency(float frequency) {
    oscillator.setFrequency(frequency);
}

void SawtoothOscillator::setLevel(float level) {
    this->level = level;
}

void SawtoothOscillator::reset() {
    oscillator.reset();
}

void SawtoothOscillator::processBlock(juce::AudioBuffer<float>& buffer, int numSamples) {
    juce::dsp::AudioBlock<float> block(buffer);
    juce::dsp::ProcessContextReplacing<float> context(block);
    oscillator.process(context);
    buffer.applyGain(level);
}
