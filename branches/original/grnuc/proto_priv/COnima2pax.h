#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnima2pax.I */
extern IGRlong CO_ni_measure_angle_of_2_pts_and_axis __((IGRlong *ReturnMsg, struct GRevent *Events[], struct GRmd_env *ModuleInfo[], IGRdouble *Angle, IGRchar *Units, GRobjid my_id, OM_S_CHANSELECT *MyChannelStruct, struct GRid *ObjectsGrid[]));

#if defined(__cplusplus)
}
#endif


#undef __
