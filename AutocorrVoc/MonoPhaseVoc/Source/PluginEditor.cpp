/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
SimpleVocoderEditor::SimpleVocoderEditor(SimpleVocoderProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    /*---------corrKslider---------*/
    corr_K_slider.setSliderStyle(juce::Slider::LinearHorizontal);
    corr_K_slider.setRange(0.95, 1.0, 0.001);
    corr_K_slider.setValue(audioProcessor.getCorrK());
    corr_K_slider.addListener(this);
    addAndMakeVisible(corr_K_slider);



    setSize (400, 300);
}

SimpleVocoderEditor::~SimpleVocoderEditor()
{
}

//==============================================================================
void SimpleVocoderEditor::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour (juce::Colours::white);
    g.setFont (15.0f);
}

void SimpleVocoderEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
    corr_K_slider.setBounds(getLocalBounds().reduced(40));
}

void SimpleVocoderEditor::sliderValueChanged(juce::Slider* slider) {
    if (slider == &corr_K_slider)
    {
        audioProcessor.setCorrK(corr_K_slider.getValue());
    }
}