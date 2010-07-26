#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRjustexts.C */
extern IGRboolean GRjust_extents __((IGRlong *message, IGRshort text_just, IGRshort num_lines, struct extents *text_extents, struct extents *just_extents));

#if defined(__cplusplus)
}
#endif


#undef __
