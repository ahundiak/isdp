#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* src_dpb/funk/EMdpbfunc.I */
extern IGRint EMget_dpbobjid __((IGRlong *EMmsg, OM_S_OBJID *dpbid, 
    OMuword *dpbos)); 

extern IGRint EMdpb_getinfo __((IGRlong *EMmsg, struct EMdpbinfo *dpbinfo)); 

extern IGRint EMdpb_get_trans __((IGRlong *EMmsg, IGRlong parameter, 
    IGRlong *buffer)); 

extern IGRint EMdpb_get __((IGRlong *EMmsg, IGRlong parameter, 
    IGRuchar *buffer)); 

extern IGRint EMdpb_putinfo __((IGRlong *EMmsg, struct EMdpbinfo *dpbinfo));

extern IGRint EMdpb_put_trans __((IGRlong *EMmsg, IGRlong parameter, 
    IGRlong *buffer)); 

extern IGRint EMdpb_put __((IGRlong *EMmsg, IGRlong parameter, 
    IGRuchar *buffer)); 

extern IGRint EFupdate_form __((void));

#if defined(__cplusplus)
}
#endif


#undef __
