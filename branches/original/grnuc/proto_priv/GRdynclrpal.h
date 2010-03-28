#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRdynclrpal.C */
extern IGRint GRdyncolorpal __((IGRlong *msg, IGRint palette_label, IGRint palette_x1, IGRint palette_y1, IGRint palette_x2, IGRint palette_y2, Form form_ptr, IGRshort *num_colors));

#if defined(__cplusplus)
}
#endif


#undef __
