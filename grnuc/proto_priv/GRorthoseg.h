#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRorthoseg.c */
extern IGRboolean GRorthoseg __((IGRlong *msg, IGRpoint point1, IGRpoint point2, IGRpoint point3, IGRpoint out_point));

#if defined(__cplusplus)
}
#endif


#undef __
