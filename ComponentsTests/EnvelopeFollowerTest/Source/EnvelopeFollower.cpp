/*
  ==============================================================================

  ==============================================================================
*/

#include "EnvelopeFollower.h"

EnvelopeFollower::EnvelopeFollower() {
    // Initialize with some default attack and release times
    setAttackTime(50.0f);  // in milliseconds
    setReleaseTime(200.0f); // in milliseconds
}

void EnvelopeFollower::setAttackTime(float attackMs) {
    // Attack rate calculation, the lower the value, the faster the attack
    ballisticsFilter.setAttackTime(attackMs);
}

void EnvelopeFollower::setReleaseTime(float releaseMs) {
    // Release rate calculation, the lower the value, the faster the release
    ballisticsFilter.setReleaseTime(releaseMs);
}

void EnvelopeFollower::prepare(const juce::dsp::ProcessSpec& spec) {
    ballisticsFilter.prepare(spec);
}

void EnvelopeFollower::reset() {
    ballisticsFilter.reset();
}

float EnvelopeFollower::processSample(float input) {
    // Assuming mono input, channel is set to 0
    return ballisticsFilter.processSample(0, input);
}

