#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COniman3pt.I */
extern IGRlong CO_ni_measure_angle_by_3_pts __((IGRlong *msg, struct GRevent *events[], IGRdouble *Angle, IGRchar *units));

#if defined(__cplusplus)
}
#endif


#undef __
