/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
PhaseVocAudioProcessor::PhaseVocAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
    : AudioProcessor(BusesProperties()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
#endif
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)
#endif
    )
#endif
{
    // All voices are automatically initialized - no need to do anything here
}

PhaseVocAudioProcessor::~PhaseVocAudioProcessor()
{
    // No need to delete voices as they are statically allocated
}

//==============================================================================
const juce::String PhaseVocAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool PhaseVocAudioProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
    return true;
#else
    return false;
#endif
}

bool PhaseVocAudioProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
    return true;
#else
    return false;
#endif
}

bool PhaseVocAudioProcessor::isMidiEffect() const
{
#if JucePlugin_IsMidiEffect
    return true;
#else
    return false;
#endif
}

double PhaseVocAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int PhaseVocAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
    // so this should be at least 1, even if you're not really implementing programs.
}

int PhaseVocAudioProcessor::getCurrentProgram()
{
    return 0;
}

void PhaseVocAudioProcessor::setCurrentProgram(int index)
{
}

const juce::String PhaseVocAudioProcessor::getProgramName(int index)
{
    return {};
}

void PhaseVocAudioProcessor::changeProgramName(int index, const juce::String& newName)
{
}

//==============================================================================
void PhaseVocAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
}

void PhaseVocAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool PhaseVocAudioProcessor::isBusesLayoutSupported(const BusesLayout& layouts) const
{
#if JucePlugin_IsMidiEffect
    juce::ignoreUnused(layouts);
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

void PhaseVocAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages) {
    juce::ScopedNoDenormals noDenormals;
    handleMidi(midiMessages);

    auto totalNumInputChannels = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    for (int i = 0; i < maxVoices; ++i) {
        if (voices[i].isActive) {
            for (int channel = 0; channel < totalNumOutputChannels; ++channel) {
                auto* output = buffer.getWritePointer(channel);
                const auto* input = buffer.getReadPointer(channel);

                voices[i].processSample(input, output, buffer.getNumSamples());
            }
        }
    }
}

//==============================================================================
bool PhaseVocAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* PhaseVocAudioProcessor::createEditor()
{
    return new PhaseVocAudioProcessorEditor(*this);
}

//==============================================================================
void PhaseVocAudioProcessor::getStateInformation(juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void PhaseVocAudioProcessor::setStateInformation(const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new PhaseVocAudioProcessor();
}

void PhaseVocAudioProcessor::handleMidi(juce::MidiBuffer& midiMessages) {
    for (const auto midiMessage : midiMessages) {
        auto msg = midiMessage.getMessage();
        if (msg.isNoteOn()) {
            auto* voice = findFreeVoice();
            if (voice) {
                voice->startVoice(msg.getNoteNumber(), 440.0f, getSampleRate());
                DBG("Note on: MIDI value is " << msg.getNoteNumber());
            }
        }
        else if (msg.isNoteOff()) {
            for (int i = 0; i < maxVoices; i++) {
                if (voices[i].noteNumber == msg.getNoteNumber() && voices[i].isActive) {
                    voices[i].stopVoice();
                    DBG("Note off: MIDI value is " << msg.getNoteNumber());
                }
            }
        }
    }
}

VocoderVoice* PhaseVocAudioProcessor::findFreeVoice() {
    for (int i = 0; i < maxVoices; i++) {
        if (!voices[i].isActive) {
            DBG("Voice Found and is now active");
            return &voices[i]; // Return a pointer to the voice in the array
        }
    }
    return nullptr; // All voices are active
}