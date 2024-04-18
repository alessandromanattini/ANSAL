/*
  ==============================================================================

    VocoderVoiceTest.h
    Created: 18 Apr 2024 8:06:33pm
    Author:  angel

  ==============================================================================
*/

#include <JuceHeader.h>
#include "VocoderVoice.h"

class VocoderVoiceTest : public juce::UnitTest {
public:
    VocoderVoiceTest() : juce::UnitTest("Vocoder Voice Test", "Audio") {}

    void runTest() override {
        beginTest("Vocoder Voice Processing");

        const double sampleRate = 44100.0; // Define the sample rate
        VocoderVoice vocoderVoice(sampleRate); // Pass sample rate to constructor
        juce::dsp::ProcessSpec spec{ sampleRate, 512, 1 };
        vocoderVoice.prepare(spec);
        vocoderVoice.updateParameters(1000.0f, 0.8f, 440.0f, 0.5f);

        juce::AudioBuffer<float> modulator(1, 512);
        juce::AudioBuffer<float> carrier(1, 512);
        juce::AudioBuffer<float> output(1, 512);

        // Fill modulator and carrier with test data
        modulator.clear();
        carrier.clear();
        for (int i = 0; i < 512; i++) {
            modulator.setSample(0, i, std::sin(2.0 * juce::MathConstants<double>::pi * 1000 * i / sampleRate));
            carrier.setSample(0, i, std::sin(2.0 * juce::MathConstants<double>::pi * 440 * i / sampleRate));
        }

        vocoderVoice.processBlock(modulator, carrier, output);

        // Testing whether the output buffer is non-zero
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
