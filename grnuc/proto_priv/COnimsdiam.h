#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnimsdiam.I */
extern IGRlong CO_ni_measure_diameter __((IGRlong *msg, struct GRevent *events[], struct GRmd_env *module_info, IGRdouble *diameter, IGRchar *units, GRobjid my_id, OM_S_CHANSELECT *my_channel_struct, struct GRid *object_grids));

#if defined(__cplusplus)
}
#endif


#undef __
