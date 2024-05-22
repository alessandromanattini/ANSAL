(
~daftPunk = (
    busOne: 0.5,
    busTwo: 0.5,
    lowPassFilterOne: 3000,
    lowPassFilterTwo: 3000,
    instOne: \violin,
    instTwo: \violin,
    monoOne: false,
    monoTwo: false,
    octaveOne: 1,
    octaveTwo: 1/2,
    bpmDrum: 120,
    vocAmpBus: 0.5,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: false,
    gloveXTwo: false,
    gloveYOne: true,
    gloveYTwo: false
);


~intro = (
    busOne: 0.5,
    busTwo: 0.5,
    lowPassFilterOne: 3000,
    lowPassFilterTwo: 3000,
    instOne: \violin,
    instTwo: \violin,
    monoOne: false,
    monoTwo: false,
    octaveOne: 1,
    octaveTwo: 1/2,
    bpmDrum: 120,
    vocAmpBus: 0.5,
    ccPedalOne: 0,
    ccPedalTwo: 1,
    gloveXOne: true,
    gloveXTwo: false,
    gloveYOne: true,
    gloveYTwo: true
);

// Funzione per impostare i valori dei parametri dal contenitore
~setModelParameters = { |preset|
	"ci sono".postln;

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