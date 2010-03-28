#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COpjptvwpl.I */
extern IGRboolean COproj_pt_to_view_pl __((IGRlong *msg, struct GRevent *event, IGRdouble *projected_point));
extern IGRboolean CO_ni_world_to_view __((IGRlong *ReturnMsg, struct GRevent *Event, struct GRid *ViewGrid, IGRpoint ViewPoint));

#if defined(__cplusplus)
}
#endif


#undef __
