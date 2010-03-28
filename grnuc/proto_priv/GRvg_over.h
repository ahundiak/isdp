#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/exec_node/GRvg_over.I */
extern int IGRboolean __((*func));
extern IGRint ASredirect_msg_to_mod __((OM_S_MESSAGE *mess, OM_S_OBJID send_id, GRspacenum send_os));

#if defined(__cplusplus)
}
#endif


#undef __
