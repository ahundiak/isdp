class specification APPcolor (1:0) of Root;

#include "wl.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igecolor.h"

   instance APPcolor
   {
      channel { (one_to_one) IGEcolor;} to_igecolor;
   };
           
   /* MESSAGES */
   
   message load_color_table(IGRint   *num_colors; IGRint *num_shades;
             IGRint   *calc_shades; IGRint (**shade_func)();
             IGRint screen_no; IGRint total_vlt_slots);

   
end specification APPcolor;

