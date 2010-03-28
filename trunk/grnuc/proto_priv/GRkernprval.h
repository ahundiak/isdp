#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRkernprval.C */
extern IGRint GRkern_pair_value __((IGRlong *msg, IGRuchar *text_string, FontId fontid, IGRint sixteen_bit, IGRdouble *kern_value));

#if defined(__cplusplus)
}
#endif


#undef __
