/*
  ==============================================================================
    SimpleCompressor
  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>

class SimpleCompressor
{
public:
    SimpleCompressor() {}

    void setThreshold(float newThreshold) { threshold = newThreshold; }
    void setRatio(float newRatio) { ratio = newRatio; }

    void process(const float* input, float* output, int numSamples)
    {
        for (int i = 0; i < numSamples; ++i)
        {
            float inputSample = input[i] * ratio;
            float outputSample = inputSample;

            // Check only if the sample exceeds the threshold in absolute value
            if (std::abs(inputSample) > threshold)
            {
                float exceedance = std::abs(inputSample) - threshold;
                float attenuation = exceedance * (1.0f - 1.0f / ratio);
                outputSample = (inputSample > 0 ? 1 : -1) * (threshold + attenuation);
            }
            // Otherwise, leave the sample as it is if it's below the threshold
            else
            {
                outputSample = inputSample;
            }

            output[i] = outputSample;
        }
    }

private:
    float threshold;
    float ratio;
};