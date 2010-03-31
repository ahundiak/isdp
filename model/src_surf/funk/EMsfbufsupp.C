/* ###################   APOGEE COMPILED   ################## */

/*
HISTORY:

Long Ago:  ?? 	Creation
08/27/92:  NP   Modified for ANSI compliance.

*/


#include "EMS.h"
#include "OMminimum.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"         /* IGResqbs         */
# include "EMSmsgdef.h"     /* EMS error codes  */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "EMSommacros.h"   /* ems$get_memory   */
# include "OMprimitives.h"  /* om$              */
# include "emserr.h"        /* EMWRAPUP         */
# include "OMerrordef.h"    /* OM error codes   */
# include "gocmacros.h"     /* GRalign          */
# include "OMmacros.h"	    /* OM_BLOCK_MOVE	*/

void EMsfsize(u_order, v_order, u_num_poles, v_num_poles, rational, size)
IGRshort u_order, v_order;
IGRlong  u_num_poles, v_num_poles;
IGRboolean rational;
IGRlong *size;
{
  EMSbs_size(u_order, v_order, u_num_poles, v_num_poles, rational, 
	     0, (IGRlong *) NULL, *size)
}


void EMsfpartition(u_order, v_order, u_num_poles, v_num_poles, rational, 
		   surface)
IGRshort u_order, v_order;
IGRlong  u_num_poles, v_num_poles;
IGRboolean rational;
struct IGRbsp_surface *surface;
{
  EMSbs_partition(u_order, v_order, u_num_poles, v_num_poles, rational, 
	          0, (IGRlong *) NULL, surface)
}

void EMsfalloc_copy(EMmsg, insurf, outsurf)
IGRlong *EMmsg;
struct IGRbsp_surface *insurf, **outsurf;
{
 IGRlong num_bytes, total_poles;

 *EMmsg = EMS_S_Success;
 EMsfsize(insurf->u_order, insurf->v_order, insurf->u_num_poles, 
	    insurf->v_num_poles, insurf->rational, &num_bytes);
 *outsurf = (struct IGRbsp_surface *) om$malloc(size = num_bytes);
 EMerr_hndlr(!(*outsurf), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 EMsfpartition(insurf->u_order, insurf->v_order, insurf->u_num_poles, 
	    insurf->v_num_poles, insurf->rational, *outsurf);
	
 (*outsurf)->u_order = insurf->u_order;
 (*outsurf)->v_order = insurf->v_order;
 (*outsurf)->u_periodic = insurf->u_periodic;
 (*outsurf)->v_periodic = insurf->v_periodic;
 (*outsurf)->u_non_uniform = insurf->u_non_uniform;
 (*outsurf)->v_non_uniform = insurf->v_non_uniform;
 (*outsurf)->u_num_poles = insurf->u_num_poles;
 (*outsurf)->v_num_poles = insurf->v_num_poles;
 (*outsurf)->u_num_knots = insurf->u_num_knots;
 (*outsurf)->v_num_knots = insurf->v_num_knots;
 (*outsurf)->rational = insurf->rational;
 (*outsurf)->planar = insurf->planar;
 (*outsurf)->u_phy_closed = insurf->u_phy_closed;
 (*outsurf)->v_phy_closed = insurf->v_phy_closed;
 (*outsurf)->pos_orient = insurf->pos_orient;
 (*outsurf)->on_off = insurf->on_off;
 (*outsurf)->num_boundaries = insurf->num_boundaries;
 (*outsurf)->bdrys = NULL;

 total_poles = (*outsurf)->u_num_poles * (*outsurf)->v_num_poles;
 num_bytes = total_poles * 3 * sizeof(double);
 OM_BLOCK_MOVE(insurf->poles, (*outsurf)->poles, num_bytes);

 if (insurf->rational)
  {
   num_bytes = sizeof(double) * total_poles;
   OM_BLOCK_MOVE(insurf->weights, (*outsurf)->weights, num_bytes);
  }
 else
  (*outsurf)->weights = NULL;
 
 num_bytes = sizeof(double) * insurf->u_num_knots;
 OM_BLOCK_MOVE(insurf->u_knots, (*outsurf)->u_knots, num_bytes);
 num_bytes = sizeof(double) * insurf->v_num_knots;
 OM_BLOCK_MOVE(insurf->v_knots, (*outsurf)->v_knots, num_bytes);

wrapup:
;
}
