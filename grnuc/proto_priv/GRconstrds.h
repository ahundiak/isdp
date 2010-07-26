#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRconstrds.I */
extern IGRint GRconstruct_ds __((IGRlong *msg, struct GRmd_env *mod_env, IGRshort level, struct IGRdisplay *display, IGRushort properties, IGRchar name[], IGRint proj_angle, IGRdouble sheet_size_x, IGRdouble sheet_size_y, struct GRevent *origin_event, IGRint border_type, IGRchar border_file[], IGRchar border_name[], IGRchar desc[], struct GRid *ds_id));

#if defined(__cplusplus)
}
#endif


#undef __
