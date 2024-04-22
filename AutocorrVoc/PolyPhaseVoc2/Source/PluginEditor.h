/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class PolyPhaseVoc2AudioProcessorEditor  : public juce::AudioProcessorEditor
{
public:
    PolyPhaseVoc2AudioProcessorEditor (PolyPhaseVoc2AudioProcessor&);
    ~PolyPhaseVoc2AudioProcessorEditor() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    PolyPhaseVoc2AudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PolyPhaseVoc2AudioProcessorEditor)
};
