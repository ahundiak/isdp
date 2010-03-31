/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include <stdio.h>
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "emserr.h"
#include "emsdef.h"

method EMcrvcrvint( IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve	  *other_curve_in;
		    struct GRid		  *other_obj;
		    struct GRmdenv_info   *other_objenv;
		    IGRboolean		   end_inter_valid;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **other_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters;
		    struct GRparms	  **other_crv_inters)

/*
Abstract
	This method intersects a composite curve object (myself) with
	another object sub-clased off GRcurve

Notes
	For description of the arguments refer to the implementation
	at GRbspline class ie EMbsBcBcInt.I

History
	gk	11/26/86	creation date
	rlw	05/08/87	modified channel name
	gk	5/25/87		modified to include EMSinters struct
    DLB 10/28/87    modified for version 1.1.0
        gk	12/3/87		changed the arguments
*/


{
  OM_S_CHANSELECT	to_components;

  IGRlong		status;

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
  if(EMSmsgReport(status, "EMccccint: OPPmargs", FALSE)) goto wrapup;;

wrapup:
  return(status);
}
end implementation GRcompcurve;
