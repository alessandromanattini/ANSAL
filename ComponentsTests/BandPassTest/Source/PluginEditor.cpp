/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
BandPassTestAudioProcessorEditor::BandPassTestAudioProcessorEditor (BandPassTestAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    // Set up the slider parameters
    frequencySlider.setSliderStyle(juce::Slider::LinearHorizontal);
    frequencySlider.setRange(20.0, 20000.0, 1.0);
    frequencySlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    frequencySlider.setValue(1000.0);  // Default value
    frequencySlider.addListener(this);

    // Add the slider to the editor
    addAndMakeVisible(&frequencySlider);

    // Set the size of the plugin window
    setSize(400, 300);
}

BandPassTestAudioProcessorEditor::~BandPassTestAudioProcessorEditor()
{
}

//==============================================================================
void BandPassTestAudioProcessorEditor::paint (juce::Graphics& g)
{
    g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));  // Clear the background
    g.setColour(juce::Colours::white);
    g.setFont(15.0f);
    g.drawFittedText("Adjust the Frequency of the BandPass Filter", getLocalBounds(), juce::Justification::centredTop, 1);
}

void BandPassTestAudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
    frequencySlider.setBounds(40, 100, getWidth() - 80, 20);
}

void BandPassTestAudioProcessorEditor::sliderValueChanged(juce::Slider* slider) {
    if (slider == &frequencySlider) {
        audioProcessor.updateFilterFrequency(slider->getValue());
    }
}
