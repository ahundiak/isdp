#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRbbegescseq.C */
extern IGRshort GRbwd_beg_esc_seq __((IGRlong *msg, IGRuchar *text_string, IGRshort *num_chars, IGRchar *esc_chars, IGRchar *esc_nums[], IGRshort *end_index, IGRint font_flags, IGRshort *beg_esc));

#if defined(__cplusplus)
}
#endif


#undef __
