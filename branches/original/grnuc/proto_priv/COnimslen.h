#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnimslen.I */
extern IGRlong CO_ni_measure_length __((IGRlong *msg, struct GRevent *events[], struct GRmd_env *module_info, IGRdouble *length, IGRchar *units, GRobjid my_id, OM_S_CHANSELECT *p_chanselect, struct GRid *object_grids));

#if defined(__cplusplus)
}
#endif


#undef __
