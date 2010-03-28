#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRhorjustmv.C */
extern IGRboolean GRhorizontal_just_mv __((IGRlong *message, IGRshort text_just, IGRdouble text_width, struct just_info *just_info, IGRdouble *h_move));

#if defined(__cplusplus)
}
#endif


#undef __
