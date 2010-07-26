#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPmpflyfunc.I */
extern int DPmpflyfunc __((IGRlong *msg, IGRshort in_out_flag, IGRdouble *center_pnt, IGRdouble factor, IGRboolean update, GRobjid *gg_objid, GRspacenum *gg_osnum));

#if defined(__cplusplus)
}
#endif


#undef __
