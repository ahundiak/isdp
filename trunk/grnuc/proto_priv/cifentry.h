#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/com/cifentry.C */
extern int create_f_ent __((struct instance_ci *code, char *name, int no_instr));

#if defined(__cplusplus)
}
#endif


#undef __
