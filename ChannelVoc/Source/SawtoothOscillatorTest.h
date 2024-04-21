/*
  ==============================================================================

    UnitTest.h
    Created: 18 Apr 2024 6:43:38pm
    Author:  angel

  ==============================================================================
*/

#pragma once

#include "SawtoothOscillator.h"
#include <JuceHeader.h>

class SawtoothOscillatorTest : public juce::UnitTest {
public:
    SawtoothOscillatorTest() : juce::UnitTest("Sawtooth Oscillator Test", "Audio") {}

    void runTest() override {
        beginTest("Sawtooth Waveform Generation");
        SawtoothOscillator osc;
        juce::dsp::ProcessSpec spec{ 48000, 512, 1 };
        osc.prepare(spec);
        osc.setFrequency(440.0f); // Standard A tuning frequency
        juce::AudioBuffer<float> buffer(1, 512);
        osc.processBlock(buffer, 512);

        // Test to ensure the buffer is filled (basic check for nonzero output)
        auto* data = buffer.getReadPointer(0);
        bool nonZeroOutput = false;
        for (int i = 0; i < 512; i++) {
            if (data[i] != 0.0f) {
                nonZeroOutput = true;
                break;
            }
        }

        expect(nonZeroOutput, "Buffer should contain non-zero samples.");
    }
};
