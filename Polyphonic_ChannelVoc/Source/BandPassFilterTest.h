/*
  ==============================================================================

    BandPassFilterTest.h
    Created: 18 Apr 2024 8:06:22pm
    Author:  angel

  ==============================================================================
*/

#pragma once

#include "BandPassFilter.h"
#include <JuceHeader.h>

class BandPassFilterTest : public juce::UnitTest {
public:
    BandPassFilterTest() : juce::UnitTest("Band Pass Filter Test", "Audio") {}

    void runTest() override {
        beginTest("Band Pass Filter Functionality");

        const double sampleRate = 44100.0;  // Sample rate for the test
        BandPassFilter filter(sampleRate);
        juce::dsp::ProcessSpec spec{ sampleRate, 512, 1 };
        filter.prepare(spec);
        filter.setFrequency(2000.0);  // Set a different frequency
        filter.setQualityFactor(0.7); // Set a different quality factor
        filter.reset();

        juce::AudioBuffer<float> buffer(1, 512);
        filter.processBlock(buffer, 512);

        // Simple check for non-zero output as basic functionality test
        bool nonZeroOutput = false;
        auto* data = buffer.getReadPointer(0);
        for (int i = 0; i < 512; i++) {
            if (data[i] != 0.0f) {
                nonZeroOutput = true;
                break;
            }
        }

        expect(nonZeroOutput, "Filter should modify the signal.");
    }
};
