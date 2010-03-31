/*
  OVERVIEW

  This file consists of functions related to typing a given Curve Entity.


  HISTORY

  SS    : 05/31/95  :  Creation
*/

class implementation GRcurve;

#include "bsgeom_cvsf.h"

#include "emsedgedef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/cvtype.h" 
#include "PWapi/objaccess.h"
#include "PWapi/clsid.h"

extern PWclassid OPP_GRcompcurve_class_id, OPP_GRbspline_class_id;

/*
  ABSTRACT

  Functions to test if the given object is a curve-entity or more 
  specifically, a composite curve or a simple curve (3 functions).
*/

PWboolean pwIsCurve
(
  PWobjid  cvobj,
  PWosnum  cvos
)
{
  return (omIsAncestryValid (omClassidFromObjid (cvobj, cvos), 
           OPP_GRcurve_class_id));
}

PWboolean pwIsCompCv
(
  PWobjid  cvobj,
  PWosnum  cvos
)
{
  return (omIsAncestryValid (omClassidFromObjid (cvobj, cvos), 
           OPP_GRcompcurve_class_id));
}

PWboolean pwIsSimpleCv
(
  PWobjid  cvobj,
  PWosnum  cvos
)
{
  return (omIsAncestryValid (omClassidFromObjid (cvobj, cvos), 
           OPP_GRbspline_class_id));
}

/*
  ABSTRACT
 
  This function returns the EMS type of this curve, given the BS type.
  It is simply a map from one system to another.

  NOTES

  None. 
*/

char pwEMSCvType
(
  short bstype
)
{
  if (bstype == BSPOINT)
    return (EMpoint);
  else if (bstype == BSLINE)
    return (EMlinesegment);
  else if (bstype == BSCIRCLE)
    return (EMcircle);
  else if (bstype == BSELLIPSE)
    return (EMellipse);
  else if (bstype == BSCIRC_ARC)
    return (EMcircular_arc);
  else if (bstype == BSELLIP_ARC)
    return (EMelliptical_arc);
  else if (bstype == BSINF_LINE)
    return (EMinfinite_line);
  else
    return (EMfreeform_curve);
}

/*
  ABSTRACT

  Given the curve type defined by BS, it returns the class of the curve object
  to create.

  NOTES

  Refer to "$BS/include/bsgeom_cvsf.h" for valid BS curve types.
*/
 
PWclassid pwCvClassid
(
  short cvtype
)
{
  PWclassid cvclass=0;
  extern  PWclassid  OPP_GR3dpoint_class_id,
                     OPP_GR3dlineseg_class_id,
                     OPP_GR3dcircle_class_id,
                     OPP_GR3dellipse_class_id,
                     OPP_GR3dcirarc_class_id,
                     OPP_GRbcsubbc_class_id,
                     OPP_GR3dinfline_class_id,
                     OPP_GR3dlinestr_class_id,
                     OPP_GR3dellarc_class_id;

  switch (cvtype)
  {
    case BSPOINT:
      cvclass = OPP_GR3dpoint_class_id;
      break;
    case BSLINE:
      cvclass = OPP_GR3dlineseg_class_id;
      break;
    case BSCIRCLE:
      cvclass = OPP_GR3dcircle_class_id;
      break;
    case BSELLIPSE:
      cvclass = OPP_GR3dellipse_class_id;
      break;
    case BSCIRC_ARC:
      cvclass = OPP_GR3dcirarc_class_id;
      break;
    case BSELLIP_ARC:
      cvclass = OPP_GR3dellarc_class_id;
      break;
    case BSINF_LINE:
      cvclass = OPP_GR3dinfline_class_id;
      break;
    case BS3DLINESTR:
      cvclass = OPP_GR3dlinestr_class_id;
      break;
    default:
      cvclass = OPP_GRbcsubbc_class_id;
      break;
  }

  return (cvclass);
}  

end implementation GRcurve;
