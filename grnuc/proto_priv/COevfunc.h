#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/eventsco/COevfunc.I */
extern IGRlong COev_pt_angle_from __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_angle_to __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_center __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_end __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_intersection __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_key __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_mid __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_project __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_perpendicular_from __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_perpendicular_to __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_tangent_from __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_tangent_to __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));
extern IGRlong COev_pt_tentative_key __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));

#if defined(__cplusplus)
}
#endif


#undef __
