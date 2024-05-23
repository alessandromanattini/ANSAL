/* This file records Synths for a clean classic guitar tracking.  */
s.boot;
s.options.memSize = 2.pow(20);
s.latency=0;

s.options.memSize.post; //= 2.pow(20);

//////////////////////

// ****************************************************************************************************************
(
// DRY GUITAR
SynthDef(\micGuit, {
	var micIn, volLin, volRin;
	volLin = 0.5; volRin = 0.5;  // to control output volumes L-R separately
	micIn = SoundIn.ar(0); // get first channel of sound input
	Out.ar([0, 1], ((micIn * volLin) + (micIn * volRin)));  // output to L-R
}).add;

// ****************************************************************************************************************

// Flanger(ish) No. 2 - MID and Hi range to flange, LOW range filtered and sent to both channels

// CHORUS
SynthDef.new(\flangish2, {
	arg in = 0, rate = 0.1, depth = 6, amp = 1.2, cfreq = 440;
	//  it appears to work fine with rates around 0.1, depths around 4-6 - changes should be subtle
	var sig, highSig, delayL, delayR;
	sig = SoundIn.ar(0) * amp;
	highSig = HPF.ar(sig, cfreq * 1.20);
	sig = LPF.ar(sig, cfreq * 0.80);
	delayL = DelayN.ar(highSig, 0.5, SinOsc.kr(rate + 0.3).exprange(depth * 0.012, rate * 0.030) * 0.1);
	delayR = DelayN.ar(highSig, 0.5, SinOsc.kr(rate + 0.8).exprange(depth * 0.008, rate * 0.028) * 0.1);
	Out.ar(0, sig * 0.6 + delayL * 1.2);
	Out.ar(1, sig * 0.6 + delayR * 1.2);
}).add;

// ****************************************************************************************************************

// GUITAR & BASS
SynthDef(\bassGuit5th, {
	var mic, lowsnd, freq, hasFreq, amp, harm, k;
	mic = SoundIn.ar(0); // get first channel of sound input
	lowsnd = BLowPass4.ar(mic, 800, 0.5);
	# freq, hasFreq = Pitch.kr(lowsnd); // Pitch of input signal
	amp = Amplitude.ar(mic, releaseTime: 0.1);  // in the original NO releaseTime
	k = 0.497;  // tuning of the harmonic
	harm = SinOsc.ar(freq * k, 0, amp * hasFreq);
	Out.ar([0, 1], ((harm) * 0.6 + (mic) * 1));  // to play found. + 5th and hear synth bass and natural 5th
}).add;
)
// ****************************************************************************************************************

~mode = \micGuit;
~synth = Synth(\micGuit);

// ---------------------------------- OSC -------------------------------------------------------------------------------

(
~processingAddr = NetAddr("127.0.0.1", 12000);

OSCdef(\selectMode, { |msg, time, addr, recvPort|
    var mode;
    mode = msg[1].asString;

    "Modalità selezionata : ".post; mode.postln;

    // Seleziona e avvia il synth in base allo strumento selezionato
    if (mode == "Mode1") {
        ~mode = \flangish2;
    };
	if(mode == "Mode2") {
		~mode = \bassGuit5th;
    };
	if(mode == "Mode3") {
		~mode = \micGuit;
    };

    // Libera il synth precedente e avvia il nuovo synth
    ~synth.free;
    ~synth = Synth(~mode);
}, '/selectMode');
)

