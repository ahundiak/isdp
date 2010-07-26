#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPgetsavvwid.I */
extern IGRint DPgetvwid __((IGRlong *msg, IGRchar *name, IGRlong array_size, IGRlong *total_num, IGRlong *numid, struct GRid *found_ids, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
