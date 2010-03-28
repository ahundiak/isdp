#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRmakegs.I */
extern IGRlong GRmake_graphic_set __((IGRlong *msg, IGRint nobjs, struct GRlc_info *objs, OMuword osnum, struct GRid *grset));

#if defined(__cplusplus)
}
#endif


#undef __
