#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnimsalng.I */
extern IGRlong CO_ni_measure_length_along_element __((IGRlong *msg, struct GRevent *Events[], struct GRmd_env *ModuleInfo, IGRdouble *Length, IGRchar *Units, GRobjid my_id, OM_S_CHANSELECT *MyChannelStruct, struct GRid *ObjectsGrid));

#if defined(__cplusplus)
}
#endif


#undef __
