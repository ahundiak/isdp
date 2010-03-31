class implementation GRcurve;

#include <stdio.h>
#include <math.h>
#include <alloca.h>

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"


#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igr.h"

#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "EMSmsgdef.h"

#include "bsgeom_cvsf.h"
#include "bscvtgeomcv.h"
#include "PWapi/cvtype.h"
#include "PWapi/objdel.h"
#include "PWapi/cvcons.h"

PWobjid  pwCreateCvObj
(
  struct PWcvdata  *p_cvdata,
  PWosnum  os
)
{
  int OMsts=OM_S_SUCCESS;
  long OMmsg=EMS_S_Success;
  enum PWcvdatatype datatype=PWcvdata_null;
  struct GRvg_construct  constargs;
  PWclassid cvclass=0;
  PWobjid cvobj=PW_K_NullObjid;
  PWresult PWsts = PW_K_Success;
  struct GRmd_env obj_md_env;
  struct IGRdisplay disp_attrib;
  PWboolean stat = 0;

  extern  PWclassid    OPP_GR3dpoint_class_id,
                       OPP_GR3dlineseg_class_id,
                       OPP_GR3dlinestr_class_id;

  datatype = p_cvdata->datatype;

  /*
   * Validate the incoming arguments
   */
  if ((datatype == PWcvdata_pt2d) ||
      (datatype == PWcvdata_py2d) ||
      (datatype == PWcvdata_null))
  {
    OnErrorState( TRUE, PWsts, SetError( PW_K_Pathway, PW_K_Error), wrapup);
  }

  EMinitvgcnstr (&OMmsg, &obj_md_env, &disp_attrib, NULL, &constargs);
  stat = EMgetvgcnstr (NULL, NULL, NULL, DEFAULT_GR_LEVEL, NULL, NULL,NULL,
            &constargs);
  OnErrorState( !stat, PWsts, SetError( PW_K_Pathway, PW_K_Error), wrapup);
 
  switch (datatype)
  {
    case PWcvdata_pt:
    case PWcvdata_py:
    {
      struct IGRpolyline polyline;

      /*
       * Construct a GR3dpoint object and post the geometry into
       * its instance data.
       */
      if (datatype == PWcvdata_pt)
      {
        polyline.num_points = 1;
        polyline.points = p_cvdata->data.pt;
        cvclass = OPP_GR3dpoint_class_id;
      }
      else
      {
        polyline.num_points = p_cvdata->data.py.num_pts;
        polyline.points = (double *)(p_cvdata->data.py.p_pts);
        if (polyline.num_points == 2)
          cvclass = OPP_GR3dlineseg_class_id;
        else
          cvclass = OPP_GR3dlinestr_class_id;
      }

      constargs.geometry = (IGRchar *) &polyline;
      OMsts = om$construct (msg = message GRgraphics.GRaltconstruct (
                                          &constargs), classid = cvclass, 
                            osnum = os, p_objid = &cvobj);
      constargs.geometry = NULL;
      OnErrorCode ((OMsts & OMmsg), wrapup);
    }
    break;

    case PWcvdata_bspcv:
    {
      struct BSgeom_bsp_curve geom_bspcv;
      BSrc rc=BSSUCC;
      double  arcdata[38];
      struct IGRbsp_curve arc;

      memset (&geom_bspcv, 0, sizeof (struct BSgeom_bsp_curve));
      geom_bspcv.type = BSGEN_BSP_CV;

      /*
       * Get the geometric properties of the incoming bspline curve
       */
      if (p_cvdata->data.p_bspcv->order == 3)
      {
        short arc_ind=0;
        PWpoint center;
        double radius=0;

        arc.poles = &arcdata[0];
        arc.knots = &arcdata[21];
        arc.weights = &arcdata[31];

        BStstcvfarc (p_cvdata->data.p_bspcv, &arc_ind, center, &radius, &arc,
                     &rc);
        OnErrorState (BSERROR (rc), cvobj, PW_K_NullObjid, wrapup);
      
        geom_bspcv.bspcv = &arc;  
        if (arc_ind == 1)
          geom_bspcv.type = BSCIRC_ARC;
        else if (arc_ind == 2)
          geom_bspcv.type = BSCIRCLE;
      }

      if (geom_bspcv.type != BSCIRC_ARC &&  geom_bspcv.type != BSCIRCLE)
      {
        geom_bspcv.bspcv = p_cvdata->data.p_bspcv;
        geom_bspcv.type = (geom_bspcv.bspcv->order == 3) ? BSCIRC_ARC : 
                                                           BSGEN_BSP_CV;
        BScvtgeomcv (&geom_bspcv, &geom_bspcv, &rc);
        OnErrorState ((rc != BSUNMATCHEDTYPES) && BSERROR (rc), cvobj,
                      PW_K_NullObjid, wrapup);
      }

      cvclass = pwCvClassid (geom_bspcv.type);

      constargs.geometry = (IGRchar *) geom_bspcv.bspcv;
      OMsts = om$construct (msg = message GRcurve.GRconstruct (&constargs),
                            classid = cvclass, osnum = os, p_objid = &cvobj);
      constargs.geometry=NULL;
      OnErrorCode ((OMsts & OMmsg), wrapup);
    }
    break;

    case PWcvdata_gmbspcv:
    {
      cvclass = pwCvClassid (p_cvdata->data.p_gmbspcv->type);

      constargs.geometry = (IGRchar *)p_cvdata->data.p_bspcv;
      OMsts = om$construct (msg = message GRcurve.GRconstruct (&constargs),
                            classid = cvclass, osnum = os, p_objid = &cvobj);
      constargs.geometry=NULL;
      OnErrorCode ((OMsts & OMmsg), wrapup);
    }
    break;

    default:
    break;
  }

wrapup:

  if (IsError (OMsts & OMmsg) && cvobj != PW_K_NullObjid)
  {
    omDeleteObject (cvobj, os);
    cvobj = PW_K_NullObjid;
  }
  return  cvobj;
}

end implementation GRcurve;
