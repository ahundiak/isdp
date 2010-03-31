/* ###################   APOGEE COMPILED   ################## */
class implementation ECdrawrngbx;

/* HISTORY:

   Vadiraj 20/05/92   Modified for message subsystem compliance */	   

#include "EMS.h"
# include "OMerrordef.h"
# include "grdpbmacros.h" /* gr$get_active_display */
# include "griodef.h"
# include "igrdef.h"
# include "codef.h"
# include "msdef.h"
# include "emsdef.h"
# include "emserr.h"
# include "bserr.h"
# include "EC_I.h"

%safe
 IGRushort draw_boxes_around_the_range = 0;
%endsafe

#define BIT1 0x1

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
 IGRlong stat_OM;
 void EFtoggle();

  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  
  (void) EFtoggle(BIT1, &draw_boxes_around_the_range);
  
  if(draw_boxes_around_the_range)
     ex$message(msgnumb=EMS_I_RngBoxDrwn) 
  else
     ex$message(msgnumb=EMS_I_RngBoxNotDrwn);

ret_end:
  return (stat_OM);
}

end implementation ECdrawrngbx;

