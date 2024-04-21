/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
VocVoiceTestAudioProcessor::VocVoiceTestAudioProcessor()
    : AudioProcessor(BusesProperties()
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)),
    parameters(*this, nullptr, "Parameters", {
        std::make_unique<juce::AudioParameterFloat>("frequency",
                                                    "Frequency",
                                                    20.0f,      // Minimum frequency
                                                    20000.0f,   // Maximum frequency
                                                    1000.0f)    // Default frequency
        }),
    level(1.0f),
    qFactor(1.0f),
    attackTime(50.0f), // ms
    releaseTime(200.0f) // ms
{
    // Additional setup can be performed here if needed
}


VocVoiceTestAudioProcessor::~VocVoiceTestAudioProcessor()
{
}

//==============================================================================
const juce::String VocVoiceTestAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool VocVoiceTestAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool VocVoiceTestAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool VocVoiceTestAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double VocVoiceTestAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int VocVoiceTestAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int VocVoiceTestAudioProcessor::getCurrentProgram()
{
    return 0;
}

void VocVoiceTestAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String VocVoiceTestAudioProcessor::getProgramName (int index)
{
    return {};
}

void VocVoiceTestAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void VocVoiceTestAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    //Sawtooth
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = getTotalNumOutputChannels();
    envFollower.prepare(spec);

    // Prepare the buffers for processing
    oscillatorBuffer.setSize(spec.numChannels, samplesPerBlock);
    bandPassBuffer.setSize(spec.numChannels, samplesPerBlock);
    envelopeBuffer.setSize(spec.numChannels, samplesPerBlock);
    processedBuffer.setSize(spec.numChannels, samplesPerBlock);
}

void VocVoiceTestAudioProcessor::releaseResources()
{
    oscillators.clear();
    bandPassFilter.reset();
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool VocVoiceTestAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
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

void VocVoiceTestAudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
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

    // Save audioContext properties
    const int totalNumInputChannels = getTotalNumInputChannels();
    const int totalNumOutputChannels = getTotalNumOutputChannels();
    const int numSamples = buffer.getNumSamples();

    // Clear buffers for processing
    oscillatorBuffer.clear();
    bandPassBuffer.clear();
    envelopeBuffer.clear();
    processedBuffer.clear();
    for (auto& osc : oscillators) {
        
        // Parameters initialization
        osc.second->setLevel(level);
        bandPassFilter.prepare(spec);
        bandPassFilter.setQualityFactor(qFactor);


        // Sawtooth
        osc.second->processBlock(oscillatorBuffer, numSamples);
        
        // BandPassFilter
        bandPassFilter.setFrequency(osc.second->getFreq());
        bandPassFilter.processBlock(buffer, bandPassBuffer, numSamples);

        
        // EnvelopeFollower
        envFollower.setAttackTime(attackTime);
        envFollower.setReleaseTime(releaseTime);
        // Inside your audio processing loop
        for (int channel = 0; channel < buffer.getNumChannels(); ++channel) {
            for (int sample = 0; sample < buffer.getNumSamples(); ++sample) {
                float sampleValue = bandPassBuffer.getSample(channel, sample);
                float processedSample = envFollower.processSample(channel, sampleValue);
                envelopeBuffer.setSample(channel, sample, processedSample);
            }
        }
        
        // FinalProcessing
        for (int channel = 0; channel < totalNumOutputChannels; ++channel) {
            for (int sample = 0; sample < numSamples; ++sample) {
                float oscillatorSample = oscillatorBuffer.getSample(channel, sample);
                float envelopeSample = envelopeBuffer.getSample(channel, sample);
                processedBuffer.addSample(channel, sample, oscillatorSample * envelopeSample);
            }
        }
    }
    buffer.clear();
    // Put result to output
    for (int channel = 0; channel < totalNumOutputChannels; ++channel) {
        for (int sample = 0; sample < numSamples; ++sample) {
            buffer.setSample(channel, sample, processedBuffer.getSample(channel, sample));
        }
    }

}

//==============================================================================
bool VocVoiceTestAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* VocVoiceTestAudioProcessor::createEditor()
{
    return new VocVoiceTestAudioProcessorEditor (*this);
}

//==============================================================================
void VocVoiceTestAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void VocVoiceTestAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new VocVoiceTestAudioProcessor();
}
