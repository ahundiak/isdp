#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPaddvwname.C */
extern int DPadd_vw_name_dir __((IGRlong *msg, IGRlong in_flags, GRspacenum osnum, GRobjid objid, IGRchar *type, IGRchar *sub_dir, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
