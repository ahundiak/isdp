/*
  DESCRIPTION
    
    This function takes in a point and vector defined in the world-coordinate
    system that is representative of some planar data residing in a local
    coordinate system (for example instance data of objects). It returns a
    single matrix that can be used to transform the local-space data onto the
    Z=0 plane in the world co-ordinates. Application of the transformation
    will take place such that the input point becomes the origin.

    The transformation matrix that would bring the data from the Z=0 plane to
    local-space is optionally returned.

  ARGUMENTS

    pt, norvec			- Input: The point and the normal defining the
                                  input plane.
    modmattyp, modmat		- Input: The transformation matrix (and
                                  it's type) that transforms from local to
                                  world system.
    xmattyp, xmat		- Output: The single transformation matrix to
                                  transform the input plane in it's local
                                  space to the Z=0 plane in the world space.
    invmattyp, invmat		- Output: The single transformation matrix
                                  to transform from Z=0 plane into the
                                  local coordinate space. Could be NULL.
    bastol			- Input: The basis tolerance in world space.

  ALGORITHM
   
    The steps involved in the computation of the matrix to go to Z=0, are:
       i) If the natural normal does not lie along the +Z-vector, obtain
          the rotation matrix to force the normal along this direction.
          (Called the "rotxmat" matrix). Multiply rotxmat X modmat = tempmat.
      ii) If the resulting plane does not lie in the Z=0 plane, multiply
          in a translation matrix to take it there. (Called the "transxmat"
          matrix). Multiply transxmat X tempmat = xmat.

    The matrix to bring back the plane to the local system can be computed as:
    inverse of (transxmat X rotxmat).

  HISTORY
  
    SS  :  10/20/87  :  Creation
    SS  :  05/04/89  :  Made bastol optional. If NULL passed in the 
                        current default collinearity-tolerance is extracted.
    SS/NP: 03/10/93  :  Cleaned up function. This also corrected an error where
                        the input point was being wrongly transformed, while 
                        checking if translation is necessary.
*/

#include "EMS.h"
#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"
#include "maerr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"

#define X 0
#define Y 1
#define Z 2

void EMtoplnxform (msg, pt, norvec, modmattyp, modmat, xmattyp, xmat, 
                   invmattyp, invmat, bastol)
IGRlong *msg;
IGRdouble pt[3], norvec[3];
IGRshort *modmattyp, *xmattyp, *invmattyp;
IGRmatrix modmat, xmat, invmat;
IGRdouble *bastol;
{
  IGRboolean stat_func;
  IGRshort four = 4;
  IGRint numpts;
  IGRlong msg_loc;
  IGRdouble crosstol, xpt[3];
  IGRmatrix rotxmat, transxmat, tempmat;
  extern IGRboolean MAmulmx(), MAptsxform(), MAtrnmx(), MAzrotmx();
  extern IGRboolean MAtypemx(), MAinvmx();
  extern IGRboolean EFextract_par();
  IGRlong OM_stat = OM_S_SUCCESS;

  *msg = EMS_S_Success;

  if (bastol)
    EFextract_par (BSTOLCOLLINVEC, *bastol, &crosstol, &msg_loc);
  else
    BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, crosstol);

  /*
   * If a rotation matrix to go to Z=0 plane is required to be introduced, 
   * compute the rotation matrix.
   */

  if (fabs (norvec[X]) > crosstol ||
      fabs (norvec[Y]) > crosstol ||
      fabs (1.0 - norvec[Z]) > crosstol)
    {
    stat_func = MAzrotmx (&msg_loc, norvec, rotxmat);
    EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_MAerror, 
     ret_end);
    }
  else
    MAidmx (&msg_loc, rotxmat);

  /*
   * Check if a translation along the Z-axis is required to go to
   * the Z=0 plane.
   */

  numpts = 1;
  stat_func = MAptsxform (&msg_loc, &numpts, rotxmat, pt, xpt);
  EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  if (xpt[X] != 0.0 || xpt[Y] != 0.0 || xpt[Z] != 0.0)
    {
    MAidmx (&msg_loc, transxmat);
    transxmat[3] = -xpt[X];
    transxmat[7] = -xpt[Y];
    transxmat[11] = -xpt[Z];
    }
  else
    MAidmx (&msg_loc, transxmat);


  stat_func = MAmulmx (&msg_loc, &four, &four, &four, transxmat, rotxmat,
               tempmat);
  EMerr_hndlr (! stat_func || EMSerror (msg_loc), *msg,
   EMS_E_MAerror, ret_end);

  if (*modmattyp != MAIDMX)
    {
    stat_func = MAmulmx (&msg_loc, &four, &four, &four, tempmat, modmat,
                 xmat);
    EMerr_hndlr (! stat_func || EMSerror (msg_loc), *msg,
     EMS_E_MAerror, ret_end);
    }
  else
    OM_BLOCK_MOVE (tempmat, xmat, sizeof (IGRmatrix));

  MAtypemx (&msg_loc, xmat, xmattyp);

  /*
   * If the computation of the inverse matrix that will return the Z=0
   * transformation to the world system is required, compute it.
   */

  if (invmat)
    {
    stat_func = MAmulmx (&msg_loc, &four, &four, &four, transxmat, rotxmat,
                 invmat);
    EMerr_hndlr (! stat_func || EMSerror (msg_loc), *msg,
     EMS_E_MAerror, ret_end);
    stat_func = MAinvmx (&msg_loc, &four, invmat, invmat);
    EMerr_hndlr (! stat_func || EMSerror (msg_loc), *msg,
     EMS_E_MAerror, ret_end);

    if (invmattyp)
      {
      stat_func = MAtypemx (&msg_loc, invmat, invmattyp);
      EMerr_hndlr (! stat_func || EMSerror (msg_loc), *msg, EMS_E_MAerror,
       ret_end);
      }
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, OM_stat, "EMtoplnxform");
}

