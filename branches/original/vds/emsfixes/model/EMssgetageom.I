/* $Id: EMssgetageom.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	emsfixes/model/EMSssgetageom.I
 *
 * Description:
 *		Display method for EMSsubbs class objects which need to 
 *		be corrected to avoid a crash.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMssgetageom.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/03/27  16:54:56  pinnacle
# File being re-created for ems fix
#
# Revision 1.2  1995/10/03  16:35:20  pinnacle
# Replaced: emsfixes/model/EMssgetageom.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/09/20  14:52:56  pinnacle
# Created: emsfixes/model/EMssgetageom.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/20/95	adz		creation date
 *
 ***************************************************************************/

/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method can be used in place of get-abstract-geometry and get-geometry.
    The call is not as efficient as the former and not as resource-consuming
    as the latter. The method possesses an abstract-geometry buffer of it's
    own. The buffer is locked into use automatically when this method is
    invoked, until the buffer is "unlocked" by a call to an argument-less
    function - EMunlock_surf_absg_buffer. While the buffer is "locked"
    other calls to this method will fail with an error. 

    The motivation for this message is to get some of the benefits of having
    an abstract buffer but without the restriction that no other 
    generate-abstract geometry calls can be made before the task is complete.

  NOTES
    
    First used in the method EMget_ele_header (file EMssEleHdr.I). This
    method should be overridden only with extreme caution.
 
  RETURN VALUES

    If all went well (the output is valid):
      - EMS_S_Success
    On error (there is no valid surface output):
      - EMS_E_Fail, This condition can also be caused by this method being
                   invoked when the surface buffer has not been unlocked since
                   the previous call to this method.
      - EMS_E_NoDynamicMemory, When malloc ro realloc failed.

  HISTORY

    SS  :  12/01/88  :  Creation
    NP  :  08/26/92  :  Modified for ANSI compliance. Added missing typecast in
			GRgetabsg.
*/

class implementation EMSsubbs;

#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"

/* (1 block - 504 bytes) */
#define POLES_SIZE   21

/* (1/2 block - 256 bytes) */
#define U_KNOTS_SIZE 32

/* (1/2 block - 256 bytes) */
#define V_KNOTS_SIZE 32

/* (1/2 block - 256 bytes) */
#define WEIGHTS_SIZE 32

%safe
static IGRboolean a_buffer_locked = FALSE;
static struct IGRbsp_surface a_srf;
static IGRdouble *a_poles = NULL;
static IGRint a_num_poles = 0;
static IGRdouble *a_u_knots = NULL;
static IGRint a_u_num_knots = 0;
static IGRdouble *a_v_knots = NULL;
static IGRint a_v_num_knots = 0;
static IGRdouble *a_weights = NULL;
static IGRint a_num_weights = 0;
%endsafe

void EMunlock_surf_absg_buffer()
{
  a_buffer_locked = FALSE;
  return;
}

