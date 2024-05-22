/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"
#include "SimpleCompressor.h"
//#include "ImageKnob.h"

//==============================================================================
PolyPhaseVoc2AudioProcessorEditor::PolyPhaseVoc2AudioProcessorEditor(PolyPhaseVoc2AudioProcessor& p)
    : AudioProcessorEditor(&p), audioProcessor(p)


{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize(900, 600);

    //customLookAndFeel = std::make_unique <CustomLookAndFeel>();

    // font KNOBS
    auto typeface = juce::Typeface::createSystemTypefaceFor(BinaryData::JuliusSansOneRegular_ttf, BinaryData::JuliusSansOneRegular_ttfSize);
    juce::Font customFontKnobComp(typeface);
    juce::Font customFontKnobEnv(typeface);
    customFontKnobComp.setHeight(18);
    customFontKnobEnv.setHeight(18);
    //customFontKnobComp.setBold(true);
    //customFontKnobEnv.setBold(true);

    // font SCREEN KNOBS
    auto typeface1 = juce::Typeface::createSystemTypefaceFor(BinaryData::KronaOneRegular_ttf, BinaryData::KronaOneRegular_ttfSize);
    juce::Font customFontKnobScreen(typeface1);
    customFontKnobScreen.setHeight(13);
    customFontKnobScreen.setBold(true);

    juce::Font customFontKnobCompBold = customFontKnobComp.withStyle(juce::Font::bold);

    // Load images
    woodBackground = juce::ImageCache::getFromMemory(BinaryData::sfondoLegnoNero_jpg, BinaryData::sfondoLegnoNero_jpgSize);
    background = juce::ImageCache::getFromMemory(BinaryData::Subtract_png, BinaryData::Subtract_pngSize);
    visualizerFrame = juce::ImageCache::getFromMemory(BinaryData::sfondoMetallo_3_png, BinaryData::sfondoMetallo_3_pngSize);
    screen = juce::ImageCache::getFromMemory(BinaryData::Rectangle_27_png, BinaryData::Rectangle_27_pngSize);

    // Load text images
    //ratioText = juce::ImageCache::getFromMemory(BinaryData::RATIO_png, BinaryData::RATIO_pngSize);
    //thresholdText = juce::ImageCache::getFromMemory(BinaryData::THR_png, BinaryData::THR_pngSize);
    juce::Image ansalLogo = juce::ImageCache::getFromMemory(BinaryData::ANSAL_LOGO_png, BinaryData::ANSAL_LOGO_pngSize);
    logoComponent.setImage(ansalLogo);
    addAndMakeVisible(logoComponent);

    vocoderLogo.setText("VOCODER", juce::dontSendNotification);
    vocoderLogo.setFont(customFontKnobScreen);
    vocoderLogo.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    // Increase font size for vocoderLogo
    juce::Font customFontVocoderLogo(typeface1);
    customFontVocoderLogo.setHeight(30); // Increase the height to make it bigger
    vocoderLogo.setFont(customFontVocoderLogo);
    addAndMakeVisible(vocoderLogo);


    /*___________________________________________________________________________*/

    // Visualizer
    visualiser.setBufferSize(512);
    visualiser.setSamplesPerBlock(512);
    visualiser.setColours(juce::Colours::black, juce::Colours::white);
    addAndMakeVisible(visualiser);

    /*___________________________________________________________________________*/

    // Knobs

    bufferSizeSlider.setRange(128, 2048, 128);
    bufferSizeSlider.setValue(512);
    bufferSizeSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    bufferSizeSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    bufferSizeSlider.onValueChange = [this] {
        visualiser.setBufferSize((int)bufferSizeSlider.getValue());
        };

    bsLabel.setText("BUFF SIZE", juce::dontSendNotification);
    bsLabel.setFont(customFontKnobScreen);
    bsLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&bufferSizeSlider);
    addAndMakeVisible(bsLabel);
    bufferSizeSlider.addListener(this);

    // Samples per block slider
    samplesPerBlockSlider.setRange(128, 2048, 128);  // Min, max, step
    samplesPerBlockSlider.setValue(512);  // Default value
    samplesPerBlockSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    samplesPerBlockSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    samplesPerBlockSlider.onValueChange = [this] {
        visualiser.setSamplesPerBlock((int)samplesPerBlockSlider.getValue());
        };

    spbLabel.setText("SPL", juce::dontSendNotification);
    spbLabel.setFont(customFontKnobScreen);
    spbLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&samplesPerBlockSlider);
    addAndMakeVisible(spbLabel);
    samplesPerBlockSlider.addListener(this);

    // ----------------------Knobs Compressor------------------------------
    ratioSlider.setRange(1.1, 20.0, 1.0);
    ratioSlider.setValue(0.0);
    ratioSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    ratioSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    ratioSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    ratioLabel.setText("SAT", juce::dontSendNotification);
    ratioLabel.setFont(customFontKnobComp);
    ratioLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(ratioLabel);
    addAndMakeVisible(&ratioSlider);
    ratioSlider.addListener(this);


    HPFSlider.setRange(0, 1000, 1);
    HPFSlider.setValue(200);
    HPFSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    HPFSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    HPFSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    HPFLabel.setText("HPF", juce::dontSendNotification);
    HPFLabel.setFont(customFontKnobComp);
    HPFLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&HPFSlider);
    addAndMakeVisible(HPFLabel);
    HPFSlider.addListener(this);

    // ---------------------- Knob Envelope ------------------------------------

    attackSlider.setRange(0.0, 1.5, 0.001);
    attackSlider.setValue(0.0);
    attackSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    attackSlider.setColour(juce::Slider::thumbColourId, juce::Colours::white);
    attackSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    attackLabel.setText("ATTACK", juce::dontSendNotification);
    attackLabel.setFont(customFontKnobEnv);
    attackLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&attackSlider);
    addAndMakeVisible(attackLabel);
    attackSlider.addListener(this);


    decaySlider.setRange(0.0, 2.0, 0.001);
    decaySlider.setValue(0.0);
    decaySlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    decaySlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    decaySlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    decayLabel.setText("DECAY", juce::dontSendNotification);
    decayLabel.setFont(customFontKnobEnv);
    decayLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&decaySlider);
    addAndMakeVisible(decayLabel);
    decaySlider.addListener(this);


    sustainSlider.setRange(0.0, 1.0, 0.01);
    sustainSlider.setValue(0.0);
    sustainSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    sustainSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    sustainSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    sustainLabel.setText("SUSTAIN", juce::dontSendNotification);
    sustainLabel.setFont(customFontKnobEnv);
    sustainLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&sustainSlider);
    addAndMakeVisible(sustainLabel);
    sustainSlider.addListener(this);


    releaseSlider.setRange(0.0, 3.0, 0.1);
    releaseSlider.setValue(0.0);
    releaseSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    releaseSlider.setColour(juce::Slider::thumbColourId, juce::Colours::white);
    releaseSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    releaseLabel.setText("RELEASE", juce::dontSendNotification);
    releaseLabel.setFont(customFontKnobEnv);
    releaseLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    addAndMakeVisible(&releaseSlider);
    addAndMakeVisible(releaseLabel);
    releaseSlider.addListener(this);


    /*--------------- Granuliser ----------------------------------------------*/
    granuliserSlider.setRange(0.9950, 0.9999, 0.0001);
    granuliserSlider.setValue(0.0);
    granuliserSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    granuliserSlider.setColour(juce::Slider::thumbColourId, juce::Colours::black);
    granuliserSlider.setTextBoxStyle(juce::Slider::NoTextBox, false, 0, 0);

    granuliserLabel.setText("AC FACTOR", juce::dontSendNotification);
    granuliserLabel.setFont(customFontKnobCompBold);
    granuliserLabel.setColour(juce::Label::textColourId, juce::Colour(0xFF7C7C7C));

    //addAndMakeVisible(granuliserLabel);
    addAndMakeVisible(&granuliserSlider);
    addAndMakeVisible(granuliserLabel);
    granuliserSlider.addListener(this);


    /*prova knob image*/
    //knob.setRange(0.0, 1.0);  // Set the knob's value range
    //addAndMakeVisible(knob);
    //knob.setBounds(300, 300, 150, 150);  // Position and size the knob

}

