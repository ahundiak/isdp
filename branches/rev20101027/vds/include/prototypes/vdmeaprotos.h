/* $Id: vdmeaprotos.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/vdmeaprotos.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdmeaprotos.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/11/08  21:55:32  pinnacle
 * Created: include/prototypes/vdmeaprotos.h by v241_int for vds.241
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 ***************************************************************************/


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

/* cmd/VDmeasCmdi.I */

/* cmd/VDmeasOver.I */

/* func/VDdynmeas.I */
IGRint VDrasdisp __((struct VDdynInfo *dynm_data, struct EX_button *pnt2, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *inflag1, IGRchar *inflag2, IGRchar *inflag3, IGRint *outflag4, IGRchar **outflag5, IGRchar **outflag6));
IGRlong VDrbrasdisp __((IGRshort *num_entries, IGRshort *offset_array, IGRchar **string_array, struct disp_val_info *disp_va_inf, struct IGRbsp_curve *Crv));
IGRlong VDdisp_triad1 __((IGRlong *msg, struct EX_button *pnt2, IGRint xdit, IGRint ydit));
IGRlong VDdisp_triad2 __((IGRlong *msg, struct EX_button *pnt2, IGRint xdit, IGRint ydit));
IGRlong VDdisp_line __((IGRlong *msg, struct VDdynInfo *dyn, struct EX_button *pnt, IGRdouble *mtx));
IGRlong VDdisp_hdr __((IGRlong *msg, struct EX_button *pnt2, IGRint xdit, IGRint ydit, int val));

/* func/Windows.I */
IGRlong VDgetDefaultView __((IGRlong *msg, GRspacenum ActiveOs, struct GRid *win));

/* imp/Measure.I */
IGRlong VDminimumDistance __((IGRlong *msg, struct VDmeasure *Meas));
IGRlong VDfillPlaneObject __((IGRlong *msg, struct GRobj_env *Obj1, struct GRobj_env *Obj2, struct VDcollector *Tpl));
IGRlong VDinterPlanObjects __((IGRlong *msg, IGRint num, struct GRobj_env Obj[], struct GRobj_env *Pln, struct GRobj_env Mac[]));
IGRlong VDfillSuppObject __((IGRlong *msg, struct GRobj_env *Obj1, struct GRobj_env *Obj2, struct VDcollector *Tpl));
IGRlong VDinterSuppObjects __((IGRlong *msg, IGRint num, struct GRobj_env Obj[], struct GRobj_env *Sup, struct GRobj_env Mac[]));
IGRlong VDgetIntersections __((IGRlong *msg, IGRint num, struct GRobj_env Mac[], struct GRobj_env Int[]));
IGRlong VDprojectPoints __((IGRlong *msg, IGRdouble *Pnt1, IGRdouble *Pnt2, struct GRobj_env *Srf, IGRdouble *Prj1, IGRdouble *Prj2));
IGRlong VDorthoPlan __((IGRlong *msg, struct GRobj_env *Srf, IGRdouble *Spt, IGRdouble *Ept, struct GRobj_env *Pln));
IGRlong VDgetCurveLength __((IGRlong *msg, struct GRobj_env *Curv, IGRdouble *Spnt, IGRdouble *Epnt, IGRdouble *Dist));
IGRlong VDfreeDistance __((IGRlong *msg, struct VDmeasure *Meas));
IGRlong VDmeasureLineCurve __((IGRlong *msg, struct VDmeasure *Meas, struct GRobj_env *Curv));
IGRlong VDcomputeDistance __((IGRlong *msg, struct VDmeasure *Meas));
IGRlong VDprepareDistance __((IGRlong *msg, struct GRobj_env *Obj1, struct GRobj_env *Obj2, struct GRobj_env *Obj3, struct GRobj_env *Obj4, IGRdouble *Pnt1, IGRdouble *Pnt2, struct GRid *Win1, struct GRid *Win2, struct VDmeasure *Meas));
IGRlong VDmeasureDistance __((IGRlong *msg, struct GRobj_env *Obj1, struct GRobj_env *Obj2, struct GRobj_env *Obj3, struct GRobj_env *Obj4, IGRdouble *Pnt1, IGRdouble *Pnt2, IGRdouble *Dist, IGRdouble *Spnt, IGRdouble *Epnt));

#if defined(__cplusplus)
}
#endif

