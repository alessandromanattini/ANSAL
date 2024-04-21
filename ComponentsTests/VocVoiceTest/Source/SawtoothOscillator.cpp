/*
  ==============================================================================

    SawtoothOscillator.cpp

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
    freq = frequency;
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

float SawtoothOscillator::getFreq() {
    return freq;
}
