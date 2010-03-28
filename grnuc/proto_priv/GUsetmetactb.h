#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUsetmetactb.c */
extern IGRboolean GUsetmetactb __((IGRlong *msg, IGRchar *metafile, IGRchar *igdsctbfile));

#if defined(__cplusplus)
}
#endif


#undef __
