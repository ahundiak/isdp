/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "mamulmx.h"

method EMuv_transform (
        IGRlong                 *EMmsg;
        IGRdouble               matrix[16];
        struct EMSpartolbasis   *partolbasis;
        IGRshort                option;
        IGRchar                 *null_ptr1;
        IGRchar                 *null_ptr2)

/*
 Notes
        This method tranforms the B-spline edge by incoming matrix.
        This is done by transforming all of the (u,v) poles in its
        instance data.

        Some of the poles may not be in 0 to 1 range. Transform
        these poles also. 

History
        RC      04/29/87        Creation date
        RC      08/31/87        Modified the arguments and
                                the appropriate code.
	DLB	09/25/91	Pass *short to MAmulmx instead of *int.
				SUN issue.
        Sudha 06/04/93          modified to include BSprototype header files

*/

{
  IGRlong               OM_stat;
  IGRlong   rc;

  IGRdouble             mat_a[4], mat_c[4];

  IGRint                i, wt_ptr;
  IGRshort		l = 4, m = 4, n = 1; /*Made shorts - DLB*/

  IGRboolean            status;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  wt_ptr = ME.EMSbsedge->num_poles * 2;

  for (i = 0; i < ME.EMSbsedge->num_poles; i++)
  {
     mat_a[0] = ME.EMSbsedge->packed_doubles[2*i];
     mat_a[1] = ME.EMSbsedge->packed_doubles[2*i + 1];
     mat_a[2] = 0.0;
     mat_a[3] = 1.0;
        
     if (ME.EMSbsedge->bs_props & EMBS_RATIONAL)
     {
       mat_a[0] /= ME.EMSbsedge->packed_doubles[wt_ptr];
       mat_a[1] /= ME.EMSbsedge->packed_doubles[wt_ptr];
     }
	   
     status = MAmulmx (&rc, &l, &m, &n, matrix, mat_a, mat_c);
     EMerr_hndlr ((!status || !(1&rc)),*EMmsg,EMS_E_Fail,wrapup);

     if (ME.EMSbsedge->bs_props & EMBS_RATIONAL)
     {
       mat_c[0] *= ME.EMSbsedge->packed_doubles[wt_ptr];
       mat_c[1] *= ME.EMSbsedge->packed_doubles[wt_ptr++];
     }

     ME.EMSbsedge->packed_doubles[2*i] = mat_c[0];
     ME.EMSbsedge->packed_doubles[2*i + 1] = mat_c[1];

  } /* for (i = 0; i < ME.EMSbsedge->num_poles; i++) */

wrapup:
	
    EMWRAPUP (*EMmsg, OM_stat, "In EMSbsedge.EMuv_transform");
 
    return (OM_stat);

}
end implementation EMSbsedge;
