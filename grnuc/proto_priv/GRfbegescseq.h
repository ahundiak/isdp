#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfbegescseq.C */
extern IGRshort GRfwd_beg_esc_seq __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *num_chars, IGRchar *esc_chars, IGRuchar *esc_nums[], IGRshort *start_index, IGRshort *prev_font, IGRshort *current_font, struct vfont_entry *font_info, IGRshort *beg_esc));

#if defined(__cplusplus)
}
#endif


#undef __
