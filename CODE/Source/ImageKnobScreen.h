#pragma once
#include "JuceHeader.h"
#include "BinaryData.h"
class ImageKnobScreen : public juce::Slider
{
public:
    ImageKnobScreen()
    {
        auto imageData = BinaryData::screenKnob_png;  // Sostituisci con il nome reale del file
        auto imageSize = BinaryData::screenKnob_pngSize;  // Sostituisci con il nome reale del file

        juce::Image originalImage = juce::ImageFileFormat::loadFrom(imageData, (size_t)imageSize);

        // Ridimensiona l'immagine in base al componente
        auto maxDimension = 60;  // Usa una dimensione che si adatti bene al tuo componente
        knobImage = originalImage.rescaled(maxDimension, maxDimension, juce::Graphics::highResamplingQuality);


        setSliderStyle(RotaryVerticalDrag);  // Imposta lo stile di Slider adatto
        setTextBoxStyle(NoTextBox, false, 0, 0);       // Nasconde la textbox, se presente
    }

    void paint(juce::Graphics& g) override
    {
        auto bounds = getLocalBounds();
        auto centre = bounds.getCentre();

        // Calcola l'angolo di rotazione in radianti
        auto angle = getRadians();

        // Prepara una trasformazione che ruota l'immagine attorno al suo centro
        juce::AffineTransform transform = juce::AffineTransform::rotation(angle, knobImage.getWidth() / 2.0, knobImage.getHeight() / 2.0)
            .translated(centre.getX() - knobImage.getWidth() / 2.0, centre.getY() - knobImage.getHeight() / 2.0);

        // Disegna l'immagine trasformata
        g.drawImageTransformed(knobImage, transform);
    }

    double getRadians() const
    {
        // Definisci l'angolo di partenza e fine in radianti (ad esempio, -135 a 135 gradi)
        const double startAngle = -juce::MathConstants<double>::pi * 3.0 / 4.0;  // -135 gradi
        const double endAngle = juce::MathConstants<double>::pi * 3.0 / 4.0;  // 135 gradi

        // Mappa il valore dello slider ai radianti
        auto proportion = (getValue() - getMinimum()) / (getMaximum() - getMinimum());
        return startAngle + proportion * (endAngle - startAngle);
    }


private:
    juce::Image knobImage;
};
