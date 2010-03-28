#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* src_datum/imp/EMdmfunc.I */
extern IGRint EMget_datum_plane_mgr __((IGRlong *EMmsg, OMuword *os, 
        OM_S_OBJID *mgrid, OMuword *mgros)); 

extern IGRint EMget_active_datum_plane __((IGRlong *EMmsg, 
    unsigned int options, struct GRid *plane_GRid, struct GRid *win_GRid)); 

#if defined(__cplusplus)
}
#endif


#undef __
