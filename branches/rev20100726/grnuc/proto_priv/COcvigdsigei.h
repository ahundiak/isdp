#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvigdsigei.I */
extern IGRchar *COgetIGDSfilename __((IGRchar *filename));
extern IGRchar *COsetIGDSfilename __((IGRchar *filename));
extern void COset_debug_converter __((int state));

#if defined(__cplusplus)
}
#endif


#undef __
