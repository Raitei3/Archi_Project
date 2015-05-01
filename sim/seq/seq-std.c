char simname[] = "Y86 Processor: seq-std.hcl";
#include <stdio.h>
#include "isa.h"
#include "sim.h"
int sim_main(int argc, char *argv[]);
int gen_pc(){return 0;}
int main(int argc, char *argv[])
  {plusmode=0;return sim_main(argc,argv);}
int gen_need_regids()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_MUL));
}

int gen_need_valC()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JXX)||(icode) == (I_PUSHL)||(icode) == (I_ALU));
}

int gen_instr_valid()
{
    return ((icode) == (I_NOP)||(icode) == (I_HALT)||(icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_JXX)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_ENTER)||(icode) == (I_MUL));
}

int gen_instr_next_ifun()
{
    return ((((icode) == (I_ENTER)) & ((ifun) == 0)) ? 1 : (((icode) == (I_NOP)) & ((ifun) == 0)) ? 1 : ((((icode) == (I_MUL)) & ((ifun) == 2)) & ((cc) == 2)) ? -1 : (((icode) == (I_MUL)) & ((ifun) == 2)) ? 1 : (((icode) == (I_MUL)) & ((ifun) == 0)) ? 1 : (((icode) == (I_MUL)) & ((ifun) == 1)) ? 2 : 1 ? -1 : 0);
}

int gen_srcA()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == 0)) ? (ra) : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? (REG_EBP) : (((icode) == (I_MUL)) & ((ifun) == 2)) ? (ra) : ((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)) ? (ra) : ((icode) == (I_POPL)||(icode) == (I_RET)||(icode) == (I_ENTER)) ? (REG_ESP) : 1 ? (REG_NONE) : 0);
}

int gen_srcB()
{
    return ((((icode) == (I_MUL)) & ((ifun) == 1)) ? (rb) : (((icode) == (I_MUL)) & ((ifun) == 2)) ? (REG_EAX) : ((icode) == (I_ALU)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_RET)) ? (REG_ESP) : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? (REG_ESP) : 1 ? (REG_NONE) : 0);
}

int gen_dstE()
{
    return ((((icode) == (I_ENTER)) & ((ifun) == 1)) ? (REG_EBP) : ((icode) == (I_RRMOVL)||(icode) == (I_ALU)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_ENTER)) ? (REG_ESP) : (((icode) == (I_MUL)) & ((ifun) == 0)) ? (REG_EAX) : ((((icode) == (I_MUL)) & ((ifun) == 2)) & ((cc) != 2)) ? (REG_EAX) : (((icode) == (I_MUL)) & ((ifun) == 1)) ? (rb) : 1 ? (REG_NONE) : 0);
}

int gen_dstM()
{
    return ((((icode) == (I_POPL)) & ((ifun) == 0)) ? (ra) : ((icode) == (I_MRMOVL)) ? (ra) : 1 ? (REG_NONE) : 0);
}

int gen_aluA()
{
    return ((((icode) == (I_ALU)) & ((ra) == (REG_NONE))) ? (valc) : ((icode) == (I_ALU)) ? (vala) : (((icode) == (I_RRMOVL)) & ((ra) == (REG_NONE))) ? (valc) : ((icode) == (I_RRMOVL)) ? (vala) : (((icode) == (I_ENTER)) & ((ifun) == 1)) ? (vala) : (((icode) == (I_MUL)) & ((ifun) == 1)) ? -1 : (((icode) == (I_MUL)) & ((ifun) == 2)) ? (vala) : ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)) ? (valc) : ((icode) == (I_PUSHL)||(icode) == (I_ENTER)) ? -4 : ((icode) == (I_RET)||(icode) == (I_POPL)) ? 4 : 0);
}

int gen_aluB()
{
    return ((((icode) == (I_ENTER)) & ((ifun) == 1)) ? 0 : ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_RET)||(icode) == (I_POPL)||(icode) == (I_ENTER)) ? (valb) : ((icode) == (I_RRMOVL)) ? 0 : (((icode) == (I_MUL)) & ((ifun) == 0)) ? 0 : (((icode) == (I_MUL)) & ((ifun) == 1)) ? (valb) : (((icode) == (I_MUL)) & ((ifun) == 2)) ? (valb) : 0);
}

int gen_alufun()
{
    return (((icode) == (I_ALU)) ? (ifun) : 1 ? (A_ADD) : 0);
}

int gen_set_cc()
{
    return (((icode) == (I_ALU)) | (((icode) == (I_MUL)) & ((ifun) == 1)));
}

int gen_mem_read()
{
    return ((icode) == (I_MRMOVL)||(icode) == (I_POPL)||(icode) == (I_RET));
}

int gen_mem_write()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_ENTER)) | (((icode) == (I_ENTER)) & ((ifun) == 0)));
}

int gen_mem_addr()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_MRMOVL)) ? (vale) : ((icode) == (I_POPL)||(icode) == (I_RET)) ? (vala) : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? (vale) : 0);
}

int gen_mem_data()
{
    return (((icode) == (I_RMMOVL)) ? (vala) : (((icode) == (I_PUSHL)) & ((ifun) == 0)) ? (vala) : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? (vala) : (((icode) == (I_PUSHL)) & ((ifun) == 1)) ? (valp) : 0);
}

int gen_new_pc()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == 1)) ? (valc) : (((icode) == (I_JXX)) & (bcond)) ? (valc) : (((icode) == (I_POPL)) & ((ifun) == 1)) ? (valm) : 1 ? (valp) : 0);
}

