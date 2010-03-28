#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRtransrange.c */
extern IGRboolean GRtransrange __((IGRlong *message, OM_p_KEY_DESC range_key, GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
