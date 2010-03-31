
/* 
HISTORY:

6/01/92: Rustagi  Modified for Message Sub-system Compliance
5/19/92: NP	  Added option to print timing results of ALL timers defined
		  in the code, rather that just one timer. Also, when any timer
		  is initialized, the "_use_timers" global variable is set to
		  true, so that ALL timers are activated.
*/

class implementation ECtimer;

#include "EMS.h"
#include <stdio.h>
#include "OMerrordef.h"
#include "griodef.h"
#include "igrdef.h"
#include "codef.h"
#include "emserr.h"
#include "griomacros.h"
#include "timerdef.h"
#include "EC_M.h"
#include "EC_S.h"

extern IGRboolean _use_timers;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong msg_loc;
  struct GRevent event;
  IGRint clock_num, event_size,i;

  /* These strings are used by the command object to meaningfully output
   * the results of all the timers defined in "timerdef.h".
   */

  IGRchar timer_strings[MAX_TIMERS][TIMER_STRING_MAX]=
   {
    /*0,  T_EMJOININGBOOLEAN  */
          "Time for EMjoiningBoolean",
    /*1,  T_EMINTERSECT_SURFACES*/
  	  "Time for EMintersect_surfaces", 
    /*2,  T_EMBOOLEAN_SURFACES_W_INTERSECTION*/
 	  "Time for EMboolean_surfaces_w_intersection",
    /*3,  T1_SFSFINT */ 
	  "Time for sfsfint in intersect_surfaces",
    /*4,  T1_FIXSFINTOUTS */
	  "Time for all fixsfintouts in intersect_surfaces",
    /*5,  T1_TRACE */
	  "Time for trace in intersect_surfaces",
    /*6,  T1_REFINE */
	  "Time for refine in intersect_surfaces",
    /*7,  T2_TOPOLOGY_VALIDATE */
	  "Time for topology validate in bool.srf.w.intr",
    /*8,  T2_SPLIT_EDGES */
	  "Time for edge split in bool.srf.w.intr",
    /*9,  T2_CLOSE_LOOPS*/
	  "Time for close loops in bool.srf.w.intr",
    /*10, T2_CLEANUP */
	  "Time for cleanup in bool.srf.w.intr",
    /*11, T2_SAVE_STATE_AND_BOOLINIT */
	  "Time for save state/boolinit in bool.srf.w.intr",
    /*12, T_EMSFSFINT */
	  "Time for EMsfsfint",
    /*13, T12_GET_INT_DATA */
	  "Time for get_int_data in sfsfint",
    /*14, T12_FULLTRIM */
	  "Time for fulltrim in sfsfint",
    /*15, T12_ORIENT_AND_MKINTDATA */
	  "Time for orient and mkintdata in sfsfint",
    /*16, T12_BDRYINT */
	  "Time for bdryint (coplanar processing) in sfsfint",
    /*17, T_EMGETINTDATA */
	  "Time for EMget_int_data",
    /*18, T17_BSSFSFINT */
	  "Time for bssfsfint in get_int_data",
    /*19, T17_FIX_INTERSECTIONS*/
	  "Time for fix_the_int, additpts etc. in get_int_data",
    /*20,  T2_UNSPLIT_EDGES*/
	  "Time for unsplit edges in bool.srf.w.intr" ,
    /*21,  T_CLOSEYOURSELF*/
	  "Time for loop closeyourself",
    /*22,  T21_CREATE_LOOP*/
	  "Time for creating new loop in closeyourself",
    /*23,  T21_NEST_LOOP*/
	  "Time for nesting new loop in closeyourself",
    /*24,  T_EMNESTING*/
	  "Time for EMnesting",
    /*25,  T24_PT_LOCATION */
	  "Time for pt location in nesting",
    /*26,  T_EM_PT_LOCATION */
	  "Time for EMpt_location",
    /*27,  T_EMLSFULLTRIM */
	  "Time for EMlsfulltrim",
    /*28,  T27_PARTTRIM */
	  "Time for my/other parttrim in fulltrim",
    /*29,  T27_MAP_BOUNDARY */
	  "Time for map boundary in fulltrim",
    /*30,  T_EMLSPARTTRIM */
	  "Time for EMlsparttrim",
    /*31,  T30_TRIM_AGAINST_BOUNDARY */
	  "Time for trimming againt bdry in lsparttrim",
    /*32,  T30_PT_LOCATION */
	  "Time for pt location in lsparttrim",
    /*33,  T30_MKPYBDRYSL */
	  "Time for mkpybdrysl in lsparttrim",
    /*34,  T_MKPYBDRYSL */
	  "Time for EMmkpybdrysl",
    /*35,  T34_PT_LOCATION */
	  "Time for pt location in mkpybdrysl",
    /*36,  T34_POINT_NESTING */
	  "Time for pt nesting in mkpybdrysl",
    /*37,  T_EMPTNESTING */
	  "Time for EMptnesting",
    /*38,  T37_PT_LOCATION */
	  "Time for pt location in ptnesting", 
    /*39,  T_EMMAKE_COMP */
	  "Time for stitching",
    /*40,  T12_GETRANGE */
	  "Time for get-range in sfsfint",
    /*41,  T_EMROUND */
	  "Time for EMround"
};


  if (ME.super_cmd->mytype == 0)
    ex$message(msgnumb=EM_M_TimerInit)
  else
    ex$message(msgnumb=EM_M_Timertot);

  *response = TERMINATE;
  event_size = sizeof (struct GRevent);

  do
    {
      if (ME.super_cmd->mytype == 0)
      {
        co$getevent (msg = &msg_loc, event_mask = GRm_VALUE|GRm_RJT_MOVEON,
         value_type = GRIO_SCALAR,prompt = "Input clock number/Move on for all",
         response = response, response_data = response_data, event = &event);

      if (event.response == GR_UNKNOWN_TYPE)
        {
          ex$message(msgnumb=EMS_S_NoWay);
          continue;
        }
      else if (event.response == EX_RJT_MOVEON)
        {
          /* init ALL timers*/
          for (i=0; i<MAX_TIMERS; i++)
	    init_timer(i);
          /* activate all timers, if not already done so */
          if (!_use_timers)
             _use_timers = TRUE;
          *response = TERMINATE;
          return (OM_S_SUCCESS);
        }
      else if (event.response == VALUE)
        {
          clock_num = event.event.value;
          init_timer (clock_num);
          /* activate all timers, if not already done so */
          if (!_use_timers)
             _use_timers = TRUE;
          *response = TERMINATE;
          return (OM_S_SUCCESS);
        }
      else
        return (OM_S_SUCCESS);
      }
    else if (ME.super_cmd->mytype == 1)
      {
        co$getevent (msg = &msg_loc, event_mask = GRm_VALUE|GRm_RJT_MOVEON,
         value_type = GRIO_SCALAR,prompt = "Input clock number/Move on for all",
         response = response, response_data = response_data, event = &event);

      
      if (event.response == GR_UNKNOWN_TYPE)
        {
          ex$message(msgnumb=EMS_S_NoWay);
          continue;
        }
      else if (event.response == EX_RJT_MOVEON)
        {
          /* total ALL timers*/
          for (i=0; i<MAX_TIMERS; i++)
            total_timer (i, timer_strings[i]);
          /*print boolean data to file /tmp/bool.time*/
          print_boolean_data();
          *response = TERMINATE;
          return (OM_S_SUCCESS);
        }
      else if (event.response == VALUE)
        {
          clock_num = event.event.value;
          if ((clock_num >= MAX_TIMERS) || (clock_num <0))
	  {  fprintf (stderr, "Timer number %d is NOT defined..\n", clock_num);
             ex$message(msgnumb=EMS_S_InpTNtDef);
             continue;
          }
          total_timer (clock_num, timer_strings[clock_num]);
          *response = TERMINATE;
          return (OM_S_SUCCESS);
        }
      else
        return (OM_S_SUCCESS);
      }
    }
  while (TRUE);

ret_end:
  return (OM_S_SUCCESS);
}

end implementation ECtimer;
