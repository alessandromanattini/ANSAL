/*
  ==============================================================================

    VocoderProcessorTest.h
    Created: 18 Apr 2024 8:06:43pm
    Author:  angel

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "VocoderProcessor.h"

class VocoderProcessorTest : public juce::UnitTest {
public:
    VocoderProcessorTest() : juce::UnitTest("Vocoder Processor Test", "Audio") {}

    void runTest() override {
        beginTest("Vocoder Processor Functionality");

        int numVoices = 4;
        double sampleRate = 44100.0; // Define the sample rate
        VocoderProcessor processor(numVoices, sampleRate); // Pass both numVoices and sampleRate to the constructor
        juce::dsp::ProcessSpec spec{ sampleRate, 512, 1 };
        processor.prepare(spec);

        juce::AudioBuffer<float> modulator(1, 512), carrier(1, 512), output(1, 512);
        modulator.clear();
        carrier.clear();
        output.clear();

        // Fill modulator and carrier with test data
        for (int i = 0; i < 512; i++) {
            modulator.setSample(0, i, std::sin(2.0 * juce::MathConstants<double>::pi * 200 * i / spec.sampleRate));
            carrier.setSample(0, i, std::sin(2.0 * juce::MathConstants<double>::pi * 440 * i / spec.sampleRate));
        }

        processor.processBlock(modulator, carrier, output);

        // Check that the output is not empty
        bool nonZeroOutput = false;
        for (int i = 0; i < 512; i++) {
            if (output.getSample(0, i) != 0.0f) {
                nonZeroOutput = true;
                break;
            }
        }

        expect(nonZeroOutput, "Output should contain non-zero samples after processing.");
    }
};
