#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COcharray.C */
extern IGRint CO_GA_change_dummy __((void));
extern IGRint CO_GA_change_index_in_range __((IGRint index));

#if defined(__cplusplus)
}
#endif


#undef __
