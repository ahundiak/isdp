#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COdisact.C */
extern IGRint CO_display_active_parms __((IGRint *msg, struct GRid *module_grid, IGRlong mask, char *final_string));

#if defined(__cplusplus)
}
#endif


#undef __
