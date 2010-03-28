#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpmacgenupd.I */
extern IGRint DPgenupdate __((IGRlong *msg, struct DPdit_range *range, enum GRdpmode mode, IGRboolean erase, GRobjid mod_objid, GRobjid objid, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
