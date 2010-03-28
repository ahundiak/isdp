#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRsetarc.c */
extern IGRboolean GRsetarc __((IGRlong *msg, IGRshort *dim, IGRdouble *prim, IGRdouble *sec, IGRdouble *st_ang, IGRdouble *sw_ang, IGRdouble *rot, IGRdouble *org, IGRdouble *org_z, struct IGRarc *arc));

#if defined(__cplusplus)
}
#endif


#undef __
