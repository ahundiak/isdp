#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPdyplane.C */
extern int DPdyplane __((IGRlong *msg, IGRdouble radius, IGRdouble distance, IGRdouble *pts, IGRdouble *matrix));

#if defined(__cplusplus)
}
#endif


#undef __
