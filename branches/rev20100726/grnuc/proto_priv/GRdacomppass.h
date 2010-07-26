#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/detailgo/GRdacomppass.I */
extern IGRint GRdvget_comp_type __((IGRlong *msg, struct GRid *go_id, IGRint *selector));
extern IGRint GRcomponent_pass_fun __((IGRlong *msg, OM_p_MESSAGE pass_msg, IGRint selector, GRobjid dv_objid, GRspacenum dv_osnum));

#if defined(__cplusplus)
}
#endif


#undef __
