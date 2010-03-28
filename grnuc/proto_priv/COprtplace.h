#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtplace.I */
extern IGRint COpart_place_func __((IGRint *msg, struct GRmd_env *mod_env, struct GRevent *origin_event, struct GRdpb_scale *scale, IGRdouble *angle, IGRshort *level, struct GRid *part, IGRint *num));
extern IGRint COpart_get_parts_in_cell __((struct GRid *cl_id, struct GRid *part, IGRint *num));

#if defined(__cplusplus)
}
#endif


#undef __