PolyPhaseVoc2AudioProcessorEditor::~PolyPhaseVoc2AudioProcessorEditor()
{
    bufferSizeSlider.setLookAndFeel(nullptr);
}

//==============================================================================
void PolyPhaseVoc2AudioProcessorEditor::paint(juce::Graphics& g)
{
    if (woodBackground.isValid())
    {
        // find the dimension of the image
        auto bounds = getLocalBounds(); // component dimensions
        auto scaledImage = woodBackground.rescaled(bounds.getWidth(), bounds.getHeight());

        // scaling
        g.drawImageAt(scaledImage, 0, 0);
    }
    else
    {
        g.fillAll(juce::Colours::black); // backup background colour
    }

    if (visualizerFrame.isValid())
    {
        // Coordinates
        int x_vf = 50;
        int y_vf = 40;
        int width_vf = 800;
        int height_vf = 200;

        juce::Rectangle<float> destinationRect(x_vf, y_vf, width_vf, height_vf);

        // Draw the image in the destination rectangle
        g.drawImage(visualizerFrame, destinationRect);
    }



    if (background.isValid())
    {
        // Coordinates
        int x_mb = 30;
        int y_mb = 30;
        int width_mb = 840;
        int height_mb = 540;

        juce::Rectangle<float> destinationRect(x_mb, y_mb, width_mb, height_mb);

        // Draw the image in the destination rectangle
        g.drawImage(background, destinationRect);
    }


    if (screen.isValid())
    {
        // Coordinates
        int x_sc = 69;
        int y_sc = 88;
        int width_sc = 765;
        int height_sc = 170;

        juce::Rectangle<float> destinationRect(x_sc, y_sc, screen.getWidth(), screen.getHeight());

        // Draw the image in the destination rectangle
        g.drawImage(screen, destinationRect);
    }

}

