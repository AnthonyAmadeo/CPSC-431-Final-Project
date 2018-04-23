// Anthony Amadeo
// Final Project: Musical Turing Machines
// CPSC 431
// December 4, 2017


///////////////////////////////////////////////////////////////////////////////
// TURING MACHINE: A device proposed by Alan Turing capable of computing all
//                 computable functions. Turing proposed a theoretical device
//                 that could traverse an infinitely long tape, read and write
//                 over its cells, and keep track of internal states. Such a
//                 simple and deterministic device, he proved, was able to
//                 solve the entire set of problems that can be solved by any
//                 type of device. Alan Turing further demonstrated that there
//                 existed a Universal Turing Machine, which could be
//                 initialized to perform any job that a dedicated Turing
//                 machine could perform.
//                   In this project, I construct a digital Turing machine to
//                 solve a selection of computational problems. Here Turing
//                 machines are represented digitally. The tape is  a
//                 1-dimensional Array of Characters, with the blank symbol
//                 represented by "_". States are parameters of the machine
//                 configuration. Instructions are stored in computer memory
//                 and fed to the Machine.
//                   I then use the machines to generate output strings, and
//                 define procedures to transform the outputted data into
//                 meaningful and potentially interesting musical information.
///////////////////////////////////////////////////////////////////////////////

(
// Initialization: a Turing Machine is an Array consisting of an initial state,
//                 a set of accepting states, and a set of instructions
~initTuringMach = { |initialState, acceptStates, instructs|
	var machine = [];

	machine = machine.add(initialState);
	machine = machine.add(acceptStates);
	machine = machine.add(instructs);
};


// Step: given current state, tape string, tape head index, and instruction
//       Dictionary, output the next state, new tape string, and new tape head
//       index.
// In the future, may want to add a decrementing counter to check if program
// does not halt.
~step = {|currState, tape, tapeHead, instruct|
	var nextState, newChar, dir;

	nextState = instruct.at(0);
	newChar = instruct.at(1);
	dir = instruct.at(2);

	// Generates blank symbol if you're moving off the edge of the string
	case
	{tapeHead == (tape.size-1) and: (dir == \r)} {tape = tape ++ "_"}
	{tapeHead == 0 and: dir == \l} {tape = "_" ++ tape; tapeHead = tapeHead + 1};

	tape = tape.separate.put(tapeHead, newChar).join;

	// Removes unnecessary blank symbols
	case
	{(tape.at(tapeHead) == "_".at(0)) and: (newChar == "_") and: (tapeHead == 0) and: (dir == \r)}
	{tape = tape[1..(tape.size-1)]; tapeHead = tapeHead - 1}
	{(tape.at(tapeHead) == "_".at(0)) and: (newChar == "_") and: (tapeHead == (tape.size-1)) and: (dir==\l)}
	{tape = tape[0..(tape.size-2)]};

	if (dir == \l, {tapeHead = tapeHead - 1}, {tapeHead = tapeHead + 1});
	[nextState, tape, tapeHead];
};


// Simulator: Given an initialized Turing machine, and an initial tape
//            (where by default we start at the leftmost character), walk
//            through all the configurations the Turing machine would go through.
// Optional Parameters:
//            print will print the tape string at the end of every step - true by default.
//            stored will return a list of the collection of tape strings generated when
//            ~simulate is called.
~simulate = {|machine, initTape, print=true, store=true|
	var output, instruct, newState, newTape, newTapeHead;
	var acceptStates = machine.at(1);
	var instructDict = machine.at(2);
	var stored = List[];

	// Look up first instruction and generate first output
	instruct = instructDict.at([machine.at(0), initTape.at(0).asString]);
	output = ~step.value(machine.at(0), initTape, 0, instruct);
	if (print, {output.at(1).postln});
	if (store, {stored.add(initTape); stored.add(output.at(1))});

	// As long as we aren't in an accepting state, repeat this process
	while ({acceptStates.includes(output.at(0)).not},
		{
			newState = output.at(0);
			newTape = output.at(1);
			newTapeHead = output.at(2);
			instruct = instructDict.at([newState, newTape.at(newTapeHead).asString]);
			output = ~step.value(output.at(0), output.at(1), output.at(2), instruct);
			if (print, {output.at(1).postln});
			if (store, {stored.add(output.at(1))});
	});

	if (store, {stored});
};

// Instruction Formatter: takes a List of individual instruction arrays, and
//                        converts them into an instruction Dictionary
~insConverter = {|instructList|
	var instructDict = Dictionary.new;

	instructList.do{|item|
		instructDict.put([item[0], item[1]], [item[2], item[3], item[4]]);
	};
	instructDict;
};

)


///////////////////////////////////////////////////////////////////////////////
// INSTRUCTION BANK: initializes a Turing machine to compute over defined
//                   instruction sets
///////////////////////////////////////////////////////////////////////////////
(
// tm_convert
//   Converts binary integer n into a sequence of n x's.
//   Example initTape: "100110" -->
~tm_convert = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~convert_inst));

