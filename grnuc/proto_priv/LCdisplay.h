#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCdisplay.I */
extern IGRint LCdisplay __((IGRlong *msg, IGRshort *matrix_type, IGRmatrix matrix, enum GRdpmode *hilight_mode, struct GRid *window_id, OM_S_OBJID objid, OMuword osnum, IGRint element, IGRint window, struct GRid *mod_id, struct GRparms *parms, IGRint *ext_o_element));

#if defined(__cplusplus)
}
#endif


#undef __
