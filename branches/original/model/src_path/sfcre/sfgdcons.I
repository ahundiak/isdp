/*
  DESCRIPTION

  The following function creates the helper-display object that is used
  in correctly displaying the rule-lines for a surface, clipped to the
  boundaries. There is one such helper object for every face (P-loop)
  on this surface. 


  NOTES

  If the surface is a natural surface, ie, the boundaries represent the 
  entire UV-domain, then there is no need for such a helper-display object
  and none is created.

  The clip-points for the rule-lines are not generated at this time, but
  generated the first time the surface is asked to display itself.

  HISTORY

  SS  :  09/25/95  :  Creation
*/

class implementation EMSgradata;

#include "emsdef.h"
#include "EMSopt.h"
#include "EMSfrtdef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sflp.h"
#include "PWapi/objcons.h"
#include "PWapi/sfprops.h"
#include "PWapi/lpprops.h"

extern PWclassid OPP_EMSgradata_class_id;

PWresult pwCreateSfDispObj
(
  PWobjid sfobj,
  PWosnum os
)
{
  int num_faces=0, i=0;
  long msg_loc=OM_S_SUCCESS;
  PWresult result=PW_K_Success;
  PWobjid *p_faces=NULL, grad=PW_K_NullObjid;
  OM_S_CHANSELECT chan_req_to_grad, chan_grad_to_req;

  if (!pwIsSfNatural (sfobj, os))
  {
    EMmake_chanselect (EMSrequester_to_helpers, &chan_req_to_grad);
    EMmake_chanselect (EMShelper_to_requesters, &chan_grad_to_req);

    num_faces = pwNumFacesOfSf (sfobj, os);

    p_faces = (PWobjid *) alloca (num_faces * sizeof (PWobjid));
    OnErrorState (!p_faces, result, PW_K_DynamicMemory, wrapup);

    pwFacesOfSf (sfobj, os, p_faces);

    for (i=0; i<num_faces; i++)
    {
      grad = omCreateObjFromClassid (os, OPP_EMSgradata_class_id);
      OnErrorState (grad == PW_K_NullObjid, result, PW_K_Error, wrapup);

      result = om$send (msg = message Root.connect (chan_req_to_grad, 0, 
                grad, os, chan_grad_to_req, MAXINT),
                targetid = sfobj, targetos = os, senderid = NULL_OBJID);
      OnErrorCode (result, wrapup);

      result = om$send (msg = message Root.connect (chan_req_to_grad, 1, 
                grad, os, chan_grad_to_req, MAXINT),
                targetid = p_faces[i], targetos = os, senderid = NULL_OBJID);
      OnErrorCode (result, wrapup);

      result = om$send (msg = message EMShelper.EMset_props (&msg_loc, 
                EMGD_NONNATURAL, EMS_O_ON), 
                targetid = grad, targetos = os, senderid = NULL_OBJID);
      OnErrorCode (result, wrapup);
    }
  }

wrapup:
  PW_WrapupId (result, "pwCreateSfDispObject", sfobj);
  return (result);
}

end implementation EMSgradata;
