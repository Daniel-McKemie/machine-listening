// Template
(
d={
	var in, amp, freq, hasFreq, out;
	in = SoundIn.ar(0);
	amp = Amplitude.ar(in);
	# freq, hasFreq = Pitch.kr(in, 440, 30, 4000, 1000, 3, 16, 0.01, 0.5, 1, 0);
	SinOsc.ar(freq*[1, 2]) * amp;
	out = Mix.new(SinOsc.ar(freq * [1], 0, LFNoise1.kr(0.3,0.1,0.1), amp) + (VarSaw.ar(freq * [1], 0, LFNoise1.kr(0.5,0.3,0.3), amp)));
    6.do({
		out = AllpassC.ar(out, 0.040, [0.040.rand, 0.040.rand], 2)
    });
	Out.ar(0,out)
}.play
)

d.free

// Check your devices

ServerOptions.inDevices;
ServerOptions.outDevices;


// Reboot the Server, name your device accordingly, these are defaults...
(
s.options.inDevice_("Built-in Input"); s.reboot;
s.options.outDevice_("Built-in Output"); s.reboot;
)
{SinOsc.ar([400, 600, 800, 1000])*0.3}.play //test


// Main pitch module

(
SynthDef("pitchFollow1",{
    var in, amp, freq, hasFreq, out;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05, add: 0.05);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.05, median: 7);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
    out = Mix.new(SinOsc.ar(freq * [1], 0, LFNoise1.kr(0.3, 0.1, 0.1), amp));
    6.do({
        out = AllpassN.ar(out, 0.00, [0.00.rand, 0.00.rand], 2)
    });
	Out.ar(0,out)
}).send(s);
)

//SynthDefs, activate these before triggering at bottom

// Multiple partials/sawtooth
(
SynthDef("pitchFollowSawHarmonics",{
	var in, amp,freq, hasFreq, out;
	in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 0.05, add: 0);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.1, median: 7); // lowThresh = chaos
	//freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
	out = {Mix.new([SinOsc.ar(freq * [1, 2, 4, 6, 8], 0, LFNoise1.kr(0.3, 0.1, 0.1), add:
		0.5),
		VarSaw.ar(freq * [1, 3, 5, 7, 9], 0, LFNoise1.kr(0.3, 0.1, 0.1), add:
			0.5)])};
	6.do({
		out = AllpassN.ar(out, 0.000, [0.000.rand, 0.000.rand], 2, mul: 0.7) //VOLUME HERE!
	});
	Out.ar(0,out)
}).send(s);
)
s.record

// Model 15 Routing (for the Moog Model 15 app)
(
SynthDef("Model 15",{
	var in, amp, out;
	in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 0.05, mul: 0.5);
	out = Mix.new(in, amp);
	6.do({
		out = AllpassN.ar(out, 0.000, [0.000.rand, 0.000.rand], 2)
	});
	Out.ar(0,out);
}).send(s);
)


// FM Synth

(
SynthDef("pitchFollowFMSynth",{
	arg drone = 1; //assign OSC to one number here
    var in, amp, freq, hasFreq, out;
    in = Mix.new(SoundIn.ar([0,1]));
    amp = Amplitude.kr(in, 0.05, 0.05, add: 0.05);
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.01, median: 7);
    //freq = Lag.kr(freq.cpsmidi.round(1).midicps, 0.05);
	out = Mix.new([SinOsc.ar(Rand(100.0, 100.0) + SinOsc.ar(freq * [2.5], 0, freq * [1]), 0,
		0.5)!2]);
    6.do({
        out = AllpassN.ar(out, 0.00, [0.00.rand, 0.00.rand], 2)
    });
	Out.ar(0, out)
}).send(s);
)


// Dust to fill space if you want (this was an aesthetic choice for a piece of my own)
(
SynthDef("Dust",{
	var in, amp, out;
	in = Mix.new(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, 0.05, 0.05, mul: 0.5);
	out = Dust.ar(2, 1, 0);
	6.do({
		out = AllpassN.ar(out, 0.035, [0.035.rand, 0.035.rand], 2)
	});
	Out.ar(0,out);
}).send(s);
)
)
})
)

// Touch OSC assignments
(
OSCdef.new(
		\slider,  //this is the name of def
		{
			arg msg, time, addr, port;
		a.set(\drone, msg[1].linlin(0, 1, 20, 22000)); // this assigns the msg, in this case, the 'drone arg in the FM Synthdef, x.set allows change in synth without ADDING layer
		msg.postln;
		},
		'/main/fader1' // osc objects here, port is always 57120 from phone/pad
);
)

// Turn on the synths

x = Synth("pitchFollow1", out: [0,1]);
y = Synth("pitchFollowSawHarmonics", out: [0,1]);
z = Synth("Model 15", out: [0,1]);
a = Synth("pitchFollowFMSynth", out: [0,1]);
b = Synth("Dust", out: [0,1]);

// Turn off the synths

x.free;
y.free;
z.free;
a.free;
b.free;