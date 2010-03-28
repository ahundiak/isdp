#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_crdef5.I */
extern int COm_generate_name __((char *name, char *prefix, int size, int index, int type, struct GRid *obj));

#if defined(__cplusplus)
}
#endif


#undef __
