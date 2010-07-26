#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRdetpoint.I */
extern IGRlong GRdetpoint __((IGRlong *msg, struct GRid *objid, IGRshort *mat_type, IGRdouble *matrix, struct IGRline *line, IGRboolean *ortho, IGRpoint point));

#if defined(__cplusplus)
}
#endif


#undef __
