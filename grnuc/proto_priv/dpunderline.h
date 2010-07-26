#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpunderline.I */
extern int DPunderine __((IGRlong *msg, struct IGRlbsys *lbsys, struct IGResintx *txt_ele, GRspacenum osnum, GRobjid mod_objid, IGRint which_char, IGRint which_point, IGRint horizontal, IGRdouble *point1, IGRdouble *point2));

#if defined(__cplusplus)
}
#endif


#undef __
