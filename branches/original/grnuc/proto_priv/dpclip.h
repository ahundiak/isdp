#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpclip.C */
extern IGRint DPclip __((IGRlong *message, IGRboolean *clip, IGRboolean *front_clip, IGRboolean *back_clip, IGRdouble dit_clip_range[], IGRlong *index, IGRdouble *in_buf, IGRlong *no_in_vec, IGRdouble *out_buf, IGRlong *no_out_vec));

#if defined(__cplusplus)
}
#endif


#undef __
