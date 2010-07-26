#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUnormknot.C */
extern IGRlong GUnormalize_knots __((IGRdouble old[], IGRdouble new[], IGRlong *number, IGRshort *order));

#if defined(__cplusplus)
}
#endif


#undef __
