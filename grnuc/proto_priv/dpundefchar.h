#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpundefchar.C */
extern int DPset_undef_char __((IGRlong *msg, struct f_facts *fun_facts, IGRchar *undef_char_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
