/* ###################   APOGEE COMPILED   ################## */
class implementation ECmathtog;

/*
   HISTORY
   
   05-Sep-91  Jack  Creation
   08/14/94   scw   clarified sleep method

   Notes: 
   This command-object is used to toggle the OLD_MATH_ROUTINE bit
   for the global flag surface_display_flags stored in 
   $MODEL/src_gralp/imp/EFsetdisp.C.  This is temporary until we
   are satisfied enough with the new parting lines math routine,
   BSprtlngmsf(), to let it be used by default for horizon edges.
   Until then we will use the old math routine by default and 
   provide this command to toggle which is used.
   This command will be key-in only.
   I didn't utilize the message subsystem since this is only a 
   temporary command.


   27/05/92   Vadiraj Modified for message subsystem compliance.

*/

#include "EMS.h"
#include "EMSopt.h"
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "codef.h"
#include "griodef.h"
#include "grio.h"
#include "EMSdpb.h"
# include "griomacros.h"    /* co$getevent */
# include "EMSlogic.h"      /* EMSokay */
# include "EC_S.h"
# include "EC_M.h"


method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{
  ex$message(msgnumb=EM_M_ZtogHorznEdgMath);
  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{


  IGRint  option,
          turn_on;

  extern int EFold_math_routine();
  extern void EFset_surface_display();
  
  option = OLD_MATH_ROUTINE;
  if(EFold_math_routine())
    {
      ex$message(msgnumb=EMS_S_NwMathRuAct)
      turn_on = 0;
      EFset_surface_display(option,turn_on);
    }
  else
    {
      ex$message(msgnumb=EMS_S_OlMathRuAct)
      turn_on = 1;
      EFset_surface_display(option,turn_on);
    }


  *response = TERMINATE;

 return (OM_S_SUCCESS);
}

method super_cmd.sleep (IGRint pos)
{
  ex$message(msgnumb=EMS_P_ClearPromptField);
  ex$message(msgnumb=EM_M_ClearMessageField);

  return (OM_S_SUCCESS);
}

end implementation ECmathtog;
