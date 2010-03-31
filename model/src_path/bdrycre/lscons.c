/* Includes */

#include "OMminimum.h"
#include "OMerrordef.h"

#include "emsdef.h"

#include "PWminimum.h"            /* Pathway */
#include "PWgmdata.h"
#include "PWerror.h"

/* Prototypes */

#include "PWapi/lscons.h"
#include "PWapi/objcons.h"
#include "objconn.h"
#include "PWapi/objdel.h"        /* Pathway */
#include "PWapi/edprops.h"
#include "PWapi/lpprops.h"

/* Externs */

extern PWclassid OPP_EMSloopset_class_id;

/*
  ABSTRACT

  NOTES
*/

PWobjid pwCreateLoopset
(
  PWobjid sfobj,
  PWosnum os
)
{
  PWresult PWsts=PW_K_Success; 
  PWobjid lsobj = PW_K_NullObjid;

  lsobj = omCreateObjFromClassid (os, OPP_EMSloopset_class_id);
  OnErrorState ((lsobj == PW_K_NullObjid), PWsts, SetError (PW_K_Pathway, 
                PW_K_Internal), wrapup);
 
  if (sfobj != PW_K_NullObjid)
  {
    OM_S_CHANSELECT to_loopset, to_surface; 

    EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
    EMmake_chanselect (EMSloopset_to_surface, &to_surface);

    PWsts = omConnectObjectAtIndex (sfobj, os, &to_surface, 0, lsobj, os, 
                                    &to_loopset, 0);
    OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Pathway,
                  PW_K_InvalidArg), wrapup);
  }
 
wrapup : 

  PW_Wrapup (PWsts, "pwCreateLoopset");

  if (IsError (PWsts))
  {
    if (lsobj != PW_K_NullObjid)
    {
      omDeleteObject (lsobj, os);
    }

    return PW_K_NullObjid;
  }
  else
    return lsobj;
}

