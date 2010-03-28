#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRget2objgeo.I */
extern IGRboolean GRget2objgeom __((IGRlong *msg, struct GRid *obj1, struct GRmdenv_info *env1, IGRboolean *ex1, struct GRid *obj2, struct GRmdenv_info *env2, IGRboolean *ex2, IGRchar *buf1, IGRchar *buf2, IGRlong *s1, IGRlong *s2, IGRchar **ptr1, IGRchar **ptr2, struct GRprops *props1, struct GRprops *props2));

#if defined(__cplusplus)
}
#endif


#undef __
