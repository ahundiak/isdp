#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/exec_node/ASlinei.I */
extern int ASprint_line_ext __((FILE *stream, IGRdouble d0, IGRdouble d1, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
