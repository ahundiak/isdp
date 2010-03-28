#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/M_cidb.C */
extern int ciDBinit __((struct ci_instruction *instr));
extern int ciDBopen __((struct ci_instruction *instr));
extern int ciDBclose __((struct ci_instruction *instr));
extern int ciDBcmd __((struct ci_instruction *instr));
extern int ciDBsearch __((struct ci_instruction *instr));
extern int ciDBread __((struct ci_instruction *instr));
extern int ciDBwrite __((struct ci_instruction *instr));
extern int ciDBflush __((struct ci_instruction *instr));
extern int ciDBselect __((struct ci_instruction *instr));
extern int ciDBattach __((struct ci_instruction *instr));
extern int ciDBdetach __((struct ci_instruction *instr));

#if defined(__cplusplus)
}
#endif


#undef __
