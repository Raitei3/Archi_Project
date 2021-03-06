#/* $begin seq-all-hcl */
#/* $begin seq-plus-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2002       #
####################################################################

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig NOP 	'I_NOP'
intsig HALT	'I_HALT'
intsig RRMOVL	'I_RRMOVL'
intsig IRMOVL	'I_IRMOVL'
intsig RMMOVL	'I_RMMOVL'
intsig MRMOVL	'I_MRMOVL'
intsig OPL	'I_ALU'
intsig IOPL	'I_ALUI'
intsig JXX	'I_JXX'
intsig CALL	'I_CALL'
intsig RET	'I_RET'
intsig PUSHL	'I_PUSHL'
intsig POPL	'I_POPL'
intsig JMEM	'I_JMEM'
intsig JREG	'I_JREG'
intsig LEAVE	'I_LEAVE'

intsig ENTER  'I_ENTER'
intsig MUL 'I_MUL'

##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"
intsig REAX		'REG_EAX'

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig icode	'icode'			# Instruction control code
intsig ifun	'ifun'			# Instruction function
intsig rA	'ra'			# rA field from instruction
intsig rB	'rb'			# rB field from instruction
intsig valC	'valc'			# Constant from instruction
intsig valP	'valp'			# Address of following instruction

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Bch	'bcond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory


####################################################################
#    Control Signal Definitions.                                   #
intsig cc 'cc'
####################################################################

################ Fetch Stage     ###################################

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { RRMOVL, OPL, PUSHL, POPL, RMMOVL, MRMOVL,MUL };

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { RRMOVL, RMMOVL, MRMOVL, JXX, PUSHL, OPL };

bool instr_valid = icode in 
	{ NOP, HALT, RRMOVL, RMMOVL, MRMOVL,
	       OPL, JXX, PUSHL, POPL, ENTER,MUL };
int instr_next_ifun = [

		icode == ENTER && ifun == 0 : 1;	#permet l'injection de ENTER 1

		icode == MUL && ifun == 2 && cc==2 : -1;	#permet les injections des instructions MUL
		icode == MUL && ifun == 2 : 1;				#dans le bon ordre
		icode == MUL && ifun == 0: 1;
		icode == MUL && ifun == 1 : 2;

		1 : -1;
];

################ Decode Stage    ###################################

## What register should be used as the A source?
int srcA = [
	icode == PUSHL && ifun == 0 : rA; 	#ifun = 0 est le vrais pushl ifun = 1 designe call

	icode == ENTER && ifun == 0 : REBP; #ENTER et ifun = 0 tient lieu de PUSHL %ebp.
										# ifun = 1 est un rrmovl %esp,%ebp
	icode == MUL && ifun == 2 : rA;

	icode in { RRMOVL, RMMOVL, OPL, PUSHL } : rA;
	icode in { POPL,ENTER } : RESP;
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
int srcB = [
	icode == ENTER && ifun == 0 : RESP;

	icode == MUL && ifun == 1 : rB;
	icode == MUL && ifun == 2 : REAX;

	icode in { OPL, RMMOVL, MRMOVL} : rB;
	icode in { PUSHL, POPL } : RESP;

	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
int dstE = [
	icode == ENTER && ifun == 1 : REBP;

	icode == MUL && ifun==0 : REAX;
	icode == MUL && ifun==2 && cc != 2 : REAX;
	icode == MUL && ifun == 1 : rB;

	icode in { RRMOVL, OPL } : rB;
	icode in { PUSHL, POPL, ENTER } : RESP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the M destination?
int dstM = [

	icode == POPL && ifun == 0 : rA;

	icode in { MRMOVL } : rA;
	1 : RNONE;  # Don't need register
];

################ Execute Stage   ###################################

## Select input A to ALU

int aluA = [
	icode == OPL && rA == RNONE : valC;
	icode == OPL: valA;

	icode == RRMOVL && rA ==RNONE: valC;
	icode == RRMOVL : valA;

	icode == ENTER && ifun == 1 : valA;

	icode == MUL && ifun == 1 : -1;
	icode == MUL && ifun == 2 : valA;

	icode in { RMMOVL, MRMOVL} : valC;
	icode in { PUSHL,ENTER } : -4;
	icode in {  POPL } : 4;
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	icode == ENTER && ifun==1 : 0;

	icode == MUL && ifun == 0: 0 ;
	icode == MUL && ifun == 1 : valB;
	icode == MUL && ifun == 2: valB;

	icode in { RMMOVL, MRMOVL, OPL, PUSHL, RET, POPL, ENTER } : valB;
	icode in { RRMOVL } : 0;

	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	icode in { OPL } : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
bool set_cc = icode in { OPL  }|| (icode == MUL && ifun == 1); #onvmet a jour le cc aprés la decrementation du compteur

################ Memory Stage    ###################################

## Set read control signal
bool mem_read = icode in { MRMOVL, POPL };

## Set write control signal
bool mem_write = icode in { RMMOVL, PUSHL, ENTER } || (icode == ENTER && ifun==0);

## Select memory address
int mem_addr = [
	icode == ENTER && ifun == 0 : valE;

	icode in { RMMOVL, PUSHL, MRMOVL } : valE;
	icode in { POPL } : valA;
	# Other instructions don't need address
];

## Select memory input data
int mem_data = [
	# Value from register
	icode == PUSHL && ifun == 0: valA;
	icode == PUSHL && ifun==1 : valP;

	icode == ENTER && ifun == 0 : valA;

	icode in { RMMOVL } : valA;
	# Default: Don't write anything
];

################ Program Counter Update ############################

## What address should instruction be fetched at

int new_pc = [
	# Call.  Use instruction constant
	icode == PUSHL && ifun== 1 : valC;
	# Taken branch.  Use instruction constant
	icode == JXX && Bch : valC;
	# Completion of RET instruction.  Use value from stack
	icode == POPL && ifun == 1 : valM;
	# Default: Use incremented PC
	1 : valP;
];
#/* $end seq-plus-all-hcl */
#/* $end seq-all-hcl */
