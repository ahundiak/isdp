#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfwdescseq.C */
extern IGRshort GRfwd_esc_seq __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRboolean *multi_mode, IGRshort *start_position, IGRshort *num_chars));

#if defined(__cplusplus)
}
#endif


#undef __
