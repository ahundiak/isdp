#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetattach.I */
extern IGRint GRgetattachment __((IGRlong *msg, struct GRid *objid, IGRchar *info));

#if defined(__cplusplus)
}
#endif


#undef __
