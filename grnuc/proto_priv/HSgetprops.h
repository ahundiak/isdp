#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/HSgetprops.C */
extern IGRint HSgetprops __((IGRuint *properties));

#if defined(__cplusplus)
}
#endif


#undef __
