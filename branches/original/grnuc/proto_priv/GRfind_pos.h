#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfind_pos.C */
extern IGRboolean GRfind_position __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRshort *line_num, IGRshort *user_position, IGRshort *actual_position));

#if defined(__cplusplus)
}
#endif


#undef __
