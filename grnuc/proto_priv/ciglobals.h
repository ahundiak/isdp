#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciglobals.c */
extern void GLOinit __((SysVfname F));

#if defined(__cplusplus)
}
#endif


#undef __
