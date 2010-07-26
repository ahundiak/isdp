#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COnims2pt.C */
extern IGRlong CO_ni_measure_distance_btwn_2pts __((IGRlong *ReturnMsg, struct GRevent *Events[], IGRdouble *Distance, IGRchar *Units));

#if defined(__cplusplus)
}
#endif


#undef __
