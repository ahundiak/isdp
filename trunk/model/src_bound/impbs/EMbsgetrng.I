/* ###################   APOGEE COMPILED   ################## */
/*
   History

         Sudha 06/04/93          modified to include BSprototype header files
*/

class implementation EMSbsedge;

#include "EMS.h"
#include "bserr.h"
#include "emsmacros.h"
#include "bsfreecv.h"
#include "bscvinskts.h"
#include "bsbx2.h"

#define FROM_SPAN_INX 0
#define NO_SPANS 1

#define DO_COMPARE_TIGHT_RANGE_TO_NORMAL_RANGE 0
#define NUM_KNOTS_TO_INSERT 2

method EMgetrange (IGRlong *EMmsg;
                   IGRdouble *range;
                   struct EMSpartedinfo *bnd)
{
 IGRlong	status;
 IGRboolean	bssts, return_tight_range = TRUE;
 IGRpoint	min,
                max;
 BSrc		rc;
 struct IGRbsp_curve bsgeom, *insktcv = NULL, *cv = NULL;
 IGRint num_insert = NUM_KNOTS_TO_INSERT;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 bsgeom.poles = NULL;
 bsgeom.weights = NULL;
 bsgeom.knots = NULL;
 bsgeom.bdrys = NULL;

 status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                         NO_SPANS, FALSE, bnd, &bsgeom, NULL, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

 if(return_tight_range)
  {
   (void) BScvinskts(&bsgeom, num_insert, &insktcv, &rc);
   if( (rc != BSSUCC) || !insktcv)
    cv = &bsgeom;
   else
    cv = insktcv;
  }
 else
  cv = &bsgeom;

 bssts = BSbx2 (&rc, &cv->num_poles, (IGRpoint *) cv->poles,
          cv->rational ? cv->weights : NULL, min, max);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_EdgeError, wrapup);

 range[0] = min[0];
 range[1] = min[1];
 range[2] = max[0];
 range[3] = max[1];

#if DO_COMPARE_TIGHT_RANGE_TO_NORMAL_RANGE
 {
  int i;

  printf("BSedge ID %d\n", my_id);

  if(cv == insktcv)
   {
    bssts = BSbx2 (&rc, &bsgeom.num_poles, (IGRpoint *) bsgeom.poles, 
            bsgeom.rational ? bsgeom.weights : NULL, min, max);
    EMerr_hndlr (!bssts, *EMmsg, EMS_E_EdgeError, wrapup);
    printf("Normal range -- \n");
    for(i=0; i<2; i++)
     printf("%5.12lf\n", min[i]);
    for(i=0; i<2; i++)
     printf("%5.12lf\n", max[i]);

    printf("Tighter range -- \n");
    for(i=0; i<4; i++)
     printf("%5.12lf\n", range[i]);
   }
  else
   {
    printf("Normal range -- \n");
    for(i=0; i<4; i++)
     printf("%5.12lf\n", range[i]);
   }
 }
#endif

wrapup:
 if (bsgeom.poles) free (bsgeom.poles);
 if (bsgeom.weights ) free (bsgeom.weights);
 if (bsgeom.knots) free (bsgeom.knots);
 if (bsgeom.bdrys) free (bsgeom.bdrys);
 if(insktcv) BSfreecv(&rc, insktcv);
 EMWRAPUP (*EMmsg, status , "In EMSbsedge:EMgetrange error");

 return (status);

}

end implementation EMSbsedge;
              

