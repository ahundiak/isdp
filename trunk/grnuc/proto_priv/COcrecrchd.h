#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/COcrecrchd.C */
extern IGRlong CO_create_circle_tan_chord __((IGRlong *msg, struct IGRbsp_curve *bspline_ptr, IGRdouble *active_angle, IGRdouble *distance, IGRdouble *tanpoint, IGRdouble *uparm, IGRdouble *RotationMatrix, IGRpoint arcept, IGRboolean ccw, struct IGRbsp_curve *circle));

#if defined(__cplusplus)
}
#endif


#undef __
