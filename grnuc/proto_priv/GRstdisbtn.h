#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRstdisbtn.C */
extern IGRint GRstatus_display_button __((IGRint on));

#if defined(__cplusplus)
}
#endif


#undef __