~convert_inst = List[
	[\q1, "0", \q1,  "_", \l],
	[\q1, "_", \end, "_", \l],
	[\q1, "1", \q2,  "x", \r],
	[\q2, "0", \q3,  "-", \l],
	[\q2, "1", \q3,  "+", \l],
	[\q3, "x", \q4,  "s", \l],
	[\q3, "s", \q3,  "s", \l],
	[\q3, "t", \q6,  "t", \l],
	[\q4, "x", \q4,  "x", \l],
	[\q4, "t", \q4,  "t", \l],
	[\q4, "_", \q5,  "t", \r],
	[\q5, "t", \q5,  "t", \r],
	[\q5, "x", \q5,  "x", \r],
	[\q5, "s", \q5,  "s", \r],
	[\q5, "-", \q3,  "-", \l],
	[\q5, "+", \q3,  "+", \l],
	[\q6, "s", \q6,  "s", \l],
	[\q6, "t", \q6,  "t", \l],
	[\q6, "_", \q7,  "_", \r],
	[\q7, "t", \q7,  "x", \r],
	[\q7, "s", \q7,  "x", \r],
	[\q7, "-", \q8,  "x", \l],
	[\q7, "+", \q2,  "x", \r],
	[\q8, "x", \q8,  "x", \l],
	[\q8, "_", \q9,  "_", \r],
	[\q9, "x", \q2,  "_", \r],
	[\q2, "x", \q2,  "x", \r],
	[\q2, "_", \q10,  "_", \l],
	[\q10, "x", \q10,  "x", \l],
	[\q10, "_", \end,  "_", \r]
];


// tm_reverse
//   Reverses a string of 1's and 0's.
//   Example initTape: "100110" -->
~tm_reverse = ~initTuringMach.value(\q1, [\q7], ~insConverter.value(~reverse_inst));

~reverse_inst = List[
	[\q1, "0", \q2, "*", \l],
	[\q1, "1", \q3, "*", \l],
	[\q2, "*", \q2, "*", \l],
	[\q2, "0", \q2, "0", \l],
	[\q2, "1", \q2, "1", \l],
	[\q3, "*", \q3, "*", \l],
	[\q3, "0", \q3, "0", \l],
	[\q3, "1", \q3, "1", \l],
	[\q2, "_", \q4, "0", \r],
	[\q3, "_", \q4, "1", \r],
	[\q4, "0", \q4, "0", \r],
	[\q4, "1", \q4, "1", \r],
	[\q4, "*", \q5, "*", \r],
	[\q5, "*", \q5, "*", \r],
	[\q5, "0", \q2, "*", \l],
	[\q5, "1", \q3, "*", \l],
	[\q5, "_", \q6, "_", \l],
	[\q6, "*", \q6, "_", \l],
	[\q6, "0", \q6, "0", \l],
	[\q6, "1", \q6, "1", \l],
	[\q6, "_", \q7, "_", \r],
];

// tm_sort
//   Takes a string of 1's and 0's and sorts them so that the 0's are on the
//	 left and the 1's are on the right.
//   Example initTape: "100110" -->
~tm_sort = ~initTuringMach.value(\q1, [\fin], ~insConverter.value(~sort_inst));

~sort_inst = List[
	[\q1, "0", \q2, "*", \r],
	[\q1, "1", \q4, "*", \r],
	[\q2, "0", \q2, "0", \r],
	[\q2, "1", \q2, "1", \r],
	[\q2, "_", \q5, "s", \l],
	[\q2, "s", \q2, "s", \r],
	[\q2, "t", \q3, "s", \r],
	[\q3, "t", \q3, "t", \r],
	[\q3, "_", \q5, "t", \l],
	[\q4, "_", \q5, "t", \l],
	[\q5, "s", \q5, "s", \l],
	[\q5, "t", \q5, "t", \l],
	[\q5, "0", \q5, "0", \l],
	[\q5, "1", \q5, "1", \l],
	[\q5, "*", \q1, "*", \r],
	[\q4, "0", \q4, "0", \r],
	[\q4, "1", \q4, "1", \r],
	[\q4, "s", \q4, "s", \r],
	[\q4, "t", \q4, "t", \r],
	[\q1, "s", \q6, "s", \l],
	[\q1, "t", \q6, "t", \l],
	[\q6, "*", \q6, "_", \l],
	[\q6, "_", \q7, "_", \r],
	[\q7, "_", \q7, "_", \r],
	[\q7, "s", \q8, "0", \r],
	[\q7, "t", \q8, "1", \r],
	[\q8, "s", \q8, "0", \r],
	[\q8, "t", \q8, "1", \r],
	[\q8, "_", \q9, "_", \l],
	[\q9, "0", \q9, "0", \l],
	[\q9, "1", \q9, "1", \l],
	[\q9, "_", \fin, "_", \r]
];


// tm_bitOr
//   Takes two binary numbers and computes their bitwise OR.
//   Example initTape: "1011?1001" -->
~tm_bitOr = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~bitOr));

