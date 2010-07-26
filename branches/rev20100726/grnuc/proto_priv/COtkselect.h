#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/eventsco/COtkselect.I */
extern IGRlong COtkselect __((IGRlong *lc_msg, struct LC_select_args *lc_args, struct GRevent *locate_event));

#if defined(__cplusplus)
}
#endif


#undef __
