#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/eventsco/COevarray.C */
extern IGRlong CO_GA_ev_func_dummy __((void));
extern IGRboolean CO_GA_ev_func_index_in_range __((IGRlong index));

#if defined(__cplusplus)
}
#endif


#undef __
