#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cidiv.C */
extern int CIgetvarno __((char *s, struct instance_ci *xdata));
extern int getnofile __((char *nom, int new_use));
extern int erreur __((char *s));
extern int linerreur __((char *s, int linenumber));
extern int ischar __((int var_nb));
extern int isshort __((int var_nb));
extern int isint __((int var_nb));
extern int ispointer __((int var_nb));
extern int isdouble __((int var_nb));
extern int isfunction __((int var_nb));
extern int isextern __((int var_nb));
extern int isGRobj __((int var_nb));
extern int isstring __((int var_nb));
extern int ispoint __((int var_nb));
extern int isarray __((int var_nb));
extern int isnumvalue __((int var_nb));
extern int isintvalue __((int var_nb));
extern int isstruct __((int var_nb));
extern int alloc_ci_IGE __((ci_IGE **p_IGEinfo));
extern int free_ci_IGE __((ci_IGE *IGEinfo));
extern int cieditvar __((int i));
extern int editinstr __((struct ci_instruction *instr));

#if defined(__cplusplus)
}
#endif


#undef __
