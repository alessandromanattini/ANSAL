#include "PhaseVoc.h"

PhaseVocoder::PhaseVocoder() {
    initializeParameters();
}

void PhaseVocoder::initializeParameters() {
    corr_k = 0.9992f;

    for (int i = 0; i < 256; ++i) {
        window[i] = 0.5f - 0.5f * std::cos(i * 2.0f * M_PI / 256);
    }

    std::fill(std::begin(X), std::end(X), 0.0f);
    std::fill(std::begin(Y), std::end(Y), 0.0f);
    std::fill(std::begin(R), std::end(R), 0.0f);

    pos = 0;
    phase = 0;
    delta = 0;
}

void PhaseVocoder::process(const float* input, float* output, int numSamples) {
    for (int i = 0; i < numSamples; ++i) {
        X[pos] = input[i]; // Apply envelope to input sample

        unsigned char rd = pos;
        for (int lag = 0; lag < 128; lag++) {
            R[lag] = R[lag] * corr_k + (1 - corr_k) * X[pos] * X[rd];
            if (rd > 0) --rd;
        }

        phase += delta;
        if (phase < delta) {
            unsigned char wy = pos;
            float scale = 1.0f / std::sqrt(R[0] + 0x1p-10f);

            for (int k = 1; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[128 - k] * window[k] * scale;
            }
            for (int k = 0; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[k] * window[k + 128] * scale;
            }
        }

        output[i] = Y[pos] * envGen.getNextSample(); // Apply envelope to output sample
        Y[pos] = 0.0f;

        pos = (pos + 1) % 256;
    }
}

void PhaseVocoder::setDelta(float newDelta) {
    delta = static_cast<unsigned int>(newDelta);
}

void PhaseVocoder::noteOn() {
    envGen.noteOn();
}

void PhaseVocoder::noteOff() {
    envGen.noteOff();
}

void PhaseVocoder::setCorr_k(float value) {
    corr_k = value;
}