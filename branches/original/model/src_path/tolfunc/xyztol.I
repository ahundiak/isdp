class implementation Root;

#include "bserr.h"
#include "bsparameters.h"
#include "igrtypedef.h"
#include "igr.h"
#include "grdpbdef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/xyztol.h"
#include "PWapi/objaccess.h"

from GRdpb import GRget;

/*
  DESCRIPTION
 
  This function returns the current, active zero length tolerance in the
  XYZ space. This value is the value stored in the global that is expected to
  be initialized every time a design file is opened. The initial value of this
  global is the value stored within the file. It can be manipulated later in 
  the session and may end up looking distinct from the value that is 
  persistently stored.
*/

double pwActiveXYZLenTol
(
)
{
  long rc;
  double active_lentol;

  BSEXTRACTPAR (&rc, BSTOLLENVEC, active_lentol);

  return (active_lentol);
}


/*
  DESCRIPTION
 
  This function returns the current, active chordal-height tolerance in the
  XYZ space. This value is the value stored in the global that is expected to
  be initialized every time a design file is opened. The initial value of this
  global is the value stored within the file. It can be manipulated later in 
  the session and may end up looking distinct from the value that is 
  persistently stored.
*/

double pwActiveXYZChtTol
(
)
{
  long rc;
  double active_chttol;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, active_chttol);

  return (active_chttol);
}

/*
  DESCRIPTION
 
  This function sets the current, active zero length tolerance in the
  XYZ space. The value stored in the global is what gets changed by this
  function. Note that this will NOT cause this new tolerance to be stored
  persistently with the file.
*/

void pwSetActiveXYZLenTol
(
  double newtol
)
{
  long rc;

  BSchangepar (&rc, BSTOLLENVEC, newtol);

  return;
}

/*
  DESCRIPTION
 
  This function sets the current, active chord-height tolerance in the
  XYZ space. The value stored in the global is what gets changed by this
  function. Note that this will NOT cause this new tolerance to be stored
  persistently with the file.
*/

void pwSetActiveXYZChtTol
(
  double newtol
)
{
  long rc;

  BSchangepar (&rc, BSTOLCHRDHT, newtol);

  return;
}

/*
  DESCRIPTION
 
  This function returns the zero length tolerance in XYZ space, and the
  chord height tolerance in XYZ space, that is set within this OS (file).
  These are the persistent tolerances that are retrieved and returned.
  These values are not necessarily the currently active ones (stored in
  the globals as mentioned above).

  These values can be extracted via this function and used to set the
  globals via the "Set" functions above.
*/

PWresult pwGetPersistXYZTols
(
  PWosnum os,
  double *lentol,
  double *chttol
)
{
  int msg;
  PWresult result=PW_K_Success;
  PWobjid grdpbid;

  grdpbid = omObjOfClass (OPP_GRdpb_class_id, os);
  OnErrorState (grdpbid == PW_K_NullObjid, result, 
   SetError (PW_K_Pathway, PW_K_NotFound), wrapup);

  result = om$send (msg = message GRdpb.GRget (&msg, grdpb_basis_tolerance,
            (char *) lentol), targetid = grdpbid, targetos = os,
            senderid = PW_K_NullObjid);
  OnErrorCode (result, wrapup);

  result = om$send (msg = message GRdpb.GRget (&msg, 
            grdpb_chord_height_tolerance,
            (char *) chttol), targetid = grdpbid, targetos = os,
            senderid = PW_K_NullObjid);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "GetPersistLenTol");
  return (result);
}

end implementation Root;
