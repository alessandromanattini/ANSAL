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

            // Controllo solo se il campione supera la soglia in valore assoluto
            if (std::abs(inputSample) > threshold)
            {
                float exceedance = std::abs(inputSample) - threshold;
                float attenuation = exceedance * (1.0f - 1.0f / ratio);
                outputSample = (inputSample > 0 ? 1 : -1) * (threshold + attenuation);
            }
            // Altrimenti, lascia il campione come è se è sotto la soglia
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
