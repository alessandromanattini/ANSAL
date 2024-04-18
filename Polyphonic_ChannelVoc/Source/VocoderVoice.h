/*
  ==============================================================================

  Represents a single polyphonic voice. Multiple instances can be managed by the VocoderProcessor to allow for polyphony.


  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "EnvelopeFollower.h"
#include "SawtoothOscillator.h"
#include "BandPassFilter.h"

class VocoderVoice {
public:
    VocoderVoice(double sampleRate);
    void prepare(const juce::dsp::ProcessSpec& spec);
    void processBlock(const juce::AudioBuffer<float>& modulator, juce::AudioBuffer<float>& carrier, juce::AudioBuffer<float>& output);
    void updateParameters(float modulatorFreq, float modulatorQ, float carrierFreq, float carrierLevel);
    void reset(); 

private:
    EnvelopeFollower envelopeFollower;
    SawtoothOscillator carrierOscillator;
    BandPassFilter modulatorFilter;

    juce::dsp::Gain<float> gain;
};
