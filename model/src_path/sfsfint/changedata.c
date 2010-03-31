/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "OMminimum.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "bsgeom_cvsf.h"
#include "msdef.h"
#include "ma.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"


/* Prototypes */
#include "maidmx.h"

#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "igrdp.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"

#include "EMSpwapi.h"

#include "PWapi/sfgeom.h"
#include "PWapi/edgeom.h"
#include "PWapi/cvgeom.h"
#include "PWapi/clsid.h"


/* Externs */

extern  OMuword   OPP_GRcurve_class_id;



PWresult  pwChangeEMSCvdata
(
  struct EMSdataselect *p_datasel,
  struct PWcvdata      *p_cvdata,
  short                mattyp,
  PWmatrix             p_mat,
  PWboolean            *p_allocated
)
{
  PWresult               retval;
  PWclassid              classid;
  PWobjid                loc_objid;
  PWosnum                os;
  PWboolean              is_curve=FALSE;
  struct IGRbsp_curve    *p_cvgeom=NULL;

  retval = PW_K_Success;

  switch (p_datasel->datatype)
  {
    case EMSdata_object:
      loc_objid = p_datasel->data.object->objid;
      os = p_datasel->data.object->osnum;
      classid = omClassidFromObjid (loc_objid, os);
      OnErrorState (classid == PW_K_NullClass, retval,
       SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

      /*
       * Check if it is a curve object
       */
      is_curve = omIsAncestryValid (classid, OPP_GRcurve_class_id);
      if (is_curve)
      {
        /*
         * Get the curve geometry
         */
        retval = PW_GetCvBspcvHeap (loc_objid, os, mattyp, p_mat, p_cvgeom);
        OnErrorCode (retval, wrapup);
        p_cvdata->datatype = PWcvdata_bspcv;
        p_cvdata->data.p_bspcv = p_cvgeom;
        *p_allocated = TRUE;
      }
      else
      {
        /*
         * This is an edge object. So get its logical geometry
         */
        retval = PW_GetEdGeomHeap (loc_objid, os, (*p_cvdata));
        OnErrorCode (retval, wrapup);
        *p_allocated = TRUE;
      }
      break;
    case EMSdata_poly2d:
    case EMSdata_poly3d:
    case EMSdata_curve3d:
      /*
       * Call the conversion routine from EMSdataselect to PWcvdata structure
       * This routine does not allocate any memory for PWcvdata structure.
       * PWcvdata pointer members just point to the geometry contained in 
       * EMSdataselect structure.
       */
      pwCnvtEMSCvdata (p_datasel, p_cvdata);
      break;
    default :
      p_cvdata->datatype = PWcvdata_null;
  }/* end of switch */
  wrapup:
  return (retval);
}/* end of function pwChangeEMSCvdata */


void pwFreeCvdata
(
  struct PWcvdata *cvdata
)
{
  switch (cvdata->datatype)
      {
        case PWcvdata_py2d:
          free (cvdata->data.py2d.p_pts);
          break;
        case PWcvdata_py:
          free (cvdata->data.py.p_pts);
          break;
        case PWcvdata_bspcv:
          free (cvdata->data.p_bspcv);
          break;
        case PWcvdata_gmbspcv:
          free (cvdata->data.p_gmbspcv->bspcv);
          free (cvdata->data.p_gmbspcv);
          break;
        default:
          break;
      }/* end of switch */
}/* end of function pwFreeCvdata */
 
