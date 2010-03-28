#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPgetid.C */
extern IGRint DPgetid __((IGRlong *msg, IGRchar *name, IGRlong array_size, IGRlong *total_num, IGRlong *numid, struct GRid *found_ids, GRspacenum *osnum, IGRchar *path));

#if defined(__cplusplus)
}
#endif


#undef __
