#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUrangeupd.I */
extern IGRboolean GUrangeupdate __((GRobjid *objid, struct GRmd_env *env));

#if defined(__cplusplus)
}
#endif


#undef __
