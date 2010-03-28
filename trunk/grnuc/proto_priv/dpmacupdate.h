#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpmacupdate.I */
extern IGRint DPmacupdate __((IGRlong *msg, struct DPdit_range *range, GRobjid objid, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
