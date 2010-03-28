#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRprerout.c */
extern IGRboolean GRprerout __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, IGRshort *max_id, IGRshort *max_val, struct GRrtevent *rtevents));

#if defined(__cplusplus)
}
#endif


#undef __
