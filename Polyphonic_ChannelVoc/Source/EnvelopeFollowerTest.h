/*
  ==============================================================================

    EnvelopeFollowerTest.h
    Created: 18 Apr 2024 8:06:03pm
    Author:  angel

  ==============================================================================
*/

#pragma once

#include "EnvelopeFollower.h"
#include <JuceHeader.h>

class EnvelopeFollowerTest : public juce::UnitTest {
public:
    EnvelopeFollowerTest() : juce::UnitTest("Envelope Follower Test", "Audio") {}

    void runTest() override {
        beginTest("Envelope Follower Functionality");

        EnvelopeFollower follower;
        juce::dsp::ProcessSpec spec{ 48000, 512, 1 };
        follower.prepare(spec);
        follower.setAttackTime(10.0f);
        follower.setReleaseTime(100.0f);
        follower.reset();

        float testInput = 0.5f;
        float output = follower.processSample(testInput);

        // Simple check to ensure the output is behaving as expected
        expect(output >= 0.0f, "Envelope follower output should be non-negative.");
        expect(output <= 1.0f, "Envelope follower output should not exceed 1.0.");
    }
};
