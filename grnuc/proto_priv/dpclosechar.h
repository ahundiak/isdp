#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpclosechar.I */
extern int DPclosestchar __((IGRlong *msg, struct IGRlbsys *lbsys, struct IGResintx *txt_ele, GRspacenum osnum, GRobjid mod_objid, IGRdouble *point, IGRint *which_char));

#if defined(__cplusplus)
}
#endif


#undef __
