//=======================================================================================================
//============================================DRUM=MIDI=HANDLING=========================================
//=======================================================================================================

MIDIdef.cc(\midiDrumOn, { |val, num, chan, src|
    if (chan == 0) {
        case
        { num == 102 } { Synth(\kick); }
        { num == 103 } { Synth(\snare); }
        { num == 104 } { Synth(\hihat);  }
		{ num == 105 } { Synth(\crash);  }
        { num == 106 } { Synth(\clap);  }
		{ num == 110 } { Synth(\crash);  }
		// Sezione sequenze
		{ num == 111 } { ~toggleDrumSequence.(\daftPunk1, ~sequences[\daftPunk1]);}
		{ num == 112 } { ~toggleDrumSequence.(\daftPunk2, ~sequences[\daftPunk2]);}
		{ num == 113 } { ~toggleDrumSequence.(\daftPunk3, ~sequences[\daftPunk3]);}
		{ num == 114 } { ~toggleDrumSequence.(\daftPunk4, ~sequences[\daftPunk4]);}
		{ num == 115 } { ~toggleDrumSequence.(\daftPunk1, ~sequences[\daftPunk1]);}
		{ num == 116 } { ~toggleDrumSequence.(\daftPunk1, ~sequences[\daftPunk1]);}
    }
}, chan: 0);
