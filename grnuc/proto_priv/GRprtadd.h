#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/partgo/GRprtadd.I */
extern IGRint GRis_a_loop __((struct GRid *owner, struct GRid *component, OM_S_CHANSELECT *comp_chan));

#if defined(__cplusplus)
}
#endif


#undef __
