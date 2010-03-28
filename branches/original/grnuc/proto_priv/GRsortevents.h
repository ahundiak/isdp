#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRsortevents.c */
extern IGRboolean GRsort_events __((IGRlong *msg, IGRshort *event_types, IGRshort *num_events, IGRshort *total, IGRshort *ordered_types, IGRshort *order));

#if defined(__cplusplus)
}
#endif


#undef __
