(
~daftPunk = (
	currentPreset: "DAFT",
    busOne: 0.3,
    busTwo: 0.3,
    lowPassFilterOne: 3000,
    lowPassFilterTwo: 3000,
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
    gloveYTwo: false
);


~intro = (
	currentPreset: "INTR",
    busOne: 0.3,
    busTwo: 0.3,
    lowPassFilterOne: 3000,
    lowPassFilterTwo: 3000,
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
    gloveYTwo: false
);

// Funzione per impostare i valori dei parametri dal contenitore
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
};

// Ripristina i parametri al primo preset salvato
~setModelParameters.value(~daftPunk);
)