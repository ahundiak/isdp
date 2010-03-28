#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COnspolyc.C */
extern IGRlong COnpolygonConstruct __((IGRlong *msg, IGRdouble *RotationMatrix, IGRdouble *CenterPoint, IGRdouble *EdgePoint, IGRlong *NumberOfSides, IGRdouble *PointArray));

#if defined(__cplusplus)
}
#endif


#undef __
