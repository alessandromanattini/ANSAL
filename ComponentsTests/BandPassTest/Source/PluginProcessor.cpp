/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
BandPassTestAudioProcessor::BandPassTestAudioProcessor()
    : AudioProcessor(BusesProperties()
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)),
    // Initialize bandPassFilter without arguments
    parameters(*this, nullptr, "Parameters",
        {
            std::make_unique<juce::AudioParameterFloat>("frequency",
                                                        "Frequency",
                                                        20.0f,  // Minimum frequency
                                                        20000.0f,  // Maximum frequency
                                                        1000.0f)  // Default frequency
        })
{
    // Additional setup can be performed here if needed
}


BandPassTestAudioProcessor::~BandPassTestAudioProcessor()
{
}

//==============================================================================
const juce::String BandPassTestAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool BandPassTestAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool BandPassTestAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool BandPassTestAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double BandPassTestAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int BandPassTestAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int BandPassTestAudioProcessor::getCurrentProgram()
{
    return 0;
}

void BandPassTestAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String BandPassTestAudioProcessor::getProgramName (int index)
{
    return {};
}

void BandPassTestAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void BandPassTestAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock) {
    juce::dsp::ProcessSpec spec;
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = getTotalNumOutputChannels();

    bandPassFilter.setSampleRate(sampleRate);  // Set the sample rate
    bandPassFilter.prepare(spec);  // Prepare the filter with the full specification
}

void BandPassTestAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
    bandPassFilter.reset();
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool BandPassTestAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    // Some plugin hosts, such as certain GarageBand versions, will only
    // load plugins that support stereo bus layouts.
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void BandPassTestAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages) {
    juce::ScopedNoDenormals noDenormals;
    const int totalNumInputChannels = getTotalNumInputChannels();
    const int totalNumOutputChannels = getTotalNumOutputChannels();
    const int numSamples = buffer.getNumSamples();

    // Create an output buffer, initialized to the size and number of channels as the input buffer
    juce::AudioBuffer<float> outputBuffer(totalNumOutputChannels, numSamples);

    // Copy the input data to the output buffer to start with the same data (if needed)
    outputBuffer.copyFrom(0, 0, buffer, 0, 0, numSamples);
    if (totalNumInputChannels == totalNumOutputChannels) {
        for (int i = 1; i < totalNumInputChannels; ++i) {
            outputBuffer.copyFrom(i, 0, buffer, i, 0, numSamples);
        }
    }

    // Now process the buffers
    bandPassFilter.processBlock(buffer, outputBuffer, numSamples);

    // Copy the processed data back to the main buffer if that's the desired behavior
    buffer.copyFrom(0, 0, outputBuffer, 0, 0, numSamples);
    if (totalNumInputChannels == totalNumOutputChannels) {
        for (int i = 1; i < totalNumInputChannels; ++i) {
            buffer.copyFrom(i, 0, outputBuffer, i, 0, numSamples);
        }
    }
}



//==============================================================================
bool BandPassTestAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* BandPassTestAudioProcessor::createEditor()
{
    return new BandPassTestAudioProcessorEditor (*this);
}

//==============================================================================
void BandPassTestAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void BandPassTestAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new BandPassTestAudioProcessor();
}

void BandPassTestAudioProcessor::updateFilterFrequency(float frequency) {
    bandPassFilter.setFrequency(frequency);
}
