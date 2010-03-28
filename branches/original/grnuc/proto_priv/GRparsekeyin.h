#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/GRparsekeyin.C */
extern int GRparse_multiple_entry_keyin __((IGRchar string[], IGRuchar buffer[], IGRint (*conversion_func )(), IGRint alpha, IGRint low, IGRint high, OMuword osnum));
extern IGRint GRnumber_conversion __((IGRchar string[], IGRint *number, IGRint low, IGRint high, OMuword osnum));
extern IGRint GRcolor_conversion __((IGRchar string[], IGRint *number, IGRint low, IGRint high, OMuword osnum));

#if defined(__cplusplus)
}
#endif


#undef __
