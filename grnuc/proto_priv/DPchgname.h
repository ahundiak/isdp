#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPchgname.C */
extern int DPchg_vw_names __((IGRlong *msg, IGRlong in_flags, GRspacenum osnum, struct EXlstcol *list, IGRlong num_in_list, IGRchar *type, IGRchar *sub_dir));

#if defined(__cplusplus)
}
#endif


#undef __