~bitOr = List[
	[\q1,"0",\q2,"0",\r],
	[\q1,"1",\q3,"1",\r],
	[\q2,"0",\q2,"0",\r],
	[\q2,"1",\q2,"1",\r],
	[\q2,"?",\q4,"?",\r],
	[\q3,"0",\q3,"0",\r],
	[\q3,"1",\q3,"1",\r],
	[\q3,"?",\q7,"?",\r],
	[\q4,"0",\q5,"_",\l],
	[\q4,"1",\q6,"_",\l],
	[\q4,"_",\q4,"_",\r],
	[\q7,"0",\q8,"_",\l],
	[\q7,"1",\q9,"_",\l],
	[\q7,"_",\q7,"_",\r],

	[\q5,"_",\q5,"_",\l],
	[\q5,"?",\q5_,"?",\l],
	[\q6,"_",\q6,"_",\l],
	[\q6,"?",\q6_,"?",\l],
	[\q8,"_",\q8,"_",\l],
	[\q8,"?",\q8_,"?",\l],
	[\q9,"_",\q9,"_",\l],
	[\q9,"?",\q9_,"?",\l],

	[\q5_,"0",\q5_,"0",\l],
	[\q5_,"1",\q5_,"1",\l],
	[\q5_,"_",\q5__,"_",\r],
	[\q5_,"s",\q5__,"s",\r],
	[\q5_,"t",\q5__,"t",\r],
	[\q6_,"0",\q6_,"0",\l],
	[\q6_,"1",\q6_,"1",\l],
	[\q6_,"_",\q6__,"_",\r],
	[\q6_,"s",\q6__,"s",\r],
	[\q6_,"t",\q6__,"t",\r],
	[\q8_,"0",\q8_,"0",\l],
	[\q8_,"1",\q8_,"1",\l],
	[\q8_,"_",\q8__,"_",\r],
	[\q8_,"s",\q8__,"s",\r],
	[\q8_,"t",\q8__,"t",\r],
	[\q9_,"0",\q9_,"0",\l],
	[\q9_,"1",\q9_,"1",\l],
	[\q9_,"_",\q9__,"_",\r],
	[\q9_,"s",\q9__,"s",\r],
	[\q9_,"t",\q9__,"t",\r],

	[\q5__,"0",\q1,"s",\r],
	[\q5__,"1",\q1,"s",\r],
	[\q6__,"0",\q1,"t",\r],
	[\q6__,"1",\q1,"t",\r],
	[\q8__,"0",\q1,"t",\r],
	[\q8__,"1",\q1,"t",\r],
	[\q9__,"0",\q1,"t",\r],
	[\q9__,"1",\q1,"t",\r],

	[\q1,"?",\q10,"_",\l],
	[\q10,"t",\q10,"1",\l],
	[\q10,"s",\q10,"0",\l],
	[\q10,"_",\end,"_",\r]
];


// tm_bitAnd
//   Takes two binary numbers and computes their bitwise AND.
//   Example initTape: "1011?1001" -->
~tm_bitAnd = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~bitAnd));

~bitAnd = List[
	[\q1, "0", \q2, "s", \r],
	[\q1, "1", \q2, "t", \r],
	[\q2, "0", \q2, "0", \r],
	[\q2, "1", \q2, "1", \r],
	[\q2, "?", \q3, "?", \r],
	[\q3, "_", \q3, "_", \r],
	[\q3, "0", \q4, "_", \l],
	[\q3, "1", \q5, "_", \l],
	[\q4, "_", \q4, "_", \l],
	[\q4, "?", \q4_, "?", \l],
	[\q5, "_", \q5, "_", \l],
	[\q5, "?", \q5_, "?", \l],

	[\q4_, "1", \q4_, "1", \l],
	[\q4_, "0", \q4_, "0", \l],
	[\q5_, "1", \q5_, "1", \l],
	[\q5_, "0", \q5_, "0", \l],

	[\q4_, "s", \q1, "0", \r],
	[\q4_, "t", \q1,"0", \r],
	[\q5_, "s", \q1, "0", \r],
	[\q5_, "t", \q1, "1", \r],

	[\q1, "?", \q6, "_", \l],
	[\q6, "1", \q6, "1", \l],
	[\q6, "0", \q6, "0", \l],
	[\q6, "_", \end, "_", \r],
];


// tm_bitXor
//   Takes two binary numbers and computes their bitwise XOR.
//   Example initTape: "1011?1001" -->
~tm_bitXor = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~bitXor));

~bitXor = List[
	[\q1, "0", \q2, "s", \r],
	[\q1, "1", \q2, "t", \r],
	[\q2, "0", \q2, "0", \r],
	[\q2, "1", \q2, "1", \r],
	[\q2, "?", \q3, "?", \r],
	[\q3, "_", \q3, "_", \r],
	[\q3, "0", \q4, "_", \l],
	[\q3, "1", \q5, "_", \l],
	[\q4, "_", \q4, "_", \l],
	[\q4, "?", \q4_, "?", \l],
	[\q5, "_", \q5, "_", \l],
	[\q5, "?", \q5_, "?", \l],

	[\q4_, "1", \q4_, "1", \l],
	[\q4_, "0", \q4_, "0", \l],
	[\q5_, "1", \q5_, "1", \l],
	[\q5_, "0", \q5_, "0", \l],

	[\q4_, "s", \q1, "0", \r],
	[\q4_, "t", \q1,"1", \r],
	[\q5_, "s", \q1, "1", \r],
	[\q5_, "t", \q1, "0", \r],

	[\q1, "?", \q6, "_", \l],
	[\q6, "1", \q6, "1", \l],
	[\q6, "0", \q6, "0", \l],
	[\q6, "_", \end, "_", \r]
];


