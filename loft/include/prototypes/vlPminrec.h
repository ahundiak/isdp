#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLminRecFunk.I */
IGRlong VLminRectangle __((struct GRid *Iobj, struct GRmd_env *Ienv, struct GRvg_construct *cst, IGRint but, IGRdouble rat, IGRdouble margin, IGRdouble *Len, IGRdouble *Wid, struct GRid *frm_id, struct GRid *txt_id, IGRlong *msg));
IGRlong VLcomputeCdg __((IGRint npts, IGRdouble pts[], IGRdouble cdg[]));
IGRlong VLinertia __((IGRdouble points[], IGRint npts, IGRdouble rat, IGRdouble cdg[], IGRdouble range[], IGRdouble pts[], IGRdouble *L, IGRdouble *W, IGRboolean *circle));
IGRlong VLstroke __((IGRdouble points[], IGRint npts, IGRdouble rat, IGRdouble range[], IGRdouble pts[], IGRdouble *L, IGRdouble *W, IGRboolean *circle));
IGRlong VLleastSquare __((IGRdouble points[], IGRint npts, IGRdouble rat, IGRdouble range[], IGRdouble pts[], IGRdouble *L, IGRdouble *W, IGRboolean *circle));
IGRboolean VLcheckAln __((IGRdouble *pt, IGRdouble *org, IGRdouble *dir));
void VLxyMinMax __((IGRint n, IGRdouble pt[], IGRdouble a, IGRdouble b, IGRdouble x0, IGRdouble y0, IGRdouble *xmin, IGRdouble *ymin, IGRdouble *xmax, IGRdouble *ymax));
void VLcomputeRng __((IGRdouble pt[], IGRint npt, IGRdouble p[], IGRdouble q[], IGRdouble rat, IGRdouble range[], IGRdouble box[], IGRdouble *l, IGRdouble *w, IGRboolean *circle));
IGRlong VLrectMargin __((IGRint npt, IGRdouble pts[], IGRdouble margin, IGRlong *msg));

#if defined(__cplusplus)
}
#endif

