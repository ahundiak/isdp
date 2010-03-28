#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dp3Ddatapt.C */
extern IGRint DPdyn3dpt __((struct pt3d *add_info, struct EX_button *button, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *in_flags, IGRchar *in_dum2, IGRchar *in_dum3, IGRint *out_flags, IGRchar **out_dum2, IGRchar **out_dum3));
extern IGRint DP3Ddatapt __((IGRdouble *pnts, IGRchar first_pnt, struct IGRline *brline1));

#if defined(__cplusplus)
}
#endif


#undef __