void PolyPhaseVoc2AudioProcessorEditor::resized()
{

    visualiser.setBounds(167, 97.5, 417, 94);

    // Sliders Visualiser
    bufferSizeSlider.setBounds(619, 117, 60, 60);
    samplesPerBlockSlider.setBounds(720, 117, 60, 60);

    // Knobs RATIO and THRESHOLD
    ratioSlider.setBounds(530, 408, 65, 65);
    HPFSlider.setBounds(634, 408, 65, 65);

    // Knobs ATTACK, DECAY, SUSTAIN and RELEASE
    attackSlider.setBounds(433, 303, 65, 65);
    decaySlider.setBounds(533, 303, 65, 65);
    sustainSlider.setBounds(633, 303, 65, 65);
    releaseSlider.setBounds(733, 303, 65, 65);

    // Knob GRANULIZER
    granuliserSlider.setBounds(134, 315, 150, 150);

    // Texts
    bsLabel.setBounds(614, 180, 83, 13);
    spbLabel.setBounds(734, 180, 35, 13);
    ratioLabel.setBounds(543, 481, 56, 21);
    HPFLabel.setBounds(644, 481, 115, 21);
    attackLabel.setBounds(427, 378, 72, 21);
    decayLabel.setBounds(533, 378, 62, 21);
    sustainLabel.setBounds(623, 378, 77, 21);
    releaseLabel.setBounds(726, 378, 82, 21);
    granuliserLabel.setBounds(160, 280, 100, 50);

    // LOGO
    logoComponent.setBounds(65, 95, 100, 100);
    vocoderLogo.setBounds(125, 430, 200, 100);


}

void PolyPhaseVoc2AudioProcessorEditor::pushDataToVisualiser(const juce::AudioBuffer<float>& buffer)
{
    visualiser.pushBuffer(buffer);
}

void PolyPhaseVoc2AudioProcessorEditor::sliderValueChanged(juce::Slider* slider) {

    if (slider == &ratioSlider) {
        float newRatio = ratioSlider.getValue();
        audioProcessor.setRatio(newRatio);
    }

    if (slider == &HPFSlider) {
        float newHPF = HPFSlider.getValue();
        audioProcessor.setHighPassCutoff(newHPF);
    }

    if (slider == &attackSlider) {
        float newAttack = attackSlider.getValue();
        audioProcessor.setAttack(newAttack);
    }

    if (slider == &decaySlider) {
        float newDecay = decaySlider.getValue();
        audioProcessor.setDecay(newDecay);
    }

    if (slider == &sustainSlider) {
        float newSustain = sustainSlider.getValue();
        audioProcessor.setSustain(newSustain);
    }

    if (slider == &releaseSlider) {
        float newRelease = releaseSlider.getValue();
        audioProcessor.setRelease(newRelease);
    }

    if (slider == &granuliserSlider) {
        float newGran = granuliserSlider.getValue();
        audioProcessor.setCorr(newGran);
    }

    audioProcessor.setHighPassCutoffSlider(&HPFSlider); // Pass the HPFSlider to the processor
    audioProcessor.setAttackSlider(&attackSlider); // Pass the attackSlider to the processor
    audioProcessor.setDecaySlider(&decaySlider); // Pass the decaySlider to the processor
    audioProcessor.setSustainSlider(&sustainSlider); // Pass the sustainSlider to the processor
    audioProcessor.setReleaseSlider(&releaseSlider); // Pass the releaseSlider to the processor
    audioProcessor.setRatioSlider(&ratioSlider);
    audioProcessor.setCorrSlider(&granuliserSlider);

}