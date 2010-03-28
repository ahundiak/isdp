#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciextern.C */
extern struct ret_val *ci_call __((char (*f_addr )(), int nargs, char arg_types[], short arg_sizes[], char arg_aligns[], char *args[]));
extern int add_alignment __((int cur_index, int numargs, char arg_types[]));
extern int cibranchxtrn __((struct ci_instruction *instr));

#if defined(__cplusplus)
}
#endif


#undef __
