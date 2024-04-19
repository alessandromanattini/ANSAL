/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
SawtoothSynthAudioProcessor::SawtoothSynthAudioProcessor()
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

SawtoothSynthAudioProcessor::~SawtoothSynthAudioProcessor()
{
}

//==============================================================================
const juce::String SawtoothSynthAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool SawtoothSynthAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool SawtoothSynthAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool SawtoothSynthAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double SawtoothSynthAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int SawtoothSynthAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int SawtoothSynthAudioProcessor::getCurrentProgram()
{
    return 0;
}

void SawtoothSynthAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String SawtoothSynthAudioProcessor::getProgramName (int index)
{
    return {};
}

void SawtoothSynthAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void SawtoothSynthAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = getTotalNumOutputChannels();
}

void SawtoothSynthAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
    oscillators.clear();
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool SawtoothSynthAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
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

void SawtoothSynthAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    buffer.clear();
    juce::MidiMessage m;
    int time;
    juce::MidiBuffer::Iterator it(midiMessages);
    while (it.getNextEvent(m, time)) {
        int noteNumber = m.getNoteNumber();
        if (m.isNoteOn()) {
            float frequency = juce::MidiMessage::getMidiNoteInHertz(noteNumber);
            auto& oscillator = oscillators[noteNumber] = std::make_unique<SawtoothOscillator>();
            oscillator->prepare(spec);
            oscillator->setFrequency(frequency);
            oscillator->setLevel(m.getFloatVelocity());
        }
        else if (m.isNoteOff()) {
            oscillators.erase(noteNumber);
        }
    }

    for (auto& osc : oscillators) {
        osc.second->processBlock(buffer, buffer.getNumSamples());
    }
}

//==============================================================================
bool SawtoothSynthAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* SawtoothSynthAudioProcessor::createEditor()
{
    return new SawtoothSynthAudioProcessorEditor (*this);
}

//==============================================================================
void SawtoothSynthAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void SawtoothSynthAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new SawtoothSynthAudioProcessor();
}
