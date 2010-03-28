#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COmnfunc.I */
extern IGRint COmn_move __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_copy __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_align __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_align __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_mirrorvh __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix, IGRint normal));
extern IGRint COmn_mirrorv __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_mirrorv __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_mirrorh __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_mirrorh __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_mirrorl __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_mirrorl __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_rotate_aa __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_rotate_aa __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_rotate_ax __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_rotate_ax __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_rotate_3pts __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_rotate_3pts __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_scale_as __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_scale_as __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_scale_3pts __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));
extern IGRint COmn_cp_scale_3pts __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRevent *events[], IGRdouble *matrix));

#if defined(__cplusplus)
}
#endif


#undef __
