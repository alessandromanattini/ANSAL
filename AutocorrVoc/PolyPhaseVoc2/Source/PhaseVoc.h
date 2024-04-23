#pragma once

#include <array>
#include <cmath>
#include "EnvelopeGenerator.h"  // Include the EnvelopeGenerator header

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

class PhaseVocoder {
public:
    PhaseVocoder();
    void process(const float* input, float* output, int numSamples);
    void setDelta(float newDelta);
    void noteOn();  // Add method to trigger note on
    void noteOff(); // Add method to trigger note off
    EnvelopeGenerator envGen;  // Declare the EnvelopeGenerator object

private:
    std::array<float, 256> X;
    std::array<float, 256> Y;
    std::array<float, 256> R;
    std::array<float, 256> window;
    float corr_k;
    unsigned char pos;
    unsigned int delta;
    unsigned int phase;

    void initializeParameters();
};
