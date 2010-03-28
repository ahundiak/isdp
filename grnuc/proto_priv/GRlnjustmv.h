#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRlnjustmv.C */
extern IGRint GRline_just_move __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *start_index, IGRdouble text_width, IGRint font_flags, IGRdouble *line_just_move));

#if defined(__cplusplus)
}
#endif


#undef __
