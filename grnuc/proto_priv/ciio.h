#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciio.C */
extern int ci_file_prep __((struct ci_instruction *instr));
extern int ciread __((struct ci_instruction *instr));
extern int ciwrite __((struct ci_instruction *instr));
extern void ciclose_all __((void));
extern int ciclose __((struct ci_instruction *instr));
extern int erreur_io __((struct ci_instruction *instr, char *file_name, char *msg));

#if defined(__cplusplus)
}
#endif


#undef __