// tm_bitNot
//   Takes a binary number and computes its bitwise NOT.
//   Example initTape: "1011?1001" -->
~tm_bitNot = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~bitNot));

~bitNot = List[
	[\q1, "0", \q1, "1", \r],
	[\q1, "1", \q1, "0", \r],
	[\q1, "_", \q2, "_", \l],
	[\q2, "0", \q2, "0", \l],
	[\q2, "1", \q2, "1", \l],
	[\q2, "_", \end, "_", \r],
];


// tm_unExp
//   Takes two unary representations (x+1, y+1), and computes the outputs
//   the unary representation of (1 + pow(x,y))
//   Example initTape: "11111_1111" -->  (computes (1 + pow(4,3))
//   Source: https://philarchive.org/archive/LEMATM
~tm_unExp = ~initTuringMach.value(\q1, [\end], ~insConverter.value(~unExp));

~unExp = List[
	[\q1, "1", \q1, "1", \r],
	[\q1, "_", \q2, "_", \r],
	[\q2, "1", \q3, "1", \r],
	[\q3, "_", \q4, "1", \l],
	[\q4, "_", \q5, "_", \l],
	[\q5, "1", \q6, "_", \l],
	[\q5, "_", \q6, "_", \l],
	[\q6, "1", \q6, "_", \l],
	[\q6, "_", \q7, "_", \r],
	[\q7, "_", \q7, "_", \r],
	[\q7, "1", \end, "1", \r],
	[\q3, "1", \q8, "1", \l],
	[\q8, "1", \q8, "1", \l],
	[\q8, "_", \q9, "_", \l],
	[\q9, "1", \q10, "1", \l],
	[\q10, "_", \q11, "_", \r],
	[\q11, "1", \q11, "1", \r],
	[\q11, "_", \q12, "_", \r],
	[\q12, "1", \q13, "_", \r],
	[\q12, "_", \q13, "_", \r],
	[\q13, "1", \q13, "_", \r],
	[\q13, "_", \q14, "_", \l],
	[\q14, "_", \q14, "_", \l],
	[\q14, "1", \end, "1", \r],
	[\q10, "1", \q15, "1", \r],
	[\q15, "1", \q15, "1", \r],
	[\q15, "_", \q16, "_", \r],
	[\q16, "1", \q16, "1", \r],
	[\q16, "_", \q17, "_", \l],
	[\q17, "1", \q18, "1", \l],
	[\q18, "1", \q19, "1", \l],
	[\q19, "_", \q37, "_", \r],
	[\q37, "1", \q38, "_", \r],
	[\q37, "_", \q38, "_", \r],
	[\q38, "1", \q39, "_", \l],
	[\q39, "_", \q39, "_", \l],
	[\q39, "1", \q40, "1", \l],
	[\q19, "1", \q20, "1", \r],
	[\q20, "1", \q21, "1", \r],
	[\q21, "1", \q22, "_", \l],
	[\q21, "_", \q22, "_", \l],
	[\q22, "1", \q22, "1", \l],
	[\q22, "_", \q23, "_", \l],
	[\q23, "1", \q22, "1", \l],
	[\q23, "_", \q24, "1", \r],
	[\q24, "1", \q24, "1", \r],
	[\q24, "_", \q25, "_", \r],
	[\q25, "1", \q26, "1", \r],
	[\q26, "1", \q27, "1", \r],
	[\q27, "1", \q27, "1", \r],
	[\q27, "_", \q28, "_", \l],
	[\q28, "1", \q29, "_", \l],
	[\q28, "_", \q29, "_", \l],
	[\q29, "1", \q29, "1", \l],
	[\q29, "_", \q30, "_", \l],
	[\q30, "1", \q30, "1", \l],
	[\q30, "_", \q24, "1", \r],
	[\q26, "_", \q32, "1", \r],
	[\q31, "1", \q32, "1", \r],
	[\q32, "_", \q32, "1", \r],
	[\q32, "1", \q33, "1", \l],
	[\q33, "1", \q34, "_", \r],
	[\q33, "_", \q34, "_", \r],
	[\q34, "1", \q34, "1", \r],
	[\q34, "_", \q35, "_", \r],
	[\q35, "1", \q34, "1", \r],
	[\q35, "_", \q36, "_", \l],
	[\q36, "_", \q17, "_", \l],
	[\q40, "1", \q40, "1", \l],
	[\q40, "_", \q41, "_", \l],
	[\q41, "_", \q65, "_", \r],
	[\q65, "_", \q65, "_", \r],
	[\q65, "1", \end, "1", \r],
	[\q41, "1", \q42, "1", \l],
	[\q42, "1", \q42, "1", \l],
	[\q42, "_", \q43, "_", \l],
	[\q43, "1", \q42, "1", \l],
	[\q43, "_", \q44, "1", \r],
	[\q44, "1", \q44, "1", \r],
	[\q44, "_", \q45, "_", \r],
	[\q45, "1", \q44, "1", \r],
	[\q45, "_", \q46, "_", \l],
	[\q46, "_", \q46, "_", \l],
	[\q46, "1", \q47, "1", \l],
	[\q47, "_", \q61, "_", \r],
	[\q61, "1", \q62, "_", \l],
	[\q62, "_", \q62, "_", \l],
	[\q62, "1", \q64, "_", \l],
	[\q63, "_", \q64, "_", \l],
	[\q64, "1", \q64, "_", \l],
	[\q64, "_", \q40, "_", \l],
	[\q47, "1", \q48, "1", \r],
	[\q48, "1", \q49, "_", \l],
	[\q48, "_", \q49, "_", \l],
	[\q49, "1", \q49, "1", \l],
	[\q49, "_", \q50, "_", \l],
	[\q50, "1", \q51, "_", \l],
	[\q50, "_", \q51, "_", \l],
	[\q51, "1", \q51, "1", \l],
	[\q51, "_", \q52, "_", \l],
	[\q52, "1", \q51, "1", \l],
	[\q52, "_", \q67, "_", \r],
	[\q67, "_", \q53, "1", \r],
	[\q53, "1", \q53, "1", \r],
	[\q53, "_", \q54, "_", \r],
	[\q54, "1", \q53, "1", \r],
	[\q54, "_", \q55, "_", \l],
	[\q55, "_", \q55, "_", \l],
	[\q55, "1", \q56, "1", \l],
	[\q56, "1", \q50, "1", \r],
	[\q56, "_", \q57, "_", \r],
	[\q57, "1", \q58, "1", \r],
	[\q58, "_", \q58, "1", \r],
	[\q58, "1", \q59, "1", \l],
	[\q59, "1", \q60, "_", \r],
	[\q59, "_", \q60, "_", \r],
	[\q60, "1", \q60, "1", \r],
	[\q60, "_", \q46, "_", \l]
];


