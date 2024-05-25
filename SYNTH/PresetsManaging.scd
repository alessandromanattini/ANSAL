// ==========================================================================================================================
// ========================================================= PRESETS ========================================================
/* ------------------------------------------------ List of available presets ---------------------------------------------*/

/*                                             INTR      DAFT     MONO    THER                                             */

/* ------------------------------------------------------------------------------------------------------------------------*/
// ==========================================================================================================================

(
// --------------------------------------------------- Presets Parameters ---------------------------------------------------

~daftPunk = (
	currentPreset: "DAFT",
    busOne: 0.45,
    busTwo: 0.30,
    lowPassFilterOne: 100,
    lowPassFilterTwo: 100,
    instOne: \VIOLSYN,
    instTwo: \VIOLSYN,
    monoOne: false,
    monoTwo: false,
    octaveOne: 1,
    octaveTwo: 1/2,
    bpmDrum: 100,
    vocAmpBus: 0.8,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: false,
    gloveXTwo: false,
    gloveYOne: true,
    gloveYTwo: false,
	keySplit: -1,

	ratio: 127/3,
	corr_k: 50,
	highPassCutoff: 70,
	attack: 20,
	decay: 20,
	sustain: 100,
	release: 100
);

~intro = (
	currentPreset: "INTR",
    busOne: 0.45,
    busTwo: 0.5,
    lowPassFilterOne: 100,
    lowPassFilterTwo: 100,
    instOne: \VIOLSYN,
    instTwo: \VIOLSYN,
    monoOne: false,
    monoTwo: false,
    octaveOne: 1,
    octaveTwo: 1/2,
    bpmDrum: 100,
    vocAmpBus: 0.0,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: true,
    gloveXTwo: true,
    gloveYOne: true,
    gloveYTwo: false,
	keySplit: -1,

	ratio: 0,
	corr_k: 0,
	highPassCutoff: 0,
	attack: 0,
	decay: 0,
	sustain: 0,
	release: 0
);

~mono = (
	currentPreset: "MONO",
    busOne: 0.26,
    busTwo: 0.7,
    lowPassFilterOne: 100,
    lowPassFilterTwo: 100,
    instOne: \VIOLSYN,
    instTwo: \BASSIMP,
    monoOne: false,
    monoTwo: true,
    octaveOne: 1,
    octaveTwo: 1/4,
    bpmDrum: 120,
    vocAmpBus: 0.0,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: false,
    gloveXTwo: false,
    gloveYOne: true,
    gloveYTwo: false,
	keySplit: 58,

	ratio: 0,
	corr_k: 0,
	highPassCutoff: 0,
	attack: 0,
	decay: 0,
	sustain: 0,
	release: 0
);


~ther = (
	currentPreset: "THER",
    busOne: 0.5,
    busTwo: 0.35,
    lowPassFilterOne: 100,
    lowPassFilterTwo: 100,
    instOne: \RHODES2,
    instTwo: \RHODES1,
    monoOne: false,
    monoTwo: false,
    octaveOne: 1,
    octaveTwo: 1/2,
    bpmDrum: 100,
    vocAmpBus: 0.0,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: true,
    gloveXTwo: true,
    gloveYOne: true,
    gloveYTwo: false,
	keySplit: -1,

	ratio: 0,
	corr_k: 0,
	highPassCutoff: 0,
	attack: 0,
	decay: 0,
	sustain: 0,
	release: 0
);


// ------------------------------------------------------- Apply Presets ----------------------------------------------------

~setModelParameters = { |preset|
	~currentPreset = preset[\currentPreset];
	~busOne.set(preset[\busOne]);
	~busTwo.set(preset[\busTwo]);
	~lowPassFilterOne.set(preset[\lowPassFilterOne]);
	~lowPassFilterTwo.set(preset[\lowPassFilterTwo]);
	~instOne = preset[\instOne];
	~instTwo = preset[\instTwo];
	~monoOne = preset[\monoOne];
	~monoTwo = preset[\monoTwo];
	~octaveOne = preset[\octaveOne];
	~octaveTwo = preset[\octaveTwo];
	~bpmDrum = preset[\bpmDrum];
	~vocAmpBus.set(preset[\vocAmpBus]);
	~vocoderVolume=preset[\vocAmpBus];
	~ccPedalOne = preset[\ccPedalOne];
	~ccPedalTwo = preset[\ccPedalTwo];
	~gloveXOne = preset[\gloveXOne];
	~gloveXTwo = preset[\gloveXTwo];
	~gloveYOne = preset[\gloveYOne];
	~gloveYTwo = preset[\gloveYTwo];
	~keySplit = preset[\keySplit];

	~setKnobValue.value(preset[\ratio], 22);
	~setKnobValue.value(preset[\corr_k], 23);
	~setKnobValue.value(preset[\highPassCutoff], 24);
	~setKnobValue.value(preset[\attack], 26);
	~setKnobValue.value(preset[\decay], 27);
	~setKnobValue.value(preset[\sustain], 28);
	~setKnobValue.value(preset[\release], 29);
};


// ------------------------------------------------------- Preset Navigation ------------------------------------------------

// Circular container for the preset names
~presetNames = [~intro, ~daftPunk, ~mono, ~ther];
~currentPresetIndex = 0;  // Index of the current preset

~changePreset = { |direction|
	var preset;
	if (direction == "+") {
		~currentPresetIndex = (~currentPresetIndex + 1) % ~presetNames.size;
	} {
		~currentPresetIndex = (~currentPresetIndex - 1) % ~presetNames.size;
		if (~currentPresetIndex < 0) { ~currentPresetIndex = ~presetNames.size - 1; }
	};

	// Set the current preset using the index
	preset = ~presetNames[~currentPresetIndex];
	~setModelParameters.value(preset);
};

)
