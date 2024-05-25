// =======================================================================================================
// =========================================== DRUM MIDI HANDLING ========================================
// =======================================================================================================

(

MIDIdef.cc(\midiDrumOn, { |val, num, chan, src|
    if (chan == 0) {
        case
        { num == 102 && (val > 0) } { Synth(\kick); }
        { num == 103 && (val > 0) } { Synth(\snare); }
        { num == 104 && (val > 0) } { Synth(\hihat);  }
        { num == 105 && (val > 0) } { Synth(\crash);  }
        { num == 106 && (val > 0) } { Synth(\clap);  }
        { num == 110 && (val > 0) } { Synth(\crash);  }
        // Sezione sequenze
        { num == 111 } { ~toggleDrumSequence.(\daftPunk1, ~sequences[\daftPunk1]);}
        { num == 112 } { ~toggleDrumSequence.(\daftPunk2, ~sequences[\daftPunk2]);}
        { num == 113 } { ~toggleDrumSequence.(\daftPunk3, ~sequences[\daftPunk3]);}
        { num == 114 } { ~toggleDrumSequence.(\daftPunk4, ~sequences[\daftPunk4]);}
		{ num == 115 && (val > 0) } {}
        { num == 116 && (val > 0) } { ~changePreset.value("-"); }
        { num == 117 && (val > 0) } { ~changePreset.value("+"); }
    }
}, chan: 0);

)