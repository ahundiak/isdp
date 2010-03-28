#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnimmindi.I */
extern IGRlong CO_ni_measure_min_dis_2_ele __((IGRlong *msg, struct GRevent *events[], struct GRmd_env *module_info[], IGRdouble *distance, IGRchar *units, GRobjid my_id, OM_S_CHANSELECT *my_chan_struct, struct GRid *object_grids[]));

#if defined(__cplusplus)
}
#endif


#undef __
