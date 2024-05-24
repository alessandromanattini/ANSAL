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
        // Store the current input sample at position 'pos' in array X
        X[pos] = input[i];

        // Initialize a temporary read position
        unsigned char rd = pos;
        // Iterate over the lag values to update the correlation array R
        for (int lag = 0; lag < 128; lag++) {
            // Update the autocorrelation values with a weighted average
            R[lag] = R[lag] * corr_k + (1 - corr_k) * X[pos] * X[rd];
            // Decrement the read position, wrapping around if necessary
            if (rd > 0) --rd;
        }

        // Increment the phase by the phase increment delta
        phase += delta;
        // If the phase has completed a cycle
        if (phase < delta) {
            // Initialize a temporary write position
            unsigned char wy = pos;
            // Compute the scaling factor to normalize the correlation
            float scale = 1.0f / std::sqrt(R[0] + 0x1p-10f);

            // Update the output array Y for the first half of the window
            for (int k = 1; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[128 - k] * window[k] * scale;
            }
            // Update the output array Y for the second half of the window
            for (int k = 0; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[k] * window[k + 128] * scale;
            }
        }

        // Apply envelope to the current output sample and store in the output array
        output[i] = Y[pos] * envGen.getNextSample();
        // Reset the current position in the output array
        Y[pos] = 0.0f;

        // Move to the next position, wrapping around if necessary
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