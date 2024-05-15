//==========================================================================================================================
//=======================================================INST=SYNTHDEF======================================================
//==========================================================================================================================

/*----------------------------------------------List-of-available-instruments----------------------------------------------*/
/*  \everythingrhodes    \mrostinato    \synchronicity    \distortedTri    \sawtooth    \hammondOrgan    \violin    \bass  */
/*-------------------------------------------------------------------------------------------------------------------------*/


//------------------------------------\everythingrhodes----------------------------------------------

SynthDef(\everythingrhodes, { |out = 0, freq = 440, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var pulse, filter, env, source, chorus, numVoices, dynamicCutoff, noteDur, globalAmp, lpFreq;

    numVoices = ~activeNotesOne.size;
    noteDur = 0.5;

    pulse = Pulse.ar(freq * [1, 33.5.midiratio], [0.2, 0.1], [0.7, 0.3]);
    env = EnvGen.ar(Env.adsr(0.0, 1.0, 0.8, 3.0 * noteDur), gate, doneAction: 2);
    dynamicCutoff = Pseries(700, 500, inf).stutter(11).asStream;

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    filter = BLowPass4.ar(pulse, (dynamicCutoff.next * (env.squared)) + 200 + freq, 0.5) * lpFreq;

    // Legge il valore del bus di controllo per l'ampiezza
	globalAmp = In.kr(ampBus) / (50000*numVoices.max(1));
    source = Mix(filter) * env * globalAmp;
    chorus = Splay.ar(Array.fill(4, {
        var maxdelaytime = 0.015;
        DelayC.ar(source, maxdelaytime, LFNoise1.kr(0.35, 0.1875 * maxdelaytime, 0.5625 * maxdelaytime))
    }));
    chorus = Compander.ar(chorus, chorus, 0.4, 1, 4);
    Out.ar(out, Pan2.ar(chorus, pan));
}).add;

//-----------------------------------------\mrostinato---------------------------------------------

SynthDef(\mrostinato, { |out = 0, freq = 440, amp = 1, gate = 1, ampBus = 0, lpFreqBus = 0|
    var lforate, lfowidth, pan;
    var lfo, pulse, env, lpFreq;

    // Definizione delle automazioni
    lfowidth = LFTri.kr(1/2, 0.5) * 0.5 + 0.5; // Automazione per lfowidth
    lforate = LFTri.kr(1/5, 0.2) * 0.2 + 0.5; // Automazione per lforate
    pan = LFTri.kr(1/2, 0.5).range(-0.5, 0.5); // Automazione per pan

    lfo = LFTri.kr(lforate, Rand(0, 2.0) ! 3);
    pulse = Pulse.ar(freq * [1, 1.01, 0.5], lfo * lfowidth + 0.5);

    env = EnvGen.ar(Env.adsr(0.01, 0.05, 0.5, 0.1), gate, doneAction: 2);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    pulse = BLowPass4.ar(pulse, lpFreq, 0.5);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    Out.ar(out, Pan2.ar(Mix(pulse) * env * amp, pan));
}).add;

//--------------------------------------\synchronicity-----------------------------------------------

