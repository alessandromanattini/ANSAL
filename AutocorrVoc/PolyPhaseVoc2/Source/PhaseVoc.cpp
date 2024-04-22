#include "PhaseVoc.h"

PhaseVocoder::PhaseVocoder(){
    initializeParameters();
}

void PhaseVocoder::initializeParameters() {
    corr_k = 0.9975f; // Leaky integration factor, you might want to tweak this

    // Initialize the Hann window function
    for (int i = 0; i < 256; ++i) {
        window[i] = 0.5f - 0.5f * std::cos(i * 2.0f * M_PI / 256);
    }

    // Initialize buffers
    std::fill(std::begin(X), std::end(X), 0.0f);
    std::fill(std::begin(Y), std::end(Y), 0.0f);
    std::fill(std::begin(R), std::end(R), 0.0f);

    pos = 0;
    phase = 0;
    delta = 0; // Set through MIDI, ensure it's reset here if not actively playing a note
}



void PhaseVocoder::process(const float* input, float* output, int numSamples) {
    for (int i = 0; i < numSamples; ++i) {
        X[pos] = input[i]; // Assign the input to the current position in the buffer

        // Update the read position for the autocorrelation
        unsigned char rd = pos;

        // Perform leaky autocorrelation
        for (int lag = 0; lag < 128; lag++) {
            R[lag] = R[lag] * corr_k + (1 - corr_k) * X[pos] * X[rd]; // Notice X[rd] instead of X[rd--]
            if (rd > 0) {
                --rd;  // Only decrement if rd is greater than 0
            }
        }

        // Increment and wrap phase
        phase += delta;
        if (phase < delta) { // If phase wraps around, perform pitch-synchronous operation
            unsigned char wy = pos; // Output write position
            float scale = 1.0f / std::sqrt(R[0] + 0x1p-10f); // Gain correction

            // Synthesize output and apply window function
            for (int k = 1; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[128 - k] * window[k] * scale;  // Add backwards
            }
            for (int k = 0; k < 128; ++k, ++wy) {
                Y[wy % 256] += R[k] * window[k + 128] * scale;  // Add forwards
            }
        }

        // Copy the output from the current position to the output buffer and clear the current position
        output[i] = Y[pos];
        Y[pos] = 0.0f;

        // Increment and wrap the position
        pos = (pos + 1) % 256;
    }
}


void PhaseVocoder::setDelta(float newDelta) {
    delta = static_cast<unsigned int>(newDelta);
}
