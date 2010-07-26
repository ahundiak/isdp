#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cisizeof.C */
static int size __((int t));
extern int CIsizeof __((int v, char **vval, struct instance_ci *c));
extern int CIalign __((int v, struct instance_ci *c));

#if defined(__cplusplus)
}
#endif


#undef __
