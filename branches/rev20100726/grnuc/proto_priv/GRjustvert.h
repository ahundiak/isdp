#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRjustvert.C */
extern IGRboolean GRjust_vertical __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort text_just, IGRdouble text_height, struct extents *extents, IGRint num_positions, IGRshort *positions[]));

#if defined(__cplusplus)
}
#endif


#undef __
