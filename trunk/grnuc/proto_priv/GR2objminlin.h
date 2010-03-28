#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GR2objminlin.C */
extern IGRboolean GR2objminline __((IGRlong *msg, struct GRid *obj1, struct GRmdenv_info *env1, struct GRparms *parms1, struct GRid *obj2, struct GRmdenv_info *env2, struct GRparms *parms2, IGRboolean *loc_global, IGRboolean *app_flag, IGRpoint pl_pt, IGRvector view, IGRpoint point, struct IGRline *line));

#if defined(__cplusplus)
}
#endif


#undef __
