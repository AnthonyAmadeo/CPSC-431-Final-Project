// Anthony Amadeo
// CPSC 431

/*
TuringMach takes an initial state Symbol, a Set of accepting states, an initial
tape String, and a Dictionary of instructions. The instruction Dictionary more
specifically maps an input list to an output list. The input list is defined as
[current_state_symbol, current_tape_char], and the output list is defined as
[next_state_symbol, new_tape_char, tape_direction], where tape_direction is either
{\L, \R}.

All states should be represented by symbols.
*/

TuringMach{

	var <>startState, <>acceptingStates, <>initTape, <>initInstructs;

	*new {
		||
		^super.newCopyArgs(statState, acceptingStates, initTape, initInstructs).initTuringMach();
	}

	initTuringMach{
		||

	}

	step {}

	print {}

	simulate {}




}