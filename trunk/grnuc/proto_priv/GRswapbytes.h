#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRswapbytes.C */
extern IGRboolean GRswap_bytes __((IGRlong *msg, IGRuchar *text_string, IGRshort text_length, IGRuchar *swapped_string));

#if defined(__cplusplus)
}
#endif


#undef __
