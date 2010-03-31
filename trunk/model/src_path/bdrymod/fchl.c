/* Includes */

#include "OMminimum.h"
#include "OMerrordef.h"

#include "emsdef.h"

#include "PWminimum.h"            /* Pathway */
#include "PWerror.h"
#include "PWgmdata.h"

/* Prototypes */

#include "PWapi/fchl.h"
#include "PWapi/sflp.h"
#include "objconn.h"
#include "PWapi/lpprops.h"

PWresult pwAddHolesToFace
(
  PWosnum os,
  PWobjid face,
  int num_holes,
  PWobjid *p_holes
)
{ 
  PWresult PWsts=PW_K_Success;
  int num_exists=0, i=0, num_connected=0;
  OM_S_CHANSELECT to_inner, to_outer;

  EMmake_chanselect (EMSloop_to_inner, &to_inner); 
  EMmake_chanselect (EMSloop_to_outter, &to_outer); 

  num_exists = pwNumHolesOfFace (face, os);
 
  for (i=0; i<num_holes; i++)
  { 
    PWsts = omConnectObjectAtIndex (face, os, &to_outer, (i+num_exists), 
                                    p_holes[i], os, &to_inner, 0);
    OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Pathway, 
                  PW_K_Internal), wrapup);
  }

  if (pwIsLpNatural (face, os))
    pwUnsetLpNatural (face, os);

wrapup :
  if (1&PWsts)
  {
    for (i=0; i<num_holes; i++)
    {
      pwSetLpActive (p_holes[i], os);
    }
  }

  num_connected = i;
  if (IsError (PWsts) && num_connected)
  {
    for (i=0; i<num_connected; i++)
      omDisconnectObject (face, os, &to_inner, p_holes[i], os, &to_outer);
  }  

  return PWsts;
}