// tm_unMult
//   Takes two unary representations of integers (x,y) and computes the unary
//   representation of their product x*y.
//   Example initTape: "11111*1111=" -->
//   Source: http://web.cecs.pdx.edu/~black/CS311/Lecture%20Notes/Lecture%2011.pdf
~tm_unMult = ~initTuringMach.value(\q0, [\end], ~insConverter.value(~unMult));

~unMult = List[
	[\q0, "1", \q1, "*", \r],
	[\q1, "1", \q1, "1", \r],
	[\q1, "*", \q2, "*", \r],
	[\q2, "1", \q4, "y", \r],
	[\q2, "=", \q3, "=", \l],
	[\q4, "1", \q4, "1", \r],
	[\q4, "=", \q5, "=", \r],
	[\q5, "1", \q5, "1", \r],
	[\q5, "_", \q6, "1", \l],
	[\q6, "1", \q6, "1", \l],
	[\q6, "=", \q7, "=", \l],
	[\q7, "1", \q7, "1", \l],
	[\q7, "y", \q8, "y", \r],
	[\q8, "1", \q4, "y", \r],
	[\q8, "=", \q3, "=", \l],
	[\q3, "y", \q3, "1", \l],
	[\q3, "*", \q9, "*", \l],
	[\q9, "1", \q9, "1", \l],
	[\q9, "*", \q0, "*", \r],
	[\q0, "*", \q12, "*", \l],
	[\q12, "*", \q12, "1", \l],
	[\q12, "_", \end, "_", \r]
];
)



///////////////////////////////////////////////////////////////////////////////
// SIMULATIONS: performs a simulation of the specified Turing machine using an
//              initial tape provided by the user. Should be run individually.
//              ** Sometimes you need to rerun the code blocks above before
//                 these work.
///////////////////////////////////////////////////////////////////////////////
(
a = ~simulate.value(~tm_convert, "10110");
b = ~simulate.value(~tm_reverse, "101011010100111001");
c = ~simulate.value(~tm_sort, "1111111010101010100000000");
d = ~simulate.value(~tm_bitOr, "11011001?10011101");
e = ~simulate.value(~tm_bitAnd, "11011001?10011101");
f = ~simulate.value(~tm_bitXor, "0110?1100");
g = ~simulate.value(~tm_bitNot, "1000011");
h = ~simulate.value(~tm_unExp, "11111_1111");
i = ~simulate.value(~tm_unMult, "111111*111111=");

/* This is useful for decomposing long outputs
h.do{|item, i|
	if ((i >= 7200) and: (i < 8000), {item.postln});
};*/

)


