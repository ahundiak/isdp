#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRvertjustmv.C */
extern IGRboolean GRvertical_just_mv __((IGRlong *message, IGRshort text_just, IGRdouble text_height, struct extents *text_extents, IGRdouble *v_move));

#if defined(__cplusplus)
}
#endif


#undef __
