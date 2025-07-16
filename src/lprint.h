#if !defined(lprint_h)
#define lprint_h

#include "lobject.h"

void PrintString(const TString* ts);
void PrintType(const Proto* f, int i);
void PrintConstant(const Proto* f, int i);
void PrintCode(const Proto* f, TString **tmname);
void PrintInstruction(const Proto* f, Instruction i, int pc, TString **tmname);

void PrintFunction(const Proto* f, int full, TString **tmname);
#define luaU_print	PrintFunction

#endif