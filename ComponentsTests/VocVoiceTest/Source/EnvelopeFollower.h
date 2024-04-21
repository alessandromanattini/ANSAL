/*
  ==============================================================================

   Tracks the amplitude envelope of the modulator signal, used for modulating the amplitude of the carrier signal.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class EnvelopeFollower {
public:
    EnvelopeFollower();
    void setAttackTime(float attackMs);
    void setReleaseTime(float releaseMs);
    void prepare(const juce::dsp::ProcessSpec& spec);
    void reset();
    float processSample(int channel, float input);

private:
    juce::dsp::BallisticsFilter<float> ballisticsFilter;
};
