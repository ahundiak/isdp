#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPcal.I */
extern int DPcalinfo __((IGRlong *msg, GRspacenum osnum, IGRchar *gragad_name, GRobjid gragad_objid));

#if defined(__cplusplus)
}
#endif


#undef __
