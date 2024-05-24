// ==========================================================================================================================
// ====================================================== INST SYNTHDEF =====================================================
/* --------------------------------------------- List of available instruments --------------------------------------------*/

/* \RHODES1   \RHODES2   \BASSYN1   \BASSYN2   \BASSYN3   \LEADSCR   \TRIWAVE   \SAWWAVE   \HAMMOND   \VIOLSYN   \BASSIMP  */

/* ------------------------------------------------------------------------------------------------------------------------*/
// ==========================================================================================================================



// --------------------------------------------------------- RHODES ---------------------------------------------------------
(
SynthDef(\RHODES1, { |out = 0, freq = 440, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var pulse, filter, env, source, chorus, numVoices, dynamicCutoff, noteDur, globalAmp, lpFreq;

    numVoices = ~activeNotesOne.size;
    noteDur = 0.5;

    pulse = Pulse.ar(freq * [1, 33.5.midiratio], [0.2, 0.1], [0.7, 0.3]);
    env = EnvGen.ar(Env.adsr(0.0, 1.0, 0.8, 3.0 * noteDur), gate, doneAction: 2);
    dynamicCutoff = Pseries(700, 500, inf).stutter(11).asStream;

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = BLowPass4.ar(pulse, (dynamicCutoff.next * (env.squared)) + 200 + freq, 0.5) * lpFreq;

    // Reads the control bus value for amplitude
	globalAmp = In.kr(ampBus) / (50000*numVoices.max(1));
    source = Mix(filter) * env * globalAmp;
    chorus = Splay.ar(Array.fill(4, {
        var maxdelaytime = 0.015;
        DelayC.ar(source, maxdelaytime, LFNoise1.kr(0.35, 0.1875 * maxdelaytime, 0.5625 * maxdelaytime))
    }));
    chorus = Compander.ar(chorus, chorus, 0.4, 1, 4);
    Out.ar(out, Pan2.ar(chorus, pan));
}).add;

SynthDef(\RHODES2, { |out = 0, freq = 440, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var pulse, filter, env, source, chorus, numVoices, dynamicCutoff, noteDur, globalAmp, lpFreq, reverb;

    numVoices = ~activeNotesOne.size;
    noteDur = 0.5;

    // Modified pulse waves for a more Rhodes-like sound
    pulse = Pulse.ar(freq * [1, 2], [0.2, 0.15], [0.6, 0.4]);
    env = EnvGen.ar(Env.adsr(0.01, 1.0, 0.8, 3.0 * noteDur), gate, doneAction: 2); // Faster attack

    dynamicCutoff = Pseries(700, 500, inf).stutter(11).asStream;
    lpFreq = In.kr(lpFreqBus);
    filter = BLowPass4.ar(pulse, (dynamicCutoff.next * (env.squared)) + 200 + freq, 0.5) * lpFreq;

    globalAmp = In.kr(ampBus) / (50000*numVoices.max(1));
    source = Mix(filter) * env * globalAmp;

    // Modified chorus for more presence
    chorus = Splay.ar(Array.fill(4, {
        var maxdelaytime = 0.02; // Increased maximum delay time
        DelayC.ar(source, maxdelaytime, LFNoise1.kr(0.25, 0.2 * maxdelaytime, 0.6 * maxdelaytime))
    }));
    chorus = Compander.ar(chorus, chorus, 0.4, 1, 4);

    // Added reverb for greater impact and spatiality
    reverb = FreeVerb.ar(chorus, mix: 0.2, room: 0.6, damp: 0.3);

    Out.ar(out, Pan2.ar(reverb, pan));
}).add;

// ---------------------------------------------------------- BASSYN ----------------------------------------------------------

SynthDef(\BASSYN1, { |out = 0, freq = 440, amp = 1, gate = 1, ampBus = 0, lpFreqBus = 0|
    var lforate, lfowidth, pan;
    var lfo, pulse, env, lpFreq;

    // Definition of automations
	lfowidth = LFTri.kr(1/2, 0.5) * 0.5 + 0.5;     // Automation for lfowidth
    lforate = LFTri.kr(1/5, 0.2) * 0.2 + 0.5;      // Automation for lforate
    pan = LFTri.kr(1/2, 0.5).range(-0.5, 0.5);     // Automation for pan

    lfo = LFTri.kr(lforate, Rand(0, 2.0) ! 3);
    pulse = Pulse.ar(freq * [1, 1.01, 0.5], lfo * lfowidth + 0.5);

    env = EnvGen.ar(Env.adsr(0.01, 0.05, 0.5, 0.1), gate, doneAction: 2);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    pulse = BLowPass4.ar(pulse, lpFreq, 0.5);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    Out.ar(out, Pan2.ar(Mix(pulse) * env * amp, pan));
}).add;

SynthDef(\BASSYN2, { |out = 0, freq = 55, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0, detune = 0.005|
    var sig, env, osc1, osc2, filter, vibrato, lpFreq, subOsc;

    // Vibrato to add realism
    vibrato = SinOsc.kr(4, 0, 0.01, 1);

    // Slightly detuned sawtooth oscillators with vibrato
    osc1 = Saw.ar((freq + (freq * detune)) * vibrato, 0.5);
    osc2 = Saw.ar((freq - (freq * detune)) * vibrato, 0.5);

    // Sub oscillator to add depth
    subOsc = Pulse.ar(freq / 2, 0.5, 0.3);

    // Combines the oscillators
    sig = Mix([osc1, osc2, subOsc]);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(sig, lpFreq);

    // ADSR envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.7, 0.3), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output with panning
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

SynthDef(\BASSYN3, { |out = 0, freq = 110, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc, filter, vibrato, subOsc, lpFreq, distortion, chorus;

    // Vibrato to add realism
    vibrato = SinOsc.kr(4, 0, 0.005, 1);

    // Sawtooth oscillator with vibrato
    osc = Saw.ar(freq * vibrato, 0.7);

    // Sub oscillator to reinforce low frequencies
    subOsc = Pulse.ar(freq / 2, 0.5, 0.3);

    // Sum of the oscillators
    sig = osc + subOsc;

    // Chorus effect to give depth
    chorus = CombN.ar(sig, 0.03, [0.02, 0.025], 2);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(chorus, lpFreq);

    // Light distortion to add character
    distortion = tanh(filter * 2);

    // ADSR envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.2, 0.6, 0.4), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);

    // Output with panning
    Out.ar(out, Pan2.ar(distortion * env * amp, pan));
}).add;

// --------------------------------------------------------- BASSIMP ---------------------------------------------------------
SynthDef(\BASSIMP, { |out = 0, freq = 55, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc, filter, vibrato, lpFreq;

    // Vibrato to add realism
    vibrato = SinOsc.kr(6, 0, 0.005, 1);

    // Sawtooth oscillator with vibrato
    osc = Saw.ar(freq * vibrato, 0.5);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(osc, lpFreq);      // Lower cutoff frequency for the bass

    // ADSR envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.7, 0.2), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output with panning
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

// --------------------------------------------------------- LEADSCR ---------------------------------------------------------

SynthDef(\LEADSCR, { |out = 0, freq = 440, amp = 0.1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var pulse, filter, env, syncfreq, cutoff, rq, lpFreq;

    // Automations for cutoff and rq
    cutoff = EnvGen.kr(Env([7000, 7000, 7000, 7000, 7000, 7000, 7000], [1.0, 1.0, 2.0, 1.0, 0.5, 1.0, 1.5]), gate, doneAction: 2);
    rq = EnvGen.kr(Env([1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 2.0, 1.0, 0.5, 1.0, 1.5]), gate, doneAction: 2);
    syncfreq = EnvGen.ar(Env([1, 5, 1], [0.04, 0.9])) * freq;
    pulse = SyncSaw.ar(freq, syncfreq);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = BLowPass.ar(pulse, lpFreq, rq);

    env = EnvGen.ar(Env.adsr(0.01, 0.0, 1.0, 0.1), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

// --------------------------------------------------------- TRIWAVE ---------------------------------------------------------

SynthDef(\TRIWAVE, { |out = 0, freq = 440, amp = 1.0, gate = 1, pan = 0.0, drive = 1.0, ampBus = 0, lpFreqBus = 0|
    var tri, dist, env, lpFreq;

    // Generates a triangle wave
    tri = LFTri.ar(freq);

    // Applies light distortion
    dist = tanh(tri * drive);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    dist = BLowPass4.ar(dist, lpFreq, 0.5);

    // Generates the envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output
    Out.ar(out, Pan2.ar(dist * env * amp, pan));
}).add;

// --------------------------------------------------------- SAWWAVE ---------------------------------------------------------

SynthDef(\SAWWAVE, { |out = 0, freq = 440, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var saw, env, lpFreq;

    // Generates a sawtooth wave
    saw = Saw.ar(freq);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    saw = BLowPass4.ar(saw, lpFreq, 0.5);

    // Generates the envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output
    Out.ar(out, Pan2.ar(saw * env * amp, pan));
}).add;

// --------------------------------------------------------- HAMMOND ---------------------------------------------------------

SynthDef(\HAMMOND, { |out = 0, freq = 440, amp = 1.0, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc1, osc2, osc3, osc4, osc5, osc6, osc7, osc8, osc9, lpFreq;

    // Oscillators for the nine drawbars of the Hammond organ
    osc1 = Saw.ar(freq * 1) * 0.2;    // Fundamental
    osc2 = Saw.ar(freq * 2) * 0.15;   // Octave
    osc3 = Saw.ar(freq * 3) * 0.12;   // Fifth
    osc4 = Saw.ar(freq * 4) * 0.1;    // Tenth
    osc5 = Saw.ar(freq * 5) * 0.08;   // Major third
    osc6 = Saw.ar(freq * 6) * 0.07;   // Twelfth
    osc7 = Saw.ar(freq * 8) * 0.05;   // Fifteenth
    osc8 = Saw.ar(freq * 10) * 0.03;  // Seventeenth
    osc9 = Saw.ar(freq * 12) * 0.02;  // Octave and fifth

    // Sum of the oscillators
    sig = osc1 + osc2 + osc3 + osc4 + osc5 + osc6 + osc7 + osc8 + osc9;

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    sig = BLowPass4.ar(sig, lpFreq, 0.5);

    // ADSR envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output with panning
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// --------------------------------------------------------- VIOLSYN ---------------------------------------------------------

SynthDef(\VIOLSYN, { |out = 0, freq = 440, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc, filter, vibrato, lpFreq;

    // Vibrato to add realism
    vibrato = SinOsc.kr(5, 0, 0.005, 1);

    // Sawtooth oscillator with vibrato
    osc = Saw.ar(freq * vibrato, 0.5);

    // Reads the control bus value for the cutoff frequency
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(osc, lpFreq);

    // ADSR envelope
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.7, 0.3), gate, doneAction: 2);

    // Reads the control bus value for amplitude
    amp = In.kr(ampBus);
    // Output with panning
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

// ----------------------------------------------------------------------------------------------------------------------------

SynthDef(\NONE, {
}).add;

)

