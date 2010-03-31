/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
# include <stdio.h>
# include "igrtypedef.h"
# include "igr.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "msdef.h"

# include "emsdef.h"
# include "emserr.h"

method EMcrvsrfint( IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve   *curve_in;
		    struct GRid		  *curve_obj;
		    struct GRmdenv_info   *curve_objenv;
		    IGRboolean		   hole_inter_valid;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **curve_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;
		    IGRulong	  **inter_props)

/*
Abstract
        This method intersects a surface with a curve.
  	I AM A COMP SURFACE. I CAN INTERSECT ONLY CURVES / COMPCURVES        

        My component children with same arguments

Nots
	For a description of the arguments refer the implementation
	at EMSsubss class (EMvgCrvSf.I)

History
	gk	12/4/87		Creation date
*/

{
  OM_S_CHANSELECT	to_components;

  IGRlong		status = OM_S_SUCCESS;

/* ------------------------------------------------------------- */

  *msg = MSSUCC;

/* Set up the channel select */

  to_components.type 	   = OM_e_addr;
  to_components.u_sel.addr = &ME.GRcmpowner->to_components;

/* Send intersect method to my children */

  status = om$send( msg = OPPmargs,
		    p_chanselect = &to_components,
	   	    from = NULL,
		    to   = GRDGNLIMITS_MAX_I);
  if(EMSmsgReport(status, "EMcscrvsf: OPPmargs", FALSE))goto wrapup;


wrapup:
  return(status);
}

end implementation EMScompsurf;

