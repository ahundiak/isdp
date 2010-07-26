#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/textgo/GRvertssmv.C */
extern IGRboolean GRvertical_ss_move __((int msg, IGRuchar *text_string, IGRshort *text_length, IGRdouble text_height, IGRdouble *v_move));

#if defined(__cplusplus)
}
#endif


#undef __
