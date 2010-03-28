#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCgetparms.I */
extern int LCget_parms __((IGRdouble x, IGRdouble y, IGRdouble z, IGRint type, OM_S_OBJID proj_objid, OMuword proj_osnum, OM_S_OBJID window_id, OMuword window_os, IGRpoint proj_point, struct GRparms *geom_parms, IGRshort matrix_type, IGRmatrix matrix));

#if defined(__cplusplus)
}
#endif


#undef __
