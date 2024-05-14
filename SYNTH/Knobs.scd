//=======================================================================================================
//==============================================SEZIONE=KNOBS============================================
//=======================================================================================================

~setLowPassFilter = { |val, num|
    var value;
    case
	{ num == 16 } {
		value = val.linlin(0, 127, 0, 1);
        ~busOne.set(value);
        ("AmpOne: " ++ value).postln;
    }
	{ num == 17 } {
		value = val.linlin(0, 127, 0, 1);
        ~busTwo.set(value);
        ("AmpTwo: " ++ value).postln;
    }
    { num == 20 } {
		value = val.linlin(0, 127, 200, 6000);
        ~lowPassFilterOne.set(value);
        ("LPF One Cutoff: " ++ value).postln;
    }
    { num == 21 } {
		value = val.linlin(0, 127, 200, 6000);
        ~lowPassFilterTwo.set(value);
        ("LPF Two Cutoff: " ++ value).postln;
    }
    {
        "Unknown control number".postln;
    };
};

MIDIdef.cc(\lpfHandler, { |val, num, chan, src|
    ~setLowPassFilter.value(val, num);
}, chan: 0);
