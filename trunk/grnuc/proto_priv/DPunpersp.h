#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPunpersp.I */
extern int DPunpersp __((IGRlong *msg, struct GRid *gg_id));

#if defined(__cplusplus)
}
#endif


#undef __
