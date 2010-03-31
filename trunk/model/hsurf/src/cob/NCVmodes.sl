/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

/*
DESCRIPTION
   Command object to set the NC Verification modes.


HISTORY
   09/19/88   CMJ   Created
*/


class              NCVmodes
super_class        CEO_LOCATE
command_string     HSM_M_StShVrPr,0,HSStShVrPr
product_name       "$MODEL"
start_state        start


specification

#include "hsncdef.h"
#include "hsncmacros.h"

implementation

#define SIMULATION      5001
#define INVALID_CHOICE  6001
#define INVALID_VALUE   6002
#define FINISHED        6003

#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"


state_table

#include "hsmsg.h"

#define SIMULATION      5001
#define INVALID_CHOICE  6001
#define INVALID_VALUE   6002
#define FINISHED        6003
#define erase           0


state    *         
   on EX_RJT_MOVEON
      state .
   on EX_RESTART
      state .


state        start
message_key  HSM_M_StShVrPr
prompt_key   HS_P_NCVSetDispMode
filter       get_event

   on EX_DATA
      state .
   on EX_STRING
      do set_display_mode( sts )
         on INVALID_CHOICE
            state .
         on SIMULATION
            state simulation_speed
         on ELSE
            state shading_style
      state .
   on EX_BACK_UP
      state .

state   simulation_speed
prompt_key   HS_P_NCVSetSimSpd
filter      get_event

   on EX_DATA
      state .
   on EX_STRING
      do set_simulation_speed( sts )
         on INVALID_VALUE
            state .
         on ELSE
            state shading_style
      state .
   on EX_BACK_UP
      state .

state       shading_style
prompt_key  HS_P_NCVSetShdSty
filter      get_event

   on EX_DATA   state .
   on EX_STRING
      do set_shading_style( sts )
         on INVALID_CHOICE
             state .
         on FINISHED
             state terminate
         on ELSE
             state terminate
      state .
   on EX_BACK_UP   state .


/*--- set_display_mode -----------------------------------------*/

action set_display_mode
{
   int   i;


   sscanf(me->event1.event.keyin, "%d", &i);

   switch (i)
   {
      case (1):   /* Swept Volume */
         hsnc$put_verification_parameters( display_mode = HSNC_SWVOL );
         break;

      case (2):   /* Swept Volume with Wireframe Tool */
         hsnc$put_verification_parameters( display_mode = HSNC_SWVOL_TOOL );
         break;

      case (0):   /* Default */
      case (3):   /* Simulation */
         hsnc$put_verification_parameters( display_mode = HSNC_SIMULATION );
         *sts = SIMULATION;
         break;

      default:
         ex$message( msgnumb = HS_E_NCVInvDispMode );
         *sts = INVALID_CHOICE;
         break;
   }
}


/*--- set_simulation_speed -----------------------------------------*/

action set_simulation_speed
{
   int   simulation_speed;


   sscanf(me->event1.event.keyin, "%d", &simulation_speed);

   if (simulation_speed == 0)
   {
      simulation_speed = HSNC_DEFAULT_SIM_SPEED;
   }

   if (hsnc$put_verification_parameters( simulation_speed = simulation_speed )
                             != HSNC_SUCCESS)
   {
      ex$message( msgnumb = HS_E_NCVInvSimSpd );
      *sts = INVALID_VALUE;
   }
}


/*--- set_shading_style -----------------------------------------*/

action set_shading_style
{
   int   i;

   sscanf(me->event1.event.keyin, "%d", &i);

   switch (i)
   {
      case (0):   /* Default */
      case (1):   /* Constant */
         hsnc$put_verification_parameters(
                                         shading_style = HSNC_CONSTANT_SHADED );
         *sts = FINISHED;
         break;

      case (2):   /* Smooth */
         hsnc$put_verification_parameters( shading_style = HSNC_SMOOTH_SHADED );
         *sts = FINISHED;
         break;

      default:
         ex$message( msgnumb = HS_E_NCVInvShdSty );
         *sts = INVALID_CHOICE;
         break;
   }
}
