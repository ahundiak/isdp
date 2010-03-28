#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvigeigdsi.I */
extern IGRint GRget_conversion_window __((struct GRid *win));

#if defined(__cplusplus)
}
#endif


#undef __