///////////////////////////////////////////////////////////////////////////////
// SYNTH BANK
//
///////////////////////////////////////////////////////////////////////////////
(
// Timpani
SynthDef("timp", { |rel = 0, choose = 0, amp = 0|
    var klank, env;

    klank = Klank.ar(`[choose ! 12, {Rand(0.5, 0.6)} ! 12], BrownNoise.ar(0.7));
    env   = EnvGen.kr(Env.perc(0.01, rel), doneAction: 2);
    Out.ar(0, klank * env.dup * amp);
}).add;


SynthDef("kick808", {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, rel = 1, dist = 0.5, pan = 0;
    var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = EnvGen.ar(Env.perc(0.001, rel, amp), doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	Out.ar(0, Pan2.ar(snd, pan));
}).add;

// High chime
SynthDef("beating", {arg freq = 880, amp = 0.9, art = 1;
	var env, snd1, snd2;
	env = EnvGen.ar(Env.perc(0.01, art), doneAction: 2);
	snd1 = SinOsc.ar(freq);
	snd2 = SinOsc.ar(Line.kr(freq+15, freq, art));
	Out.ar(0, Pan2.ar(Mix([snd1, snd2]), 0, amp*env))
}).add;

SynthDef(\kalimba2, {
    |out = 0, freq = 440, amp = 1, mix = 0.1|
    var snd, click;
    // Basic tone is a SinOsc
    snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.03, Rand(3.0, 4.0), 1, -7), doneAction: 2);
	snd = HPF.ar( LPF.ar(snd, 380), 120);
    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
	click = DynKlank.ar(`[
        // the resonant frequencies are randomized a little to add variation
        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
        [240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
        [-9, 0, -5].dbamp,
        [0.8, 0.07, 0.08]
	], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
	snd = (snd*mix) + (click*(1-mix));
	snd = Mix( snd );
    Out.ar(out, Pan2.ar(snd, 0, amp));
}).add;

// Whistle
SynthDef(\whistle, {
    |out = 0, freq = 440, gate = 1, amp = 0.5, release = 0.2, dur=1.5|
    var snd;
    // whistle sound comes from narrow band pass on pink noise.
    // LFNoise2 is used as an LFO to add some waviness to the pitch.
    // super important for realism is a slight upward pitch slide on the onset (Line.kr)
	snd = BPF.ar(PinkNoise.ar(EnvGen.kr(Env.perc, doneAction: 2)), freq * (2 ** ({ LFNoise2.kr(6, 0.01) } ! 3 + Line.kr(-0.08, 0, 0.07))), 0.001) * 200;
    snd = Splay.ar(snd);
    snd = snd * EnvGen.ar(Env.adsr(0.03, 0.1, 0.9, release), gate, doneAction: 2);
    snd = Pan2.ar(snd, 0, amp);
	snd = snd * Line.kr(1, 0, dur);
    Out.ar(out, snd);
}).add;

SynthDef(\snare2, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// Bladerunner Synth
SynthDef(\cfstring1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: 2);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

// Need for shaker
SynthDef(\grainsShake,{
        |bufnum=0, trigger=1, startPos=0.0, rate= 1, attack=0.01, sustain=0.5,
release=0.25|
	var wave;
	wave = Linen.kr(Impulse.kr(0), attack, sustain, release, doneAction: 2) * // linear envelope generator
	PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, trigger, startPos,
		loop:0, doneAction:2);
	Out.ar(0, Pan2.ar(wave*4, 0));
}).add;

SynthDef(\grainsRev,{
        |bufnum=0, trigger=1, startPos=0.0, rate= 1, attack=0.01, sustain=0.5,
release=0.25|
	var wave;
	wave = Linen.kr(Impulse.kr(0), attack, sustain, release, doneAction: 2) * // linear envelope generator
	PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, trigger, startPos,
		loop:0, doneAction:2);
	Out.ar(0, Pan2.ar(wave, 0));
}).add;


// Sample buffers
q = Buffer.read(s, "/Users/anthonyamadeo/Documents/Schoolwork/2017-18/Fall/CPSC\ 431/Final\ Project/samples/shakers.wav".standardizePath);
w = Buffer.read(s, "/Users/anthonyamadeo/Documents/Schoolwork/2017-18/Fall/CPSC\ 431/Final\ Project/samples/revHat.wav".standardizePath);

)

///////////////////////////////////////////////////////////////////////////////
// HELPFUL FUNCTIONS: used throughout synthesis and composition
///////////////////////////////////////////////////////////////////////////////
(
~countChar = {|string, charString| // number of character char in string
	var count = 0;
	var char = charString.at(0);

	string.do{|item, i|
		if (item == char, {count = count + 1})};
	count;
};

~maxChar = {|tapeList, charString| // max number of a char within any of the tapes of a tapelist
	var max_char = 0, char = charString.at(0);

	tapeList.do{|item, i|
		var countChar = ~countChar.value(item, charString);
		if (item.includes(char),
			{ if (countChar> max_char) {max_char = countChar}});
	};
	max_char;
};


// note often times root is 0
~intervalLookup = {|pitchSet, root, interval| // output semitones from tonic of given interval in scale
	var right_root = pitchSet.size - root - 1; // pitches right of root
	var left_root = pitchSet.size - right_root - 1; // pitches left of root

	case
	{(root + interval >= 0) and: (root + interval < pitchSet.size)} {pitchSet[root + interval]}
	{root + interval >= pitchSet.size}
	{((root + interval)/pitchSet.size).floor * 12 + pitchSet[(root+interval)%pitchSet.size]}
	{(root + interval < 0)}
	{((root+interval)/pitchSet.size).floor * 12 + pitchSet[(root+interval)%pitchSet.size]};
};

// Convert binary string to decimal
~binToDec = {|bin| // takes binary string
	var dec = 0;
	bin.do{|item, i|
		if (item == "1".at(0), {dec = dec * 2 + 1}, {dec = dec * 2})};
	dec;
};

~decToBin = {|dec|
	var bin = "";
	while({dec > 0},
		{if (dec % 2 == 1, {bin = "1" ++ bin}, {bin = "0" ++ bin});
			dec = (dec / 2).floor});
	bin;
};

// Random binary string of length length
~randBin = {|n|
	var output = "";
	n.do{ var rando = 1.0.rand;
		if (rando < 0.5, {output = output ++ "0"}, {output = output ++ "1"})};
	output;
};
)


///////////////////////////////////////////////////////////////////////////////
// COMPOSITIONS: sonifies and performs pieces based on tape output
//
///////////////////////////////////////////////////////////////////////////////

//*****************************************************************************
// Piece 1
//   Orchestration of tm_convert
//*****************************************************************************
(
var tape1, r1;
var max_t, root = 1;

var tempo = 60/180 /2;
var timpPitches = ([36, 43, 46, 48, 45, 41, 43, 48]+12).midicps;

var whistlePitchClass = [2,3,5,7,10];
var whistleAmpSet = [0.7, 0.8, 0.9, 0.8, 0.8, 0.7];

var kalimPitchClass = [0,2,3,5,7,9,10];
var kalimAmpSet = [0.7, 0.8, 0.7, 0.6, 0.7];

var chimePitchClass = (108 + [0, 7, 10, 5]).midicps;


tape1 = ~simulate.value(~tm_convert, "1100"); // 1 -- ends on a good note
// tape1 = ~simulate.value(~tm_convert, "1000"); // 2
// tape1 = ~simulate.value(~tm_convert, "1101", false); // 3
 tempo = tempo / 1.15; // 4
 root = 4; // 4
 whistlePitchClass = [0,2,3,5,7,9,10]; // 4
tape1 = ~simulate.value(~tm_convert, "11011"); // 4 -- super long
//tape1 = ~simulate.value(~tm_convert, "110"); // 5 -- shortest

max_t = ~maxChar.value(tape1, "t");

r1 = Routine({
	tape1.do {|item, i|
		var timpFreq, timpAmp;
		var whistleFreq, whistleAmp, whistleInt;
		var kalimFreq, kalimAmp, kalimInt;
		var chime0Amp, chime1Amp, chimePAmp, chimeMAmp;

		item.postln;

		timpFreq = timpPitches[i % timpPitches.size];
		//if (i % 2 == 0, {timpFreq = timpPitches[0]}, {timpFreq = timpPitches[1]});
		timpAmp = sqrt(~countChar.value(item, "t") / max_t); // sqrt may be unnecessary

		if (item.includes("s".at(0)), // if tape has an "s", calculate amplitude as follows
			{whistleAmp = whistleAmpSet[i % whistleAmpSet.size]},
			{whistleAmp = 0});
		whistleInt = ~countChar.value(item, "s") * -1 + 1;
		whistleFreq = (84 + ~intervalLookup.value(whistlePitchClass, root, whistleInt)).midicps;

		if (item.includes("x".at(0)), // if tape has an "x", calculate amplitude as follows
			{kalimAmp = kalimAmpSet[i % kalimAmpSet.size]},
			{kalimAmp = 0});
		kalimInt = ~countChar.value(item, "x") - 1;
		kalimFreq = (60 + ~intervalLookup.value(kalimPitchClass, 0, kalimInt)).midicps;

		if(item.includes("0".at(0)), {chime0Amp = 1}, {chime0Amp = 0});
		if(item.includes("1".at(0)), {chime1Amp = 1}, {chime1Amp = 0});
		if(item.includes("+".at(0)), {chimePAmp = 1}, {chimePAmp = 0});
		if(item.includes("-".at(0)), {chimeMAmp = 1}, {chimeMAmp = 0});

		Synth("timp", [choose: timpFreq, rel: 0.23, amp: 0.006 * timpAmp]);
		Synth(\whistle, [freq: whistleFreq, amp: 0.4 * whistleAmp]);
		Synth(\kalimba2, [freq: kalimFreq, amp: 3 * kalimAmp]);

		Synth("beating",[freq: chimePitchClass[3], amp: 0.011 * chime0Amp]);
		Synth("beating",[freq: chimePitchClass[2], amp: 0.011 * chime1Amp]);
		Synth("beating",[freq: chimePitchClass[0], amp: 0.011 * chimePAmp]);
		Synth("beating",[freq: chimePitchClass[1], amp: 0.011 * chimeMAmp]);


		tempo.yield;
    };
}).play;
)


//*****************************************************************************
// Piece 2: Don't Touch the Butt / SpongeBob's Alarm Clock
//   Flanger and modulation synthesizer with tm_unExp
//*****************************************************************************
(
var tape;
var dur, overtones, item;

var fundamental = 60.midicps;
// fundamental = 60.midicps;

tape = ~simulate.value(~tm_unExp, "1111_111", false); // pow(3,2)
tape = ~simulate.value(~tm_unExp, "11111_111", false); // pow(4,2)
// tape = ~simulate.value(~tm_unExp, "111111_111", false); // pow(5,2)
// tape = ~simulate.value(~tm_unExp, "111_1111", false); // pow(2,3)
// tape = ~simulate.value(~tm_unExp, "1111_1111", false); // pow (3,3) takes over a minute

tape.do{|item, i|
	item.postln;

	overtones = item.replace("_".at(0), "0".at(0)).separate.asInteger;
	{Mix.fill(overtones.size, {|i|
		var wave;
		wave = SinOsc.ar(fundamental*(i+1)*overtones[i], mul: 1/(i+1)) * EnvGen.kr(Env([1,0], [dur=0.1]), doneAction: 2);
		Pan2.ar(wave, 0);
	})}.play;
};

// Note: by modifying dur inside the synth, you can produce modulation synthesis as well (dur < 1).
)


//*****************************************************************************
// Piece 3
//   Percussion with bitwise operators
//*****************************************************************************
(
var eighth = 60/2/300; // length of eighth note
var tape1, durs1 = [], snareAmps = [], kickAmps = [];
var tape2, durs2 = [], hihatAmps = [], revHatAmps, shakerAmps = [];
var dursHihat = [];

var printRoutine1, printRoutine2;


// Code: Right side: 0 = kick, 1 = snare
//       Left side: 1 = 4 eighth, 0 = 2 eight, t = 3 eighth, s = 1 eighth
// Scramble both sides and pick on of each on every new tape

tape1 = ~simulate.value(~tm_bitOr, ~randBin.value(8) ++ "?" ++ ~randBin.value(8));

tape1.do{|item, i|
	var rhythms = [], events = [], left=true;
	var dur, event, kickAmp, snareAmp;
	var restCount = 0;

	if(item[0] == "_".at(0), {item = item[1..item.size-1]});
	item.postln;

	item.do{|val|
		case
		{val == "?".at(0)} {left=false}
		{left} {rhythms = rhythms.add(val)}
		{val == "_".at(0)}
		{if (restCount%2==1, {events = events.add(val)}); restCount = restCount + 1}
		{events = events.add(val)};
	};
	events.postln;

	dur = rhythms.choose;
	case
	{dur == "0".at(0)} {dur = 2 * eighth}
	{dur == "1".at(0)} {dur = 4 * eighth}
	{dur == "s".at(0)} {dur = 1 * eighth}
	{dur == "t".at(0)} {dur = 3 * eighth};

	event = events.choose;
	case
	{event == "1".at(0)} {kickAmp = 1.3*rrand(0.8,0.9); snareAmp = 0}
	{event == "0".at(0)} {snareAmp = 1.1*rrand(0.8,0.9); kickAmp = 0}
	{event == "_".at(0)} {snareAmp = 0; kickAmp = 0};

	durs1 = durs1.add(dur);
	snareAmps = snareAmps.add(snareAmp);
	kickAmps = kickAmps.add(kickAmp);
};


tape2 = ~simulate.value(~tm_bitOr, ~randBin.value(8) ++ "?" ++ ~randBin.value(8));

tape2.do{|item, i|
	var rhythms = [], events = [], left=true;
	var dur, event, shakerAmp, revHatAmp;
	var restCount = 0;

	if(item[0] == "_".at(0), {item = item[1..item.size-1]});
	item.do{|val|
		case
		{val == "?".at(0)} {left=false}
		{left} {rhythms = rhythms.add(val)}
		{val == "_".at(0)}
		{if (restCount%2==1, {events = events.add(val)}); restCount = restCount + 1}
		{events = events.add(val)};
	};

	dur = rhythms.choose;
	case
	{dur == "0".at(0)} {dur = 2 * eighth}
	{dur == "1".at(0)} {dur = 4 * eighth}
	{dur == "s".at(0)} {dur = 1 * eighth}
	{dur == "t".at(0)} {dur = 3 * eighth};

	event = events.choose;
	case
	{event == "1".at(0)} {shakerAmp = 5*rrand(0.8,0.9); revHatAmp = 0}
	{event == "0".at(0)} {revHatAmp = 1.1*rrand(0.8,0.9); shakerAmp = 0}
	{event == "_".at(0)} {shakerAmp = 5; revHatAmp = 0};

	durs2 = durs2.add(dur);
	revHatAmps = revHatAmps.add(revHatAmp);
	shakerAmps = shakerAmps.add(shakerAmp);

};

dursHihat = ([2*eighth,eighth,eighth,2*eighth] ! (1.75*durs1.size)).flat;
// dursHihat = ([2*eighth,eighth,eighth,4*eighth] ! durs1.size).flat;
(1.75*durs1.size).do{|i| hihatAmps = hihatAmps.add(0.75,0.95)};


Ppar([
	Pbind(\instrument, "kick808", \dur, Pseq(durs1), \amp, Pseq(kickAmps)),
	Pbind(\instrument, "snare2", \dur, Pseq(durs1), \amp, Pseq(snareAmps)),
	Pbind(\instrument, \grainsShake, \bufnum, q, \dur, Pseq(durs2), \amp, Pseq(shakerAmps)),
	Pbind(\instrument, \hihat, \dur, Pseq(dursHihat), \amp, Pseq(hihatAmps)),
	Pbind(\instrument, \grainsRev, \bufnum, w, \dur, Pseq(durs2), \amp, Pseq(revHatAmps))
]).play;
durs1.postln;


printRoutine1 = Routine({
	durs1.do{|item, i| "Tape 1: ".post; tape1[i].postln; item.yield}
}).play;

printRoutine2 = Routine({
	durs2.do{|item, i| "Tape 2: ".post; tape2[i].postln; item.yield}
}).play;



)