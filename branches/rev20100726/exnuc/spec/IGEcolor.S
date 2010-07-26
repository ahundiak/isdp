class specification IGEcolor (1:0) of global_class;

#include "wl.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igecolor.h"
#ifndef X11
#include <tools.h>
#endif

   instance IGEcolor
   {
      IGRint      fg_color;
      IGRint      bg_color;
      IGRint      hilite_color;
      IGRshort      num_colors;
      IGRshort      num_names;
      variable   IGRint      colors[7];
      variable   struct IGEcol_names   names[7];
      channel      { (rel_ordered, one_to_many,initial = 1, increment = 1) APPcolor; } 
             to_appcolor;
      channel      { (one_to_many,initial = 1, increment = 1) IGEcolsup; } 
             notify;
   };

   override wake_up,debug;

   /* MESSAGES */

   message app_con(IGRint type; GRobjid appcolor_objid; 
                 GRspacenum appcolor_osnum);
   
   message get_data_for_IGEcolor2(
      IGRshort  *num_colors_returned;  
      IGRint *colors;
      IGRint *num_ramp_colors);  
   
end specification IGEcolor;

