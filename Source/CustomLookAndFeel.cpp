#include "CustomLookAndFeel.h"
#include "JuceHeader.h"

CustomLookAndFeel::CustomLookAndFeel()
{
    // Configura i colori di default
    //setColour(juce::Slider::backgroundColourId, juce::Colours::lightgrey);
    //setColour(juce::Slider::trackColourId, juce::Colours::blue);
    //setColour(juce::Slider::thumbColourId, juce::Colours::darkgrey);
}

CustomLookAndFeel::~CustomLookAndFeel()
{
    // Distruttore
}

void CustomLookAndFeel::drawSliderThumb(juce::Graphics& g, int x, int y, int width, int height,
    float sliderPos, const float rotaryStartAngle,
    const float rotaryEndAngle, juce::Slider& slider)
{
    // Personalizza il disegno del tuo indicatore di slider qui
    // Ad esempio, disegna l'immagine PNG come indicatore
    juce::Image myIndicatorImage = juce::ImageCache::getFromMemory(BinaryData::knob1_png, BinaryData::knob1_pngSize);
    //g.drawImage(myIndicatorImage, x, y, width, height, 1.0f);
    g.drawImageWithin(myIndicatorImage, x, y, width, height, juce::RectanglePlacement::stretchToFit);
}

