#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRupdclrform.C */
extern IGRint GRupdcolorform __((IGRlong *msg, IGRushort active_color, IGRshort num_colors, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
