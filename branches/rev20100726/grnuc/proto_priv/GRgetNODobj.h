#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRgetNODobj.I */
extern IGRint GRget_NOD_object __((IGRlong *msg, uword osnum, GRobjid *objid));

#if defined(__cplusplus)
}
#endif


#undef __
