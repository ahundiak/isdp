#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/COparai.I */
extern int ASget_active_symb __((IGRshort *level, struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
