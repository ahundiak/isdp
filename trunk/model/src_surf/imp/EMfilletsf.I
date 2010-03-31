/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method constructs a surface which fillets 2 surfaces together.

 RETURN VALUES

  msg   EMS_S_Success - on success
        EMS_E_Fail - on a non-math failure.
        EMS_E_BSerror - math function call fail.
        EMS_E_NoDynamicMemory - if no memory could be allocated
	EMS_E_InvalidArg - Some arguments are missing.

 NOTES

 This object will delete itself if an error occurs.

 HISTORY

 11/19/87 : rlw : Rewritten, renamed, and moved method to class EMSgenbs
 05/30/88 : rlw : Modified to support variable radius fillet.
 09/14/89 : SS  : Modified to support law. Also name changed.
 04/20/95 : Hari: Modified to handle constant and variying fillet radius
 */

class implementation EMSgenbs;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"			/* Includes the world */
#include "EMSopt.h"

#define START_PAR  0.0
#define END_PAR    1.0

#define FIRST  0
#define SECOND 1

method EMmkfilletsf(
 IGRlong 		*msg;
 struct GRlc_info	*surface_1;
 IGRboolean		is_natural_normal_1;
 struct GRlc_info	*surface_2;
 IGRboolean		is_natural_normal_2;
 IGRpoint		starting_point;
 IGRdouble		starting_radius;
 IGRpoint		ending_point;
 IGRdouble		ending_radius;
 IGRdouble		*dirpt;
 struct IGRbsp_curve	*lawcv;
 IGRdouble		rho;
 struct GRvg_construct	*construct_list;
 IGRushort	options)
{
 IGRboolean	endcvs[2];
 IGRlong        loc_msg, sts;
 IGRlong	EMget_the_geometry();
 IGRdouble      cht_tol;
 struct		IGRbsp_surface *surface1, *surface2;
 struct		IGRbsp_surface *fillet_surface;
 extern  	void BSvrfilsfwl();
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 surface1 = NULL;
 surface2 = NULL;
 fillet_surface = NULL;
/*
 * Get the geometries of the various
 * entities
 */
 sts = EMget_the_geometry(
   surface_1,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   FALSE,			/* Separate mallocs? */
   my_id,
   &surface1,			/* The geometry */
   &loc_msg);
 if (EMSerror (sts))
   {
    *msg = EMS_E_Fail;
    surface1 = NULL;
    goto wrapup;
   }
 sts = EMget_the_geometry(
   surface_2,
   FALSE,			/* Is a curve? */
   NULL,			/* Is directed curve? */
   FALSE,			/* Separate mallocs? */
   my_id,
   &surface2,			/* The geometry */
   &loc_msg);
  if (EMSerror (sts))
   {
    *msg = EMS_E_Fail;
    surface2 = NULL;
    goto wrapup;
   }
/*
 * Change rho
 */
 BSchangepar(
   &loc_msg,
   BSRHO_VALUE, 
   rho);
  if (loc_msg != BSSUCC)
   {
    *msg = EMS_E_BSerror;
    goto wrapup;
   }

/*
 * Call the Math.
 * Modified to handle constant and varying fillet radius
 */

 BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, cht_tol);

 if (EMis_geomequal_3dpt (starting_point, ending_point, cht_tol))
 {
   BSfilletsfd( surface1,surface2,starting_radius, 
                dirpt, is_natural_normal_1,is_natural_normal_2,
                &fillet_surface,&loc_msg);
  }
 else
  {
   endcvs[FIRST] = endcvs[SECOND] = FALSE;
   BSvrfilsfwl(
      surface1,
      surface2,
      starting_radius,
      ending_radius,
      is_natural_normal_1,
      is_natural_normal_2,
      options & EMS_FILLET_PART,
      starting_point,
      ending_point,
      dirpt,
      lawcv ? FALSE : TRUE,
      lawcv,
      START_PAR, END_PAR,
      endcvs, NULL, NULL, NULL, NULL,
      &fillet_surface,
      &loc_msg);
   }

  if (loc_msg != BSSUCC)
   {
     *msg = EMS_E_BSerror;
     goto wrapup;
    }
  
/*
 * Fill the instance data and such
 */
 construct_list->geometry = (IGRchar *) fillet_surface;
 sts = om$send(
   msg = message GRgraphics.GRconstruct(construct_list),
   targetid = my_id);
 if (EMSerror (sts))
  {
   *msg = *(construct_list->msg);
   goto wrapup;
  }
/*
 * End of routine
 */
wrapup:
 *(construct_list->msg) = *msg;
 if (surface1) free(surface1);
 if (surface2) free(surface2);
 if (fillet_surface) BSfreesf(&loc_msg, fillet_surface);
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(
    msg = message Root.delete(1),
    targetid = my_id);
   return(OM_E_ABORT);
  }
}

end implementation EMSgenbs;
