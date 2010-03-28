#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/eventsco/COdiscoords.I */
extern IGRint COdiscoords __((IGRlong *msg, struct EX_button *button, struct GRmd_env *module, IGRint field, IGRint just));

#if defined(__cplusplus)
}
#endif


#undef __
