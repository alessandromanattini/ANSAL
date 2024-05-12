/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"
#include "ImageKnob.h"
#include "ImageKnobScreen.h"
#include "ImageKnobBig.h"

//==============================================================================
/**
*/
class PolyPhaseVoc2AudioProcessorEditor  : public juce::AudioProcessorEditor, juce::Slider::Listener
{
public:
    PolyPhaseVoc2AudioProcessorEditor (PolyPhaseVoc2AudioProcessor&);
    ~PolyPhaseVoc2AudioProcessorEditor() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

    void pushDataToVisualiser(const juce::AudioBuffer<float>& buffer);

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    PolyPhaseVoc2AudioProcessor& audioProcessor;

    // =============== Images ======================================================
    juce::Image woodBackground;
    juce::Image background;
    juce::Image visualizerFrame;
    juce::Image sliderHandle;
    juce::Image screen;



    //============ Text Images ====================================================
    /*juce::Image ratioText;
    juce::Image thresholdText;
    juce::Image attackText;
    juce::Image decayText;
    juce::Image sustainText;
    juce::Image releaseText;*/

    //============================ Visualizer ======================================
    juce::AudioVisualiserComponent visualiser{ 1 };

    //============================ Sliders =========================================
    ImageKnobScreen bufferSizeSlider;
    juce::Label bsLabel;
    ImageKnobScreen samplesPerBlockSlider;
    juce::Label spbLabel;

    // Compressor sliders and labels
    ImageKnob ratioSlider;
    juce::Label ratioLabel;
    ImageKnob thresholdSlider;
    juce::Label thresholdLabel;

    // Envelope sliders and labels
    ImageKnob attackSlider;
    juce::Label attackLabel;
    ImageKnob decaySlider;
    juce::Label decayLabel;
    ImageKnob sustainSlider;
    juce::Label sustainLabel;
    ImageKnob releaseSlider;
    juce::Label releaseLabel;

    // Granuliser slider and label
    ImageKnobBig granuliserSlider;
    juce::Label granuliserLabel;

   
    void sliderValueChanged(juce::Slider* slider) override; // Handle sliders changes


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PolyPhaseVoc2AudioProcessorEditor)
};
