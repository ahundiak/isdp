#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRoddescchr.C */
extern IGRboolean GRodd_esc_chars __((IGRlong *msg, IGRuchar *text_string, IGRshort start_position, IGRshort *num_escapes));

#if defined(__cplusplus)
}
#endif


#undef __
