class implementation ECround;

/*
HISTORY

04/23/91         DLB         use ems$getevent and stuff into edgeval_event.
April, 1991      AMD         Creation
May 31st, 1992   Vadiraj     Modified for message subsystem compliance. 
*/

#include "griomacros.h"
#include "EMSasmacros.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_E.h"
#include "EC_I.h"

#define RNDEDGE 0
#define RNDVERT 1

IGRlong EFedgeval( msg, response, response_data, mytype, event)

IGRlong            *msg;
IGRint             *response;
IGRchar            *response_data;
IGRint             mytype;
struct  GRevent    *event;

 {
   IGRboolean  stat_func; 
   IGRlong sts = OM_S_SUCCESS;
   IGRchar  locate_prompt[52];

   do
    { 
      if (mytype == RNDEDGE || mytype == RNDVERT)
        ex$message(msgnumb = EMS_P_EntRndRds, buff = locate_prompt)
      else
         ex$message(msgnumb = EMS_P_EntStbckDist, buff = locate_prompt);

      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                 in_buff = locate_prompt);
   
      stat_func = ems$getevent (
                  msg = msg,
                  event_mask = GRm_VALUE | GRm_BACK_UP,
                  value_type = GRIO_DISTANCE,
                  response = (IGRlong *)response,
                  response_data = response_data,
                  event = event
                  );

/******************************
      stat_func = co$getevent (
                  msg = msg,
                  event_mask = GRm_VALUE | GRm_BACK_UP,
                  value_type = GRIO_DISTANCE,
                  response = response,
                  response_data = response_data,
                  event = event
                  );
*******************************/

      ex$message(msgnumb=EMS_P_ClearPromptField);
      if (stat_func == FALSE)
       {
        ex$message(msgnumb=EMS_E_FailInputProcExit)
        *response = TERMINATE;
        goto wrapup;
       }
      if ( *msg == GRw_no_value)
       {
        ex$message(msgnumb=EMS_I_00006)
        sleep(2);
        continue;
       }
      if ( event->response == GR_UNKNOWN_TYPE )
       {
        ex$message(msgnumb=EMS_S_IgnUnknownIp)
        continue;
       }
  
      switch(event->response)
       {
        case EX_VALUE:
         if (event->event.value <= 0)
          {
           ex$message(msgnumb=EMS_S_DistMustBeGrtThanZero)
           break;
           } 
        default:
           goto wrapup;
       }
  } while (event->response != EX_VALUE); 

wrapup:
  return (sts);
 
}

end implementation ECround;
