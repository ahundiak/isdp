#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/ciextsym.C */
extern int CIloadsyms __((void));
extern void CIfreesyms __((void));
extern void *CIfindsym __((char *name));
extern int CIdynlink __((struct instance_ci *data, char *file, OM_S_OBJID ciid));

#if defined(__cplusplus)
}
#endif


#undef __
