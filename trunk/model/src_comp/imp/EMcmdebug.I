class implementation EMScomposite;

#include "EMScc.h"
/*
HISTORY

    DLB 10/28/89    Modified to print comp objects class names.
22 Jul 1988 jBk Modified properties print so it is obviously hex.
?           ?   Genesis.
*/

#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"

method debug ()
{
 IGRlong          OM_stat;
 OM_S_CHANSELECT  to_owners;
 IGRchar          name[OM_K_MAXCLASS_LEN];
 OMuint           count;

 to_owners.type = OM_e_addr;
 to_owners.u_sel.addr = &ME.GRconnector->to_owners;
 
 OM_stat = om$get_classname(object = me,
                            classname = name);
 if (! (1 & OM_stat)) goto wrapup;
 
 fprintf(stderr, "My class name is %s\n", name);
 fprintf(stderr, "My id is %d\n",my_id);
 fprintf(stderr, "graphics_props = 0x%x\n", (IGRushort)ME.GRgraphics->properties);

 OM_stat = om$get_channel_count(object = me,
                                p_chanselect = &to_owners,
                                count = &count);
 if (! (1 & OM_stat)) goto wrapup;

 if (count) 
 {
   if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
     fprintf (stderr, "Have a rigid owner\n");
   else
     fprintf (stderr, "Have %d flexible owner(s)\n", count);
 }    

 if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
   EFprint_assoc_info(my_id, OM_Gw_current_OS);
   
 { /*ON PURPOSE!*/
   IGRint findex=0, tindex=OM_K_MAXINT;

   EFprint_comps(my_id, OM_Gw_current_OS, &findex, &tindex);

   if (findex != OM_K_MAXINT || tindex != OM_K_MAXINT)
   {
     OM_S_CHANSELECT to_comps;

     to_comps.type = OM_e_addr;
     to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

     OM_stat = om$send(msg = message Root.debug(),
                       p_chanselect = &to_comps,
                       from = findex, to = tindex);
     if (! (1 & OM_stat)) goto wrapup;
   }
 }

 wrapup:
   return (OM_stat);
}
end implementation EMScomposite;
