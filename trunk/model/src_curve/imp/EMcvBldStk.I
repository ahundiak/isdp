/* ###################   APOGEE COMPILED   ################## */
class implementation GRcurve;

#include "EMS.h"
#include <stdio.h>
#include "msdef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EMSasdef.h" /* For ASSOC */
#include "ma2ptdis.h"

extern OMuword OPP_GRcompcurve_class_id;

#if ASSOC
extern OMuword OPP_ASnode_class_id;
#endif

method EMbuild_stack (
   IGRlong          *msg;
   IGRpoint         search_pt;
   struct GRid      original_cv;
   IGRdouble        generic_tol;
   IGRdouble        closed_tol;
   IGRint           *active_levels;
   struct GRmd_env  *module_info;
   struct GRlc_stack *stack)
/*
Abstract
     This method checks if the curve objects satisfies
     the selection criterion. If so, it puts itself
     on the stack.

Algorithm
     The criterion for selction of an object follows

      1) If LOCATABLE and level is on, goto new step. 
         Otherwise, trivially reject the object.

      2) If the object is already a part of the composite
         curve under consideration, reject the object.

      3) If the curve object is part of the composite curve,
         pass the message to the owner composite curve and let
         owner make the decision.

      4) If the curve object is a closed object (physically
         or its end points within closed tolerance), reject it.

      5) If the one of the end points of the curve object and
         search point are within the tolerance and it passes
         the above criteria, it should be placed on the stack.

History
         RC  2/02/87 : Creation date
         RC  11/30/87 : Modified such that composite curve is put
                        on stack if I am a part of composite curve.
         RC  03/11/88 : If I am a composite curve, donot check
                        LOCATABLE and DISPLAYABLE properties.
         PP  11/11/88 : Do not locate associative wireframe elements
                        because they do not behave correctly with
                        composites.
    Sudha  06/16/93     Modified for BSprototype ansification

*/
{
   IGRboolean   is_possible_candidate = FALSE, status;
   IGRboolean   valid_entry = FALSE;
   OMuint       owners;
   IGRint       EMsort(),  dum_count, i;
   IGRlong      mthd_stat;
   IGRlong   OM_stat;
   OMuword      my_classid;
   IGRpoint     start_pt, end_pt;
   IGRdouble	distance;


   OM_S_CHANSELECT to_owners;	

   struct GRlc_info new_entry;

   OM_stat = OM_S_SUCCESS;
   *msg = MSSUCC;
	
   to_owners.type = OM_e_addr;
   to_owners.u_sel.addr = &ME.GRconnector->to_owners;

   OM_stat = om$get_classid (object = me, p_classid = &my_classid);
   EMerr_hndlr (!(1&OM_stat),*msg, EMS_E_OMerror,wrapup);

#if ASSOC

/*
 * Begin change to not locate associative wireframe elements
 */


   OM_stat = om$is_ancestry_valid(subclassid = my_classid,
                                  superclassid = OPP_ASnode_class_id);
   EMerr_hndlr (!(1&OM_stat),*msg,EMS_E_OMerror,wrapup);

   if (OM_stat == OM_S_SUCCESS)
   {
    goto wrapup;
   }
   else if (OM_stat == OM_I_INVANCESTRY)
   {
    OM_stat = OM_S_SUCCESS;
   }

/* end change to not locate as wireframe elements pp 11/10/88 */

#endif

   if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE) goto wrapup;

   OM_stat = om$is_ancestry_valid (subclassid = my_classid, 
                       superclassid = OPP_GRcompcurve_class_id);
   EMerr_hndlr (!(1&OM_stat),*msg,EMS_E_OMerror,wrapup);

   if (OM_stat == OM_I_INVANCESTRY)
   {
     /* 
      * find out if I am locatable and displayable or not.
      *  if not, return with success without doing anything.
      */
	
     if (!(ME.GRgraphics->properties & GRIS_LOCATABLE)) goto wrapup;
     if (!(ME.GRgraphics->properties & GRIS_DISPLAYABLE)) goto wrapup;

     /* 
      * check for level
      */

     if (! DPlevel_check(me->level,active_levels)) goto wrapup;

   } /* if (OM_stat == OM_I_INVANCESTRY) */

   /*
    * find out if the curve being worked upon is me or not.
    * If it is me, return with success.
    */

   if ((original_cv.objid == my_id )  &&
       (original_cv.osnum == OM_Gw_current_OS)) goto wrapup;

   /*
    * find out if have any owners across to_owners channel
    * if so, is one of them a composite curve ?
    *  if so, let the composite curve decide whether
    *  to put itself on the stack or not
    */

   OM_stat = om$get_channel_count (object = me,
                          p_chanselect = &to_owners, count = &owners);
   EMomerr_hndlr(OM_stat, wrapup, "EMcvbldstk : get_channel_count" );

   if (owners > 0)
   {
      dum_count = 0;
      for (i = 0; i < owners; ++i)
      {
        OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_owners,
                            from = i, to = i);
        if (! (1 & OM_stat)) ++dum_count;
      }
	
      /*
       * if none of my owners recognized the message,
       * I am not a part of a composite curve
       */

      if (owners == dum_count) is_possible_candidate = TRUE;

   } /* if (owners > 0) */

   else   /* I am an orphan */
      is_possible_candidate = TRUE;

   /*
    * if I am a possible candidate,
    * find out the distance between my end points and
    * the search point. If this distance is <= search_tol
    * and the distance between my end points is not less
    * than closed_tol, I should be put on stack.
    */
	
   if (is_possible_candidate)
   {
      OM_stat = om$send (msg = message GRcurve.GRendpts (&mthd_stat,
                          &module_info->md_env.matrix_type,
                           module_info->md_env.matrix, start_pt, end_pt),
                         targetid = my_id);
      EMomerr_hndlr(OM_stat, wrapup, "EMcvbldstk :GRendpts" );
      EMerr_hndlr(!(1 & mthd_stat), *msg, mthd_stat, wrapup);
	   	   
      /*
       * find out if my end points are within closed_tol. 
       * If so, I should not be considered as a possible candidate
       */

      status = MA2ptdis (&mthd_stat, start_pt, end_pt, &distance);
      EMerr_hndlr((!(1 & mthd_stat) || !status), *msg, mthd_stat, wrapup);

      if (!(distance <= closed_tol))
      {
         status = MA2ptdis (&mthd_stat, start_pt, search_pt, &distance);
         EMerr_hndlr((!(1&mthd_stat) || !status),*msg, mthd_stat, wrapup);

         if (distance <= generic_tol) valid_entry = TRUE;
         else
         {
            status = MA2ptdis (&mthd_stat, end_pt, search_pt, &distance);
            EMerr_hndlr((!(1&mthd_stat)|| !status),*msg,mthd_stat,wrapup);

            if (distance <= generic_tol) valid_entry = TRUE;
         }

      } /* if (!(distance <= closed_tol)) */

      if (valid_entry)
      {
         new_entry.module_info = *module_info;
         new_entry.proj_pnt[0] = distance;
         new_entry.located_obj.objid = my_id;
         new_entry.located_obj.osnum = module_info->md_id.osnum;
         if (! EMsort(stack, &new_entry))
         {
            *msg = MSFAIL;
            goto wrapup;
         }
      }
	
   } /* if (is_possible_candidate) */


wrapup:

	return (OM_stat);

}

end implementation GRcurve;
