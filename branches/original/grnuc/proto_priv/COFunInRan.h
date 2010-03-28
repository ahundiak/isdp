#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cob/COFunInRan.C */
extern short CO_ni_index_in_range __((long FunctionIndex));
extern long CO_ni_dummy_func __((void));

#if defined(__cplusplus)
}
#endif


#undef __
