/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*

History : 02/01/88 : Creation date
  Sudha   07/08/93   Modified for BSprototypes ansification

*/
class implementation GRbspline;

#include "EMS.h"
#include "bserr.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"
#include "grerr.h"
#include "msdef.h"
#include "bsnorkts.h"
#include "bsmergecvnn.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"

IGRboolean EFget_composite_info(EMmsg,
                                number_of_curves,
                                curves,
                                composite,
                                unmerged_curves,
                                the_merged_curve)

IGRlong             *EMmsg;
IGRlong	         	number_of_curves;
OM_S_OBJECT_LINKAGE curves[];
struct GRlc_info	*composite;
struct              IGRbsp_curve **unmerged_curves;
struct        		IGRbsp_curve **the_merged_curve;

{
 IGRlong        stat_OM, msg;
 IGRshort		order;
 IGRboolean		status, rational;
 IGRlong		i, num_poles;
 IGRlong        crv_size;
 struct			IGRbsp_curve *tmp_curve, *merged_curve, *new_curve;

 *EMmsg = MSSUCC;
 *the_merged_curve = NULL;
 tmp_curve = NULL;
 merged_curve = NULL;
 new_curve = NULL;

 /* For each curve get the geometry and merge it in with the rest */

 for (i = 0; i < number_of_curves; i++)
  {
   stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                           &composite->module_info.md_env.matrix_type,
                           composite->module_info.md_env.matrix,
                           &crv_size),
                     senderid = NULL_OBJID,
                     targetid = curves[i].S_objid,
                     targetos = curves[i].osnum);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
   unmerged_curves[i] = (struct IGRbsp_curve *) om$malloc(size = (OMuint)
                        crv_size);
   EMerr_hndlr(! unmerged_curves[i], *EMmsg, EMS_E_NoDynamicMemory,
               wrapup);
  
   stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                           &composite->module_info.md_env.matrix_type,
                           composite->module_info.md_env.matrix,
                           (IGRchar *)unmerged_curves[i]),
                     senderid = NULL_OBJID,
                     targetid = curves[i].S_objid,
                     targetos = curves[i].osnum);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   BSalloccv(unmerged_curves[i]->order, unmerged_curves[i]->num_poles,
             unmerged_curves[i]->rational, 0, &tmp_curve, &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   status = BScv_copy(&msg, unmerged_curves[i], tmp_curve);
   EMerr_hndlr(!status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   /* Merge it with the rest of them */

   if (i == 0)
    {
     merged_curve = tmp_curve;
     tmp_curve = NULL;
    }
   else
    {
     /* Allocate the curve structure for */
     /* the resulting merged curve.      */

     order = (merged_curve->order >= tmp_curve->order ? 
              merged_curve->order : tmp_curve->order);
     if (merged_curve->order == tmp_curve->order)
      num_poles = merged_curve->num_poles + tmp_curve->num_poles - 1;
     else if (merged_curve->order > tmp_curve->order)
      num_poles = merged_curve->num_poles + tmp_curve->num_poles +
                   ((tmp_curve->num_poles - tmp_curve->order + 2) *
                    (merged_curve->order - tmp_curve->order));
     else
      num_poles = tmp_curve->num_poles + merged_curve->num_poles +
                   ((merged_curve->num_poles - merged_curve->order + 2) *
                    (tmp_curve->order - merged_curve->order));
     rational = merged_curve->rational || tmp_curve->rational;

     BSalloccv(order, num_poles, rational, 0, &new_curve, &msg);
     EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     BSmergecvnn(merged_curve, tmp_curve, new_curve, &msg);
     EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     status = BSfreecv(&msg, tmp_curve);
     tmp_curve = NULL;

     status = BSfreecv(&msg, merged_curve);
     merged_curve = new_curve;

     new_curve = NULL;

    } /* ELSE FOR if (i == 0) */
  } /* for (i = 0; i < number_of_curves; i++) */

 /* Fix the end weights */

 if (merged_curve->rational)
  {

   BSchgcvewts(merged_curve, merged_curve, &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 /* Reparameterize */

 status = BSnorkts(&msg,&merged_curve->order,&merged_curve->num_poles,
                   merged_curve->knots);
 EMerr_hndlr(msg != BSSUCC || ! status, *EMmsg, EMS_E_BSerror, wrapup);

 merged_curve->num_boundaries = 0;
 *the_merged_curve = merged_curve;
 merged_curve = NULL;

wrapup:
 if (tmp_curve)    status = BSfreecv (&msg, tmp_curve);
 if (merged_curve) status = BSfreecv (&msg, merged_curve);
 if (new_curve)    status = BSfreecv (&msg, new_curve);
 if (! (1 & *EMmsg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation GRbspline;
