#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cioper.C */
extern double ci_give_value __((int i));
extern int ci_give_intvalue __((int i));
extern int ci_relop __((struct ci_instruction *instr));
extern int double_arop __((struct ci_instruction *instr));
extern int int_arop __((struct ci_instruction *instr));
extern int ci_binbit_op __((struct ci_instruction *instr));

#if defined(__cplusplus)
}
#endif


#undef __
