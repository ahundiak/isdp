/* ###################   APOGEE COMPILED   ################## */
/* 
 * DESCRIPTION
 *
 * This method returns the basis parmateric tolerance of this surface.
 * The tolerance may be returned in the local or world coordinate system.
 * This tolerance being returned could be the result of a fresh computation
 * or it could be simpy a return of the tolerance stored in instance data.
 *
 * RETURN VALUES
 *
 * msg                  EMS_S_Success if success
 *                      EMS_E_Fail if problems in allocating abstract buffer
 * partolbasis 			Parametric basis tolerance of the surface.
 *
 * NOTES
 * 
 * This method calls function EFssptol_by_geom() to return the tolerance.
 *  The method was broken to function and this part with a reason that,
 *  implementations just having surface geometries can directly call the 
 *  function and others having surface objects can call this method.
 *
 * BUGS
 *
 *
 * HISTORY
 * 08/25/92 : NP  : Modified for ANSI compliance. Added typecast in GRgetabsg.
 * 11/20/87 : SAM : Function call EFsspbtol_by_geom(). 
 * 03/19/87 : SS  : Design and creation.
 */

class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
/* includes for GRgetabsg macro */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef gocmacros_include
# include "gocmacros.h"
# endif

/* end of GRgetabsg includes    */
# include "bserr.h"
# include "bsparameters.h"
# include "emserr.h"
# include "EMSmsgdef.h"

method EMpartolbasis (
  IGRlong *msg;                         /* Error return code */
  IGRshort *matrix_type;                /* Matrix type code */
  IGRmatrix matrix;                     /* Transformation matrix */
  IGRboolean *world;                    /* Range desired in world system? */
  IGRboolean compute;                   /* A fresh computation desired? */
  IGRdouble *partolbasis)               /* Return tolerance-basis */
{
  IGRint stat_OM, dumdum;
  IGRlong msg_loc, EFsspbtol_by_geom();
  struct IGRbsp_surface *srf;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain this surfaces geometry.
   */

  GRgetabsg (&msg_loc, matrix_type, matrix, (IGRchar **)&srf, dumdum);
  EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  
  stat_OM = EFsspbtol_by_geom(&msg_loc, srf, partolbasis);
  EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_SurfaceError, ret_end);


ret_end:
 return (stat_OM);
}

end implementation EMSsubbs;

