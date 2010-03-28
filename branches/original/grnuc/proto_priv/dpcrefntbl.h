#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpcrefntbl.C */
extern int DPcreate_fnt_tbl __((IGRlong *msg, struct DPfnt_os_tbl *fnt_os_tbl, GRspacenum fnt_os));

#if defined(__cplusplus)
}
#endif


#undef __
