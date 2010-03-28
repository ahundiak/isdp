#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/rfco/COinit_vari.C */
extern int COinit_variables __((IGRint *msg, struct GRmd_env *ModuleInfo, IGRshort *ActiveLevel, struct IGRdisplay *ActiveDisplay));

#if defined(__cplusplus)
}
#endif


#undef __
