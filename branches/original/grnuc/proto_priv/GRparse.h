#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRparse.C */
extern IGRint GRparse __((IGRlong *msg, IGRchar *input_strptr, IGRchar *symbol_name, IGRint *name_len, IGRchar *symbol_desc, IGRint *desc_len));

#if defined(__cplusplus)
}
#endif


#undef __
