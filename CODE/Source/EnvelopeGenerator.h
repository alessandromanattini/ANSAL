#pragma once

#include <JuceHeader.h>

class EnvelopeGenerator {
public:
    EnvelopeGenerator() {}

    void setAttack(float value) {
        params.attack = value;
        adsr.setParameters(params);  // Update ADSR with new parameters
    }

    void setDecay(float value) {
        params.decay = value;
        adsr.setParameters(params);
    }

    void setSustain(float value) {
        params.sustain = value;
        adsr.setParameters(params);
    }

    void setRelease(float value) {
        params.release = value;
        adsr.setParameters(params);
    }

    void noteOn() {
        adsr.noteOn();  // Start the ADSR envelope
    }

    void noteOff() {
        adsr.noteOff();  // Release the ADSR envelope
    }

    float getNextSample() {
        return adsr.getNextSample();  // Compute and get the next sample from the ADSR envelope
    }

    bool isActive() const {
        return adsr.isActive();
    }

private:
    juce::ADSR adsr;
    juce::ADSR::Parameters params;
};