SynthDef(\synchronicity, { |out = 0, freq = 440, amp = 0.1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var pulse, filter, env, syncfreq, cutoff, rq, lpFreq;

    // Automazioni per cutoff e rq
    cutoff = EnvGen.kr(Env([7000, 7000, 7000, 7000, 7000, 7000, 7000], [1.0, 1.0, 2.0, 1.0, 0.5, 1.0, 1.5]), gate, doneAction: 2);
    rq = EnvGen.kr(Env([1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 2.0, 1.0, 0.5, 1.0, 1.5]), gate, doneAction: 2);
    syncfreq = EnvGen.ar(Env([1, 5, 1], [0.04, 0.9])) * freq;
    pulse = SyncSaw.ar(freq, syncfreq);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    filter = BLowPass.ar(pulse, lpFreq, rq);

    env = EnvGen.ar(Env.adsr(0.01, 0.0, 1.0, 0.1), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

//------------------------------------------\distortedTri----------------------------------------------

SynthDef(\distortedTri, { |out = 0, freq = 440, amp = 1.0, gate = 1, pan = 0.0, drive = 1.0, ampBus = 0, lpFreqBus = 0|
    var tri, dist, env, lpFreq;

    // Genera un'onda triangolare
    tri = LFTri.ar(freq);

    // Applica una leggera distorsione
    dist = tanh(tri * drive);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    dist = BLowPass4.ar(dist, lpFreq, 0.5);

    // Genera l'inviluppo
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    // Uscita
    Out.ar(out, Pan2.ar(dist * env * amp, pan));
}).add;

//----------------------------------------------\sawtooth-----------------------------------------

SynthDef(\sawtooth, { |out = 0, freq = 440, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var saw, env, lpFreq;

    // Genera un'onda a dente di sega
    saw = Saw.ar(freq);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    saw = BLowPass4.ar(saw, lpFreq, 0.5);

    // Genera l'inviluppo
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    // Uscita
    Out.ar(out, Pan2.ar(saw * env * amp, pan));
}).add;

//----------------------------------------------\hammondOrgan-------------------------------------------

SynthDef(\hammondOrgan, { |out = 0, freq = 440, amp = 1.0, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc1, osc2, osc3, osc4, osc5, osc6, osc7, osc8, osc9, lpFreq;

    // Oscillatori per i nove tiranti dell'organo Hammond
    osc1 = Saw.ar(freq * 1) * 0.2;    // Fondamentale
    osc2 = Saw.ar(freq * 2) * 0.15;   // Ottava
    osc3 = Saw.ar(freq * 3) * 0.12;   // Quinto
    osc4 = Saw.ar(freq * 4) * 0.1;    // Decimo
    osc5 = Saw.ar(freq * 5) * 0.08;   // Terza maggiore
    osc6 = Saw.ar(freq * 6) * 0.07;   // Dodicesima
    osc7 = Saw.ar(freq * 8) * 0.05;   // Quindicesima
    osc8 = Saw.ar(freq * 10) * 0.03;  // Diciassettesima
    osc9 = Saw.ar(freq * 12) * 0.02;  // Ottava e quinta

    // Somma degli oscillatori
    sig = osc1 + osc2 + osc3 + osc4 + osc5 + osc6 + osc7 + osc8 + osc9;

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    sig = BLowPass4.ar(sig, lpFreq, 0.5);

    // Inviluppo ADSR
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    // Uscita con panning
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

//--------------------------------------------\violin--------------------------------------------

SynthDef(\violin, { |out = 0, freq = 440, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc, filter, vibrato, lpFreq;

    // Vibrato per aggiungere realismo
    vibrato = SinOsc.kr(5, 0, 0.005, 1);

    // Oscillatore a dente di sega con vibrato
    osc = Saw.ar(freq * vibrato, 0.5);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(osc, lpFreq);

    // Inviluppo ADSR
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.7, 0.3), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    // Uscita con panning
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

//----------------------------------------------\bass----------------------------------------------

SynthDef(\bass, { |out = 0, freq = 55, amp = 1, gate = 1, pan = 0.0, ampBus = 0, lpFreqBus = 0|
    var sig, env, osc, filter, vibrato, lpFreq;

    // Vibrato per aggiungere realismo
    vibrato = SinOsc.kr(6, 0, 0.005, 1);

    // Oscillatore a dente di sega con vibrato
    osc = Saw.ar(freq * vibrato, 0.5);

    // Legge il valore del bus di controllo per la frequenza di taglio
    lpFreq = In.kr(lpFreqBus);
    filter = LPF.ar(osc, lpFreq); // Frequenza di taglio più bassa per il basso

    // Inviluppo ADSR
    env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.7, 0.2), gate, doneAction: 2);

    // Legge il valore del bus di controllo per l'ampiezza
    amp = In.kr(ampBus);
    // Uscita con panning
    Out.ar(out, Pan2.ar(filter * env * amp, pan));
}).add;

//-------------------------------------------------------------------------------------------------
