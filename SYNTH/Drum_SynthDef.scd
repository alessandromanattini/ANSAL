// ============================================================================================================================
// ======================================================= DRUM SYNTHDEF ======================================================
/* --------------------------------------------- List of available instruments ----------------------------------------------*/
/*                                        \kick    \snare    \hihat    \clap    \crash                                       */
/* --------------------------------------------------------------------------------------------------------------------------*/
// ============================================================================================================================


// ---------------------------------------------------------- \kick ----------------------------------------------------------

SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // Body starts midrange, quickly drops down to low frequencies, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;

    // Pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;

    // Click is spectrally rich, covering the high-frequency range
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// ---------------------------------------------------------- \snare ---------------------------------------------------------

SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var transient, transientAmp;
    var snare;

    // Pop makes a click coming from very high frequencies, slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;

    // Bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    // Adding a transient for impact
    transientAmp = EnvGen.ar(Env.perc(0.001, 0.02)) * 0.8;
    transient = WhiteNoise.ar * transientAmp;

    // Combine pop, noise, and transient
    snare = (pop + noise + transient) * 1.5;

    // Distortion for more impact
    snare = snare.tanh;

    // Output the sound with panning
    Out.ar(out, Pan2.ar(snare, pan, amp));
}).add;

// ---------------------------------------------------------- \hihat ---------------------------------------------------------

SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // Noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// ---------------------------------------------------------- \clap ----------------------------------------------------------

// Adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
    |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // Noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // Noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction: 2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// ---------------------------------------------------------- \crash ----------------------------------------------------------

SynthDef(\crash, {
    |out = 0, pan = 0, amp = 0.5|
    var noise, noiseEnv, noiseFiltered;
    var metallic, metallicEnv;
    var crash, reverb;

    // Noise component for the body of the crash
    noiseEnv = EnvGen.ar(Env.perc(0.01, 2), doneAction: 2); // Slightly longer decay for a fuller sound
    noise = WhiteNoise.ar * noiseEnv;
    noiseFiltered = BPF.ar(noise, 9000, 0.6); // Band-pass filter for high frequencies

    // Reduced metallic component to avoid initial "ding"
    metallicEnv = EnvGen.ar(Env.perc(0.01, 1)); // Shorter envelope for metallic component
    metallic = SinOsc.ar([7000, 9000, 11000], 0, 0.1) * metallicEnv;

    // Combine noise and metallic components
    crash = (noiseFiltered + metallic) * amp;

    // Add reverb for a fuller sound
    reverb = FreeVerb.ar(crash, mix: 0.3, room: 0.5, damp: 0.2);

    // Output the sound with panning
    Out.ar(out, Pan2.ar(reverb, pan, amp));
}).add;

// -----------------------------------------------------------------------------------------------------------------------------