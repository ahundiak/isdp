#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRpachsym.I */
extern IGRint GRpachsym __((IGRlong *msg, GRobjid *caller, OM_S_CHANSELECT *to_comp));

#if defined(__cplusplus)
}
#endif


#undef __
