/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

   This method determines the plane formed by a surface, if any.
  
 RETURN VALUES
   
   msg                  completion code
                        - MSSUCC if successful
                        - MANOMEMORY if no dynamic memory available
                        - MANONPLANAR if no unique plane possible
                        - MSFAIL (severe) if failure
   plane                The plane, the plane
  
 HISTORY
  
   02/05/87 : dlb : Creation date.
   09/23/87 : rlw : Discontinued using MAdetplane() due to a bug.  I changed
                    to use BStst_plan().  This is probably better anyway since
                    we will be more consistent.  At any rate dave forgot to
                    unweight the poles and his result may have been incorrect
                    plus he was using a hardcoded tolerance.
   09/12/87 : dlb PP : Bug fix to type cast generic pointer to surface 
                       pointer
 */

class implementation EMSsubbs;

#include "EMS.h"
#include "bs.h"
#include "msdef.h"
#include "maerr.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "gocmacros.h"                  /* Has GRgetabsg macro */

method GRdetplane(
 IGRlong *msg; 
 IGRshort *matrix_type;
 IGRmatrix matrix;
 struct IGRplane *plane)
{
  extern  void           BStst_plan();
 IGRchar        *generic_pointer;
 IGRboolean     is_planar;
 IGRlong        i, loc_msg;
 IGRpoint	dumpt;
 IGRvector	natnorm;
 struct         IGRbsp_surface *surface;
 extern 	IGRdouble BSdotp();

/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Get my geometry
 */
 GRgetabsg(
   msg,
   matrix_type,
   matrix,
   &generic_pointer,
   i);
  if (! (1 & *msg))
   {
     *msg = MSFAIL;
     goto wrapup;
   }
 surface = (struct IGRbsp_surface *) generic_pointer;  /*bugfix DLB PP*/
/*
 * Determine planarity
 */
 BStst_plan(
   surface->u_num_poles * surface->v_num_poles,
   surface->poles,
   (surface->rational ? surface->weights : NULL),
   &is_planar,
   plane->normal,
   &loc_msg);
  if (loc_msg == BSSUCC)
   {
    if (is_planar)
     {
      *msg = MSSUCC;
      OM_BLOCK_MOVE(
       surface->poles,
       plane->point,
       sizeof(IGRpoint));
      if (surface->rational)
       {
        plane->point[0] /= surface->weights[0];
        plane->point[1] /= surface->weights[0];
        plane->point[2] /= surface->weights[0];
       }

/*
 * Use logical normal instead of an arbitrary normal.
 * pp 09/15/92
 * Since the plane->normal is arbit. We need to check against
 * an oriented normal with a dot-product. And then flip the
 * tst_plane normal of it does not confirm. SS 08/18/94
 */
      EMavgsfnorm (&loc_msg, surface, 0.5, 0.5, dumpt, natnorm);
      EMerr_hndlr (EMSerror (loc_msg), *msg, MSFAIL, wrapup);

      if (!surface->pos_orient)
       {
        for (i=0;i<3;i++)
         natnorm[i] = -natnorm[i];
       }
      
      if (BSdotp (&loc_msg, natnorm, plane->normal) < 0.0)
       {
        for (i=0;i<3;i++)
         plane->normal[i] = -plane->normal[i];
       }
     }
    else
     *msg = MANONPLANAR;
   }
  else if (loc_msg == BSNOSTKMEMORY)
   *msg = MANOMEMORY;
  else
   *msg = MSFAIL;
/*
 * Eof
 */
wrapup:
 if ((*msg == MANONPLANAR) ||
     (1 & *msg))
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation EMSsubbs;
