/* $Id: grpeventi.I,v 1.2 2001/01/13 00:23:56 hans Exp $ */
/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/grnuc/grpeventi.I
 *
 * Description:
 *
 * Revision History:
 *	$Log: grpeventi.I,v $
 *	Revision 1.2  2001/01/13 00:23:56  hans
 *	SP16 modifications
 *	
 *
 * Dependencies:
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/19/00        Rama Rao        Code change for "Elements in
 *					Current File" command.
 ***************************************************************************/

class implementation COgrpevent;

#include "coimport.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "exdef.h"

method build_locate_criteria ( long * sts )
{
  int		  status = OM_S_SUCCESS;

OMuword        GRgraphics_classid;
IGRint         criteria_flag;
IGRint         i;

   /*
    *  Get the locate criteria.
    */

   status = gr$gsget_locate_criteria ( msg = sts,
            locate_env = &me->locate_env,
            criteria_flag = &criteria_flag,
            attributes = &me->attributes,
            rtree_classes = &me->locate_rtree_thing,
            eligible_classes = &me->locate_eligible_thing);

   if (!(criteria_flag & GSPUT_LOCATE_ENV))
   {
      me->locate_env = me->ModuleInfo;
   }

   if (!(criteria_flag & GSPUT_ATTRIBUTES) || !strcmp(me->cmd_key, "GRSlAlF") )
   {
      strcpy (me->attributes.classes,"GRgraphics");
      me->attributes.properties = LC_LC_ONLY |
                                  LC_RW |
                                  LC_DP_ONLY |
                                  IGN_MOD_BIT |
                                  IGN_PLANAR_BIT;

      me->attributes.owner_action =  LC_RIGID_OWNER |
                                     LC_FLEX_COMP;
   }

   if ( (!(criteria_flag & GSPUT_RTREE_CLASSES)) ||
        (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES)))
   {
      status = om$get_classid (classname = "GRgraphics",
               p_classid = &GRgraphics_classid);

      if (!(criteria_flag & GSPUT_RTREE_CLASSES))
      {
         me->locate_rtree_thing.w_count = 1;
         me->locate_rtree_thing.w_flags = OM_CLST_subclass;
      }

      if (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES))
      {
         me->locate_eligible_thing.w_count = 1;
         me->locate_eligible_thing.w_flags = OM_CLST_subclass;
      }
   }

   /*
    * allocate space for and copy the rtree and eligible classids
    */

   if (me->locate_rtree_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->rtree_classids,
                                    size = me->locate_rtree_thing.w_count);

      if (criteria_flag & GSPUT_RTREE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_rtree_thing.w_count; ++i)
         {
            me->rtree_classids[i] = me->locate_rtree_thing.p_classes[i];
         }
      }
      else
      {
         me->rtree_classids[0] = GRgraphics_classid;
      }
   }

   if (me->locate_eligible_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->eligible_classids,
                                    size = me->locate_eligible_thing.w_count);

      if (criteria_flag & GSPUT_ELIGIBLE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_eligible_thing.w_count; ++i)
         {
            me->eligible_classids[i] = me->locate_eligible_thing.p_classes[i];
         }
      }
      else
      {
         me->eligible_classids[0] = GRgraphics_classid;
      }
   }

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   me->locate_rtree = &me->locate_rtree_thing;
   me->locate_eligible = &me->locate_eligible_thing;
quit:
  return OM_S_SUCCESS;
}

end implementation COgrpevent;
