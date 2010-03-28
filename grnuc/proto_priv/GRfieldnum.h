#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRfieldnum.C */
extern IGRboolean GRfield_num __((IGRlong *msg, IGRuchar *text_string, IGRshort *text_length, IGRuchar *field_num));

#if defined(__cplusplus)
}
#endif


#undef __
