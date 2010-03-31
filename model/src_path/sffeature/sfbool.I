/*
  DESCRIPTION

  These APIs perform the Boolean operations between two surface entities 
  (typically, solids). The two entities must produce closed intersection 
  curves. The result of the Boolean operation is output in the object --
  'union_sf' or 'difference_sf' or 'intersection_sf' or 'cut_sf'. The object
  is of the class -- "EMSsfboolean" or "EMSslboolean". Optionally, the caller
  may have the function construct this object by passing in the output
  object-id as PW_K_NullObjid. 

  All the current environment settings are honored for the operation:
  1) cht and bastol
  2) level
  3) Pathway ON/OFF setting -- if this does not make sense, ignore.


  NOTES

  The output object from these APIs are constructed while "consuming" the two
  input operands. If any one of the operands is not a solid, the resultant
  object is not a solid. When the caller passes in the output object, the
  correct class is checked for. If found incorrect, the API returns with
  an error code.

   
  HISTORY

  SS  :  06/19/95  :  Creation
*/

class implementation EMSsfboolean;

#include <alloca.h>

#include "igrtypedef.h"
#include "igr.h"

#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"

#include "gr.h"
#include "godef.h"
#include "go.h"
#include "igrdp.h"
#include "emsbool.h"
#include "emssfintdef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "PWapi/sfbool.h"
#include "PWapi/sftype.h"
#include "PWapi/mx.h"

%safe
static PWresult sf_boolean
(
  PWobjid,
  PWobjid,
  PWosnum,
  enum EMSbooltype,
  PWboolean,
  PWobjid *
);
%endsafe

extern PWclassid OPP_EMSsfboolean_class_id;
extern PWclassid OPP_EMSslboolean_class_id;

PWresult pwSfBooleanUnion
(
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *union_sf
)
{
  return (sf_boolean (sf1, sf2, os, EMSbool_union, is_interactive, union_sf));
}

PWresult pwSfBooleanDifference
(
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *difference_sf
)
{
  return (sf_boolean (sf1, sf2, os, EMSbool_difference, is_interactive, 
           difference_sf));
}

PWresult pwSfBooleanIntersection
(
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *intersection_sf
)
{
  return (sf_boolean (sf1, sf2, os, EMSbool_intersect, is_interactive, 
           intersection_sf));
}

/* ARGSUSED */
PWresult pwSfCutWithPlane
(
  PWobjid sf,
  struct PWplane *plane,
  PWosnum os,
  PWboolean is_interactive,
  PWobjid *cut_sf
)
{
  return (PW_K_Error);
}

/*----------------- STATIC FUNCTION DEFINITIONS ----------------------------*/

static PWresult sf_boolean
(
  PWobjid sf1,
  PWobjid sf2,
  PWosnum os,
  enum EMSbooltype booltype,
  PWboolean is_interactive,
  PWobjid *boolean_sf
)
{
  char status_str[PW_K_MaxCharOnLine+1], *p_status_str=NULL;
  unsigned short options=NULL;
  short mxtype=MAIDMX;
  long msg_loc=TRUE, vg_msg=TRUE;
  PWclassid boolean_classid=PW_K_NullClass;
  PWresult result=PW_K_Success;
  PWmatrix idmx;
  struct GRmd_env md_env;
  struct IGRdisplay display;
  struct GRvg_construct vg_construct;

  /*
   * Constuct the empty Boolean solid/surface if not passed in.
   */

  if (pwIsSolid (sf1, os) && pwIsSolid (sf2, os))
    boolean_classid = OPP_EMSslboolean_class_id;
  else
    boolean_classid = OPP_EMSsfboolean_class_id;

  if (*boolean_sf == PW_K_NullObjid)
  {
    result = om$construct (classid = boolean_classid, p_objid = boolean_sf,
              osnum = os);
    OnErrorCode (result, wrapup);
  }
  else
  {
    OnErrorState (omClassidFromObjid (*boolean_sf, os) != boolean_classid,
     result, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  /*
   * Perform the Boolean operation. 
   */

  pwIdMx (idmx);
  EMinitvgcnstr (&vg_msg, &md_env, &display, NULL, &vg_construct);
  EMgetvgcnstr (NULL, NULL, NULL, DEFAULT_GR_LEVEL, NULL, NULL, NULL,
   &vg_construct);

  if (is_interactive)
  {
    strcpy (status_str, "Processing");
    p_status_str = status_str;
    options |= EMSsfbool_opt_display | EMSsfbool_opt_HandleStop;
  }

  result = om$send (msg = message EMSsfboolean.EMjoiningBoolean (&msg_loc,
            &mxtype, idmx, sf1, 1, &sf2, &vg_construct, booltype, options,
            p_status_str, NULL, NULL, NULL, NULL), 
            targetid = *boolean_sf, targetos = os, senderid = *boolean_sf);
  OnErrorState (IsError (result & msg_loc), result, PW_K_Error, wrapup);
  result = PW_K_Success;

wrapup:
  PW_WrapupIdId (result, "sf_boolean", sf1, sf2);
  return (result);
}

end implementation EMSsfboolean;
