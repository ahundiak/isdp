#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/COlnangvw.C */
extern IGRlong COline_at_angle_in_view __((IGRlong *ReturnMsg, struct GRevent *Events[], IGRdouble *Angle, struct IGRbsp_curve *AbstractGeometry));

#if defined(__cplusplus)
}
#endif


#undef __
