#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUgetnum.c */
extern IGRboolean GUget_numeral __((IGRchar *input_string, IGRshort *num));

#if defined(__cplusplus)
}
#endif


#undef __
