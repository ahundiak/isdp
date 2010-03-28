#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciactions.c */
extern int asg __((int *rc, int left, int right));
extern int PPLident __((PCIcontext *ctx, int *var, PCIident ident, int action));
extern int AOPfun __((int *ret, int F, PCIlist *args));
extern int cireturn __((int fun, PCIop *o, int ret));
extern int PPLsizeofV __((int *exp, int var));
extern int PPLsizeofT __((int *exp, PCItype *typ));
extern int cimessage __((PCIlist **p_msg, PCIident class, PCIident mess, PCIlist *args));
extern int cisend __((int *send, PCIlist *msg, int target));

#if defined(__cplusplus)
}
#endif


#undef __
