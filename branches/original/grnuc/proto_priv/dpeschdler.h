#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpeschdler.C */
extern int DPesc_handler __((IGRlong *msg, struct DPesc_args *esc_arg1));

#if defined(__cplusplus)
}
#endif


#undef __
