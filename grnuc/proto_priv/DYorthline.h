#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/DYorthline.I */
extern IGRint DYorthline __((struct orthoinfo *DYinfo, struct EX_button *Cursor, IGRdouble *ViewMatrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dum1, IGRchar *in_dum2, IGRchar *in_dum3, IGRchar **out_dum1, IGRchar **out_dum2, IGRchar **out_dum3));
extern IGRlong DYrborthline __((IGRlong function_index, struct GRevent *events[], struct GRmd_env *Context, GRobjid MyId, GRspacenum my_os, OM_S_CHANSELECT *MyChannelStruct, struct GRid *ObjectGrid));

#if defined(__cplusplus)
}
#endif


#undef __
