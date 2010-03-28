#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRnotifylist.I */
extern int GRnotifylisteners __((IGRlong *msg, IGRlong *OMmsg, IGRint *mask, OM_S_MESSAGE *gr_message, GRobjid *gr_objid));

#if defined(__cplusplus)
}
#endif


#undef __
