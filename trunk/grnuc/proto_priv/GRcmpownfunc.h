#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ownergo/GRcmpownfunc.I */
extern IGRint GRget_to_comp_chansel __((OM_S_CHANSELECT *p_chansel));
extern IGRint GRget_to_comp_info __((OM_S_CHANSELECT *p_chansel, OMuword osnum, OM_S_OBJID objid, IGRint *p_count));

#if defined(__cplusplus)
}
#endif


#undef __
