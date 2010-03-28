#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grdpb/grdpb/GRsetinq.I */
extern IGRint GRsetinq __((IGRlong *msg, struct var_list *var_list, IGRint set_inq));

#if defined(__cplusplus)
}
#endif


#undef __
