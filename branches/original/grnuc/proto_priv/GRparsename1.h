#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRparsename.C */
extern IGRint GRparse_name_desc __((IGRlong *msg, IGRchar *input_strptr, IGRchar *name, IGRint *name_len, IGRchar *desc, IGRint *desc_len));

#if defined(__cplusplus)
}
#endif


#undef __
