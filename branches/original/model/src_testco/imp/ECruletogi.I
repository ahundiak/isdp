/* ###################   APOGEE COMPILED   ################## */
class implementation ECruletog;

/*
   HISTORY
   
   09-July-91  Jack  Creation
   29-Aug-91   Jack  Added status message(on/off).
   08/14/94    scw   clarified sleep method

   Notes : This command will toggle the rule line display for 
           a specified window.
               Vadiraj 06/10/92 Modified for message subsystem compliance.   

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
#include "codpdef.h"
#include "griodef.h"
#include "grio.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EMSdpb.h"
# include "griomacros.h"    /* co$getevent */
#include "igrdef.h"
#include "dpmacros.h"       
# include "EMSlogic.h"      /* EMSokay */
#include "EC_P.h"

#define DEBUG 0
#if DEBUG
#include <stdio.h>                      /* Needed for print statements */
#endif


/* command states */
#define BEGIN_STATE             0
#define IDENTIFY_WINDOW         1



#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn COintplane error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    goto wrapup;\
   }\
 }
#endif





method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{
  ex$message(msgnumb = EM_M_TgRlLnDs )
  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{


  IGRint  number_ids,
          num,
          inq_flags = 0,
          set_flags[2];
  IGRlong mask,
          sts = OM_S_SUCCESS,
          EMmsg = MSSUCC,
          which_error, 
          num_bytes;
  struct  GRevent event;
  extern int EFrule_lines_on_off();
  struct GRid gg_ids[MAX_WINDOW];
  struct var_list varlist[2];    


  mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_TEXT_VALUE;

/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {
/*
 * Room for growth
 */
     case BEGIN_STATE:
      ME.super_cmd->state = IDENTIFY_WINDOW;
      break;
/*
 * Get the window
 */
     case IDENTIFY_WINDOW:

      sts = co$getevent (
            msg = &EMmsg,
            event_mask = mask,
            msgnum = EMS_P_IdentWin,
            response = response,
            response_data = response_data,
            event = &event
        );
      ERROR(sts, EMmsg, "co$getevent error");

      if (event.response == GR_UNKNOWN_TYPE)
       {
       sts = OM_S_SUCCESS;
       goto wrapup;
       }
      else if (event.response == EX_BACK_UP)
        ME.super_cmd->state = BEGIN_STATE;
      else if (event.response == EX_RJT_MOVEON)
        ME.super_cmd->state = BEGIN_STATE;
      else if (event.response == EX_STRING)
        {
          dp$get_gragad_id(msg         = &EMmsg, 
                           name        =  event.event.keyin,
                           array_size  =  MAX_WINDOW,                           
                           numberofids = &number_ids,
                           found_GRids =  gg_ids);           

          varlist[0].var = GRAGAD_FLAGS;
          varlist[0].num_bytes = sizeof(IGRint);
          varlist[0].bytes_returned = &num_bytes;
          varlist[1].var = END_PARAM;
          set_flags[0] = DP_NO_RULE_LINES;

          for(num=0; num < number_ids; num++)
            {
             varlist[0].var_ptr = (IGRchar *)&inq_flags;
             varlist[0].num_bytes = sizeof(IGRint);
             dp$inq_set_gragad(msg = &EMmsg,
                               inq0_set1 = 0, /* inquire only */
                               osnum = gg_ids[num].osnum,
                               gragad_objid = gg_ids[num].objid,
                               which_error = &which_error,
                               var_list = varlist);
             ERROR(1, EMmsg, "dp$inq_set_gragad");

             /* toggle the rule line flag */
             if(inq_flags & DP_NO_RULE_LINES)
                  set_flags[1] = 0;
             else set_flags[1] = DP_NO_RULE_LINES;


             varlist[0].var_ptr = (IGRchar *)set_flags;
             varlist[0].num_bytes = sizeof(IGRint) * 2;             
             dp$inq_set_gragad(msg = &EMmsg,
                               inq0_set1 = 1, /* set */
                               update = 1,
                               osnum = gg_ids[num].osnum,
                               gragad_objid = gg_ids[num].objid,
                               which_error = &which_error,
                               var_list = varlist);
             ERROR(1, EMmsg, "dp$inq_set_gragad");
              
            /* display the appropriate status message */
            if(inq_flags & DP_NO_RULE_LINES)
               ex$message(msgnumb = EMS_S_RuleOn )
            else 
               ex$message(msgnumb = EMS_S_RuleOff )  

            }

        }
      else if (event.response == EX_DATA)
        {
          varlist[0].var = GRAGAD_FLAGS;
          varlist[0].var_ptr = (IGRchar *)&inq_flags;
          varlist[0].num_bytes = sizeof(IGRint);
          varlist[0].bytes_returned = &num_bytes;
          varlist[1].var = END_PARAM;
          set_flags[0] = DP_NO_RULE_LINES;

          dp$inq_set_gragad(msg = &EMmsg,
                            inq0_set1 = 0, /* inquire only */
                            osnum = event.event.button.osnum,
                            gragad_objid = event.event.button.objid,
                            which_error = &which_error,
                            var_list = varlist);
          ERROR(1, EMmsg, "dp$inq_set_gragad");
 

          /* toggle the rule line flag */
          if(inq_flags & DP_NO_RULE_LINES)
             set_flags[1] = 0;              
          else 
             set_flags[1] = DP_NO_RULE_LINES;              


          varlist[0].var_ptr = (IGRchar *)set_flags;
          varlist[0].num_bytes = sizeof(IGRint) * 2;
          dp$inq_set_gragad(msg = &EMmsg,
                            inq0_set1 = 1, /* set */
                            update = 1,
                            osnum = event.event.button.osnum,
                            gragad_objid = event.event.button.objid,
                            which_error = &which_error,
                            var_list = varlist);
          ERROR(1, EMmsg, "dp$inq_set_gragad");

          /* display the appropriate status message */
          if(inq_flags & DP_NO_RULE_LINES)
             ex$message(msgnumb = EMS_S_RuleOn )
          else 
             ex$message(msgnumb = EMS_S_RuleOff )  

        }

   break;

/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
      break;
    }
  }
 while(TRUE);


wrapup:
  return(sts);


}

method super_cmd.sleep (IGRint pos)
{
  ex$message(msgnumb = EMS_P_ClearPromptField);
  ex$message(msgnumb = EM_M_ClearMessageField);

  return (OM_S_SUCCESS);
}

end implementation ECruletog;
