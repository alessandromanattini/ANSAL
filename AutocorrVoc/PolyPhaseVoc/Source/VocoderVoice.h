/*
  ==============================================================================

    phaseVoc.h
    Created: 21 Apr 2024 4:10:16pm
    Author:  angel

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

#define M_PI 3.14159265358979323846


class VocoderVoice {
public:
    VocoderVoice() : isActive(false), noteNumber(-1) {
        memset(X, 0, sizeof(X));
        memset(Y, 0, sizeof(Y));
        memset(R, 0, sizeof(R));
        phase = 0;
        delta = 0;
        corr_k = 0.9975f;
        pos = 0;
        prepareWindow();
    }

    void prepareWindow() {
        for (int i = 0; i < 256; i++) {
            window[i] = 0.5f - 0.5f * cosf(i * 0x1p-8f * 2.0f * M_PI);
        }
    }

    void startVoice(int midiNote, float frequency, float sampleRate) {
        DBG("_______________________________________________________VoiceStarted " << frequency);
        noteNumber = midiNote;
        isActive = true;
        delta = frequency * exp2f((midiNote - 69) / 12.0f) * 0x1p32f / sampleRate;
    }

    void stopVoice() {
        isActive = false;
        noteNumber = -1;
    }

    void processSample(const float* input, float* output, int numSamples) {
        if (!isActive) return; // Only process samples if the voice is active

        for (int i = 0; i < numSamples; i++) {
            DBG("======================================================0input[" << i << "]: " << input[i]);
            X[pos] = *input++;
            unsigned char rd = pos;
            for (int lag = 0; lag < 128; lag++) R[lag] = R[lag] * corr_k + (1 - corr_k) * X[pos] * X[rd--];

            phase += delta;
            if (phase < delta) {
                unsigned char wy = pos;
                const float scale = 1.0f / sqrtf(R[0] + 0x1p-10f);
                for (int k = 1; k < 128; k++)  Y[wy++] += R[128 - k] * window[k] * scale;
                for (int k = 0; k < 128; k++)  Y[wy++] += R[k] * window[k + 128] * scale;
                DBG("X[pos]: " << X[pos] << ", R[0]: " << R[0] << ", scale: " << scale);
            }
            *output++ = Y[pos];
            DBG("_______________________________________________________The outputValue is " << Y[pos]);
            Y[pos++] = 0.0f; // Clear after output to prevent old data mixing
        }
    }

    bool isActive;
    int noteNumber;

private:
    float X[256], Y[256], R[256], window[256];
    unsigned char pos;
    unsigned int delta, phase;
    float corr_k;
};