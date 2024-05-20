#ifndef HIGHPASSFILTER_H
#define HIGHPASSFILTER_H

#include <JuceHeader.h>
#include <juce_dsp/juce_dsp.h> // Include the DSP module

class HighPassFilter
{
public:
    HighPassFilter() = default;
    ~HighPassFilter() = default;

    void prepareToPlay(double sampleRate, int samplesPerBlock)
    {
        juce::dsp::ProcessSpec spec;
        spec.sampleRate = sampleRate;
        spec.maximumBlockSize = samplesPerBlock;
        spec.numChannels = 2; // stereo

        filter.prepare(spec);
        filter.reset();
    }

    void setCutoffFrequency(float frequency)
    {
        *filter.state = *juce::dsp::IIR::Coefficients<float>::makeHighPass(44100.0, frequency);
    }

    void processBlock(juce::AudioBuffer<float>& buffer)
    {
        juce::dsp::AudioBlock<float> block(buffer);
        juce::dsp::ProcessContextReplacing<float> context(block);
        filter.process(context);
    }

private:
    juce::dsp::ProcessorDuplicator<juce::dsp::IIR::Filter<float>, juce::dsp::IIR::Coefficients<float>> filter;
};

#endif // HIGHPASSFILTER_H
