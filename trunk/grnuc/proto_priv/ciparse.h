#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/setup/ciparse.C */
extern int ciruncompiler __((OM_S_OBJID ciid, char *file));

#if defined(__cplusplus)
}
#endif


#undef __
