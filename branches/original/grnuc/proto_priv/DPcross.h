#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPcross.I */
extern int DPdrawcross __((IGRlong *msg, struct EX_button *t_point));
extern int DPerasecross __((IGRlong *msg));

#if defined(__cplusplus)
}
#endif


#undef __
