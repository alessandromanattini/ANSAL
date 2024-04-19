/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
EnvelopeFollowerTestAudioProcessor::EnvelopeFollowerTestAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       )
#endif
{
}

EnvelopeFollowerTestAudioProcessor::~EnvelopeFollowerTestAudioProcessor()
{
}

//==============================================================================
const juce::String EnvelopeFollowerTestAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool EnvelopeFollowerTestAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool EnvelopeFollowerTestAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool EnvelopeFollowerTestAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double EnvelopeFollowerTestAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int EnvelopeFollowerTestAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int EnvelopeFollowerTestAudioProcessor::getCurrentProgram()
{
    return 0;
}

void EnvelopeFollowerTestAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String EnvelopeFollowerTestAudioProcessor::getProgramName (int index)
{
    return {};
}

void EnvelopeFollowerTestAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void EnvelopeFollowerTestAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock) {
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = getTotalNumOutputChannels();

    envFollower.prepare(spec);
    oscillator.prepare(spec);
    gain.prepare(spec);
    gain.setGainLinear(0.5f); // Initial gain setting, can be adjusted
}

void EnvelopeFollowerTestAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool EnvelopeFollowerTestAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
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

void EnvelopeFollowerTestAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages) {
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i) {
        buffer.clear(i, 0, buffer.getNumSamples());
    }

    processMidi(midiMessages);
    DBG("Processing MIDI and Audio Block");  // Debug statement

    for (int sample = 0; sample < buffer.getNumSamples(); ++sample) {
        float env = envFollower.processSample(buffer.getSample(0, sample));  // Assuming mono input for simplicity
        float oscSample = oscillator.processSample(0);

        for (int channel = 0; channel < totalNumOutputChannels; ++channel) {
            buffer.setSample(channel, sample, oscSample * env);
        }
    }
}

//==============================================================================
bool EnvelopeFollowerTestAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* EnvelopeFollowerTestAudioProcessor::createEditor()
{
    return new EnvelopeFollowerTestAudioProcessorEditor (*this);
}

//==============================================================================
void EnvelopeFollowerTestAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void EnvelopeFollowerTestAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new EnvelopeFollowerTestAudioProcessor();
}





void EnvelopeFollowerTestAudioProcessor::processMidi(const juce::MidiBuffer& midiMessages) {
    juce::MidiMessage message;
    int time;
    for (juce::MidiBuffer::Iterator it(midiMessages); it.getNextEvent(message, time);) {
        if (message.isNoteOn()) {
            currentFrequency = frequencyFromMidiNote(message.getNoteNumber());
            oscillator.setFrequency(currentFrequency);
        }
    }
}

float EnvelopeFollowerTestAudioProcessor::frequencyFromMidiNote(int midiNote) {
    return 440.0 * std::pow(2.0, (midiNote - 69) / 12.0);
}

