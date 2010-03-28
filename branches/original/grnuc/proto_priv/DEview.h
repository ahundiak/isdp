#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEview.I */
extern int DEref_view_recalled __((long *msg, struct GRid *ref_id, struct GRid *win_id));

#if defined(__cplusplus)
}
#endif


#undef __
