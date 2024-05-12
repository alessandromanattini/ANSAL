/*
  ==============================================================================

    SimpleCompressor.h
    Created: 23 Apr 2024 12:31:51am
    Author:  angel

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class SimpleCompressor
{
public:
    SimpleCompressor(){}

    void setThreshold(float newThreshold) { threshold = newThreshold; }
    void setRatio(float newRatio) { ratio = newRatio; }

    void process(const float* input, float* output, int numSamples)
    {
        for (int i = 0; i < numSamples; ++i)
        {
            float inputSample = input[i];
            float outputSample = inputSample;

            if (std::abs(inputSample) > threshold)
            {
                float exceedance = std::abs(inputSample) - threshold;
                float compressedExceedance = exceedance / ratio;
                outputSample = (inputSample > 0 ? 1 : -1) * (threshold + compressedExceedance);
            }

            output[i] = outputSample;
        }
    }

private:
    float threshold; // default threshold
    float ratio;     // default compression ratio (4:1)
};