method EMgetabsgeom (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                     IGRchar **srf)
{
  IGRint numblks, dumint;
  IGRint num_poles, u_num_knots, v_num_knots, num_weights;
  IGRlong msg_loc, stat_OM;
  struct IGRbsp_surface *loc_srf;

#ifdef	DEBUG
  printf(" >> [%d,%d] EMgetabsgeom \n", my_id, OM_Gw_current_OS );
#endif

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the abstract buffer has been locked by a previous call
   * (and not unlocked yet) return with an error code.
   */

  EMerr_hndlr (a_buffer_locked, *msg, EMS_E_Fail, ret_end);

  /*
   * Obtain the geometry of this surface
   */
/**
  GRgetabsg (&msg_loc, mattyp, mat, (IGRchar **)&loc_srf, dumint);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
 **/

/* START MODIFICATION */
  stat_OM =
  om$send( mode = OM_e_wrt_object,
	   msg  = message GRvg.GRgenabsg( msg, mattyp, mat,
					  (IGRchar **)&loc_srf ),
	   targetid = my_id );

  if( !(stat_OM & *msg & 1 )){
	*msg = EMS_E_Fail ;
	goto ret_end ;
  }
/* END MODIFICATION */
	
  /*
   * Move it into the abstract buffer of this file, allocating
   * additional space if necessary. All control variables are
   * updated.
   */

  a_srf = *loc_srf;
  num_poles = a_srf.u_num_poles * a_srf.v_num_poles;
  u_num_knots = a_srf.u_num_knots;
  v_num_knots = a_srf.v_num_knots;
  num_weights = a_srf.rational ? num_poles : 0;

#ifdef	DEBUG
  printf(" num_poles/a_num_poles : %d, %d \n", num_poles , a_num_poles );
#endif

/* START MODIFICATION */
  if(( num_poles > a_num_poles) || (! a_poles) )
    {
    numblks = (num_poles / POLES_SIZE) + ((num_poles % POLES_SIZE) ? 1 : 0);
    if (a_poles)
      om$dealloc (ptr = a_poles);
    a_poles = (IGRdouble *) om$malloc (size = numblks * POLES_SIZE * 3 *
               sizeof (IGRdouble));
    EMerr_hndlr (!a_poles, *msg, EMS_E_NoDynamicMemory, ret_end);
    a_num_poles = numblks * POLES_SIZE;
    }

#ifdef	DEBUG
  printf(" u_num_knots/a_u_num_knots : %d, %d \n", u_num_knots,a_u_num_knots );
#endif

  if(( u_num_knots > a_u_num_knots ) || ( ! a_u_knots ))
    {
    numblks = (u_num_knots / U_KNOTS_SIZE) + 
               ((u_num_knots % U_KNOTS_SIZE) ? 1 : 0);
    if (a_u_knots)
      om$dealloc (ptr = a_u_knots);
    a_u_knots = (IGRdouble *) om$malloc (size = numblks * U_KNOTS_SIZE * 
                 sizeof (IGRdouble));
    EMerr_hndlr (!a_u_knots, *msg, EMS_E_NoDynamicMemory, ret_end);
    a_u_num_knots = numblks * U_KNOTS_SIZE;
    }

#ifdef	DEBUG
  printf(" v_num_knots/a_v_num_knots : %d, %d \n", v_num_knots,a_v_num_knots );
#endif

  if(( v_num_knots > a_v_num_knots ) || ( ! a_v_knots ))
    {
    numblks = (v_num_knots / V_KNOTS_SIZE) + 
               ((v_num_knots % V_KNOTS_SIZE) ? 1 : 0);
    if (a_v_knots)
      om$dealloc (ptr = a_v_knots);
    a_v_knots = (IGRdouble *) om$malloc (size = numblks * V_KNOTS_SIZE * 
                 sizeof (IGRdouble));
    EMerr_hndlr (!a_v_knots, *msg, EMS_E_NoDynamicMemory, ret_end);
    a_v_num_knots = numblks * V_KNOTS_SIZE;
    }

#ifdef	DEBUG
  printf(" num_weights/a_num_weights : %d, %d \n", num_weights,a_num_weights );
#endif
  if( num_weights > a_num_weights )
    {
    numblks = (num_weights / WEIGHTS_SIZE) + 
               ((num_weights % WEIGHTS_SIZE) ? 1 : 0);
    if (a_weights)
      om$dealloc (ptr = a_weights);
    a_weights = (IGRdouble *) om$malloc (size = numblks * WEIGHTS_SIZE * 
               sizeof (IGRdouble));
    EMerr_hndlr (!a_weights, *msg, EMS_E_NoDynamicMemory, ret_end);
    a_num_weights = numblks * WEIGHTS_SIZE;
    }

/* END MODIFICATION */

#ifdef	DEBUG
  printf(" OM_BLOCK_MOVE poles : %d\n", num_poles * 3 * sizeof (IGRdouble) );
#endif
  OM_BLOCK_MOVE (loc_srf->poles, a_poles, num_poles * 3 * 
   sizeof (IGRdouble));
  a_srf.poles = a_poles;

#ifdef	DEBUG
  printf(" OM_BLOCK_MOVE u_knots : %d\n", u_num_knots * sizeof (IGRdouble) );
#endif
  OM_BLOCK_MOVE (loc_srf->u_knots, a_u_knots, u_num_knots * 
   sizeof (IGRdouble));
  a_srf.u_knots = a_u_knots;

#ifdef	DEBUG
  printf(" OM_BLOCK_MOVE v_knots : %d\n", v_num_knots * sizeof (IGRdouble) );
#endif
  OM_BLOCK_MOVE (loc_srf->v_knots, a_v_knots, v_num_knots * 
   sizeof (IGRdouble));
  a_srf.v_knots = a_v_knots;

  if (num_weights)
    {
#ifdef	DEBUG
    printf(" OM_BLOCK_MOVE weights : %d\n", num_weights * sizeof (IGRdouble) );
#endif
    OM_BLOCK_MOVE (loc_srf->weights, a_weights, num_weights *
     sizeof (IGRdouble));
    a_srf.weights = a_weights;
    }

  /*
   * A valid surface geometry is about to be returned. Lock this
   * buffer in place.
   */

  *srf = (IGRchar *) &a_srf;
  a_buffer_locked = TRUE;

ret_end:

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMgetabsgeom");

#ifdef	DEBUG
  printf(" << [%d,%d] EMgetabsgeom \n", my_id, OM_Gw_current_OS );
#endif

  return (stat_OM);
}

end implementation EMSsubbs;
