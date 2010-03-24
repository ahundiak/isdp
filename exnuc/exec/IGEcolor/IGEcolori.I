/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:38:41 $
$Locker:  $
*/
class implementation IGEcolor;

#include <stdio.h>
#include <string.h>

#include "exmacros.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "igewindef.h"
#include "msdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"

extern OMuword OM_Gw_current_OS;
from APPcolor import  load_color_table;
from IGEcolor2 import set_data_for_IGEcolor2;

/************************ wake_up ******************************/

method  wake_up()
{
   IGRint   sts = 1;
   IGRshort   num_colors_returned;
   IGRint   colors[512];
   OM_S_OBJID   IGEcolor2_id,module_id;
   OMuword     super_osnum;
   IGRint     num_ramp_colors;
    
   if (!ex$is_invis(mod_osnum = OM_Gw_current_OS) && !ex$is_temp_wakeup())
   {
       sts = ex$get_modid ( mod_osnum = OM_Gw_current_OS, 
                  mod_id = &module_id );
       sts = ex$get_super(mod_id = module_id,
                          mod_osnum = OM_Gw_current_OS,
                          super_name = "IGECOLOR2",
                          create = TRUE,
                          super_class = "IGEcolor2",
                          super_id = &IGEcolor2_id,
                          super_osnum = &super_osnum,
                          wakeup_flag = 0);

      sts = om$send(msg = message IGEcolor.get_data_for_IGEcolor2(
            &num_colors_returned,colors,&num_ramp_colors),
         targetid=my_id);
      sts = om$send(msg = message IGEcolor2.set_data_for_IGEcolor2(
            num_colors_returned,colors,
            me->num_names,me->names,num_ramp_colors ),
         targetid=IGEcolor2_id);
      sts = om$send(msg = message IGEcolor2.wake_up(),
         senderid=IGEcolor2_id,
         targetid=IGEcolor2_id);
      sts = om$send(msg = message IGEcolor.delete(0),
         targetid=my_id);
   }

   return(sts);
}

/******************* app_con ******************************/

method app_con(IGRint type; GRobjid appcolor_objid; GRspacenum appcolor_osnum)

{
   IGRint      status;
   OM_S_CHANSELECT   to_chandef;
   OM_S_CHANSELECT   fr_chandef;

   if (type == IGECOLAPP)
   {
      fr_chandef.type = OM_e_addr;
      fr_chandef.u_sel.addr = &ME.IGEcolor->to_appcolor;
      to_chandef.type = OM_e_name;
      to_chandef.u_sel.name = "APPcolor.to_igecolor";
   }
   else
   {
      fr_chandef.type = OM_e_addr;
      fr_chandef.u_sel.addr = &ME.IGEcolor->notify;

      to_chandef.type = OM_e_name;
      to_chandef.u_sel.name = "IGEcolsup.listener";
   }

   status = om$send(msg = message Root.connect(to_chandef,NULL,my_id,
                   OM_Gw_current_OS,fr_chandef,
                   OM_K_MAXINT),
          targetid = appcolor_objid,
          targetos = appcolor_osnum);

   if (!(1 & status)) 
   {
#ifdef   DEBUG_CL
      om$report_error(sts = status);
#endif
      goto wrapup;
   }

wrapup:
   return(status);
}

/********************* debug ******************************/

method debug()
/*
DESCRIPTION
   Print out instance data
*/

{ 
   int i;

   fprintf( stderr, "IGEcolor INSTANCE DATA\n\n" );
   fprintf( stderr, "   FOREGROUND COLOR:    %d\n", me->fg_color);
   fprintf( stderr, "   BACKGROUND COLOR:    %d\n", me->bg_color);
   fprintf( stderr, "   HIGHLIGHT COLOR:    %d\n", me->hilite_color);
   fprintf( stderr, "   NUMBER OF COLORS:    %d\n", me->num_colors);
   fprintf( stderr, "   NUMBER OF NAMES:    %d\n", me->num_names);

   fprintf( stderr, "\n");
   fprintf( stderr,     "   COLORS:        %3d%13d\n", 0, me->colors[0] );
   for (i=1; i<me->num_colors; i++)
       fprintf( stderr, "                  %3d%13d\n", i, me->colors[i] );
   
   fprintf( stderr, "\n");
   fprintf( stderr,     "   NAMES:         %s   %d\n", 
       me->names[0].name, me->names[0].index );
   for (i=1; i<me->num_names; i++)
       fprintf( stderr, "                  %s   %d\n", 
           me->names[i].name, me->names[i].index );

   return( OM_S_SUCCESS );

}  /* debug */

method get_data_for_IGEcolor2(
      IGRshort  *num_colors_returned;  
      IGRint *colors;
      IGRint *num_ramp_colors)  
{
   IGRint sts = 1;
   IGRint i,j;
   IGRint total_slots;
   IGRint screen_no;
   IGRint num_colors;
   IGRint size_colors;
   IGRint num_shades;
   IGRint calc_shades;
   IGRint (*shade_func)();
   IGRint count;
   OM_S_CHANSELECT   chandef;
   
   sts = om$make_chanselect (channame = "IGEcolor.to_appcolor", 
      p_chanselect = &chandef);
   
   sts = om$get_channel_count(objid = my_id, 
         p_chanselect = &chandef, 
   count = (OMuint *)&count);

   num_colors = 240;
   num_shades = NO_SHADES;
   *num_ramp_colors = 10;
   calc_shades = TRUE;
   shade_func = NULL;
   screen_no = IGE_RIGHT_SCREEN;
   total_slots = 256;/* 53093 doesn't matter for HSctbl2 */

   if (count)
   {
      /* just querying to see if calc_shades or not */
      sts = om$send(msg = message APPcolor.load_color_table(
               &num_colors,
               &num_shades,
               &calc_shades,
               &shade_func,
               screen_no,
               total_slots),
            senderid = my_id, 
            p_chanselect = &chandef,
            from = (count - 1),
            to = (count - 1));
      sts = om$send(msg = message APPcolor.delete(0),
            senderid = my_id, 
            p_chanselect = &chandef,
            from = (count - 1),
            to = (count - 1));

      if (calc_shades)
      {
         /* reset to 240 for case if they had developed a color table
            on an Edge2 and saved on a rop... preserve 240 colors */
         num_colors = 240;
      }
   }


   /*   colors will be: bg-logical_colors-hl      */
   /*   bg      0            */
   /*   logical colors   1..num_colors_returned-2   */
   /*   hilite      num_colors_returned-1      */
   size_colors = om$dimension_of( varray = me->colors );
   if (calc_shades)
   {
      if (num_colors > size_colors)
      {
         /* this is an error check to make sure that the forced 240 colors
            is not more than are stored with the object */
         num_colors = size_colors;
      }
      /*system calculates shades.  Grab entire colors array*/
      colors[0] = me->bg_color;
      for (i = 0; i < num_colors; i++)
      {
         colors[i + 1] = me->colors[i];
      }
      colors[num_colors + 1] = me->hilite_color;
      *num_colors_returned = num_colors + 2;
   }
   else
   {
      if (num_colors * num_shades > size_colors)
      {
         /* this is an error check to make sure that the number of colors
            is not more than are stored with the object */
         num_colors = size_colors / num_shades;
      }
      /*user shades.  Grab just base colors*/
      colors[0] = me->bg_color;
      for (i = 0, j = 1; j <= num_colors; i += num_shades)
      {
         colors[j++] = me->colors[i];
      }
      colors[j++] = me->hilite_color;
      *num_ramp_colors = num_colors;
      *num_colors_returned = j;
   }

   return(sts);
}

end implementation IGEcolor;
