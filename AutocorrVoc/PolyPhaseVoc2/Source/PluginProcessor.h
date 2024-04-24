/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PhaseVoc.h"
#include "SimpleCompressor.h"

#include <array>
#include <vector>

//==============================================================================
/**
*/
class PolyPhaseVoc2AudioProcessor  : public juce::AudioProcessor
{
public:
    //==============================================================================
    PolyPhaseVoc2AudioProcessor();
    ~PolyPhaseVoc2AudioProcessor() override;

    //==============================================================================
    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

   #ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
   #endif

    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    //==============================================================================
    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;

    //==============================================================================
    const juce::String getName() const override;

    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;

    //==============================================================================
    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram (int index) override;
    const juce::String getProgramName (int index) override;
    void changeProgramName (int index, const juce::String& newName) override;

    //==============================================================================
    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;



    /* ______________________________________METODI UTILI PER SLIDERS______________________________________*/
    void updateEnvelopeParameters();
    void updateCompressorParameters();
    void updatePhaseVocParameters();
    /* ____________________________________________________________________________________________________*/


private:

    static constexpr int maxVoices = 5;
    std::array<PhaseVocoder, maxVoices> vocoders;
    std::vector<int> activeNotes; // To keep track of which MIDI notes are currently active

    void handleMidiEvent(const juce::MidiMessage& msg);

    SimpleCompressor comp;

    /* ______________________________________VARIABILI UTILI PER SLIDERS______________________________________*/
    // ENVELOPE GENERATOR VARIABLES
    float attack;
    float decay;
    float sustain;
    float release;

    // SIMPLE COMPRESSOR VARIABLES
    float ratio;
    float threshold;

    // PHASE VOCODER VARIABLES
    float corr_k;
    /* _______________________________________________________________________________________________________*/


    //==============================================================================
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PolyPhaseVoc2AudioProcessor)
};
