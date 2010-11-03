/* ###################   APOGEE COMPILED   ################## */
class implementation ECdynload;

#include "EMS.h"
#include "dload.h"
/*
DESCRIPTION
        DEBUG COMMAND
        ODEN COMMAND
HISTORY

08/14/94    scw clarified sleep method
15-Mar-93       Added ems_dload() function that will accept
                the file to dload and will set the default
                options.
6/02/92 Rustagi Modified for Message Sub-system Compliance
22 May 1989 jBk Changed from use of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

                Changed from GRm_STRING mask to GRm_TEXT_VALUE.

        DLB     08/03/87    Creation date.
*/

#include <stdio.h>
#include "msmacros.h"
#include "codef.h"
#include "ECdlb.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "dpmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "EMSmsgdef.h"
#include "EMSerrordef.h"
#include "exmacros.h"
#include "emsbool.h"
#include "dpmacros.h"
# include "griomacros.h"    /* co$getevent */
#include "EC_M.h"
#include "EC_S.h"

#define LOAD 0
#define ODEN 1
#define RTREERNG 2
#define LOAD_FROM_FILE 3

method super_cmd.sleep(int pos)
{
 ex$message(msgnumb = EM_M_ClearMessageField);
 ex$message(msgnumb = EMS_S_ClearStatusField);
 ex$message(msgnumb = EMS_P_ClearPromptField);
 return(OM_S_SUCCESS);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint         sts = OM_S_SUCCESS, msg;
 IGRint         mask, id;
 struct GRevent event;
 IGRchar         *GoodDload = NULL;

 if (ME.super_cmd->mytype == LOAD)
    ex$message(msgnumb = EM_M_DynLode)
 else if (ME.super_cmd->mytype == LOAD_FROM_FILE)
    ex$message(msgnumb = EM_M_DynLDFiles) 
 else
    ex$message(msgnumb = EM_M_VwRtrRnge);

 do
 {
   switch(ME.super_cmd->state)
   {
     case 0:
     {
       ME.super_cmd->state = 1;
       break;
     }
     
     case 1:
     {
       mask = GRm_TEXT_VALUE | GRm_BACK_UP;

       if (ME.super_cmd->mytype == LOAD)
          ex$message(msgnumb = EMS_P_EntFilLoad)
       else if (ME.super_cmd->mytype == LOAD_FROM_FILE)
          ex$message(msgnumb = EMS_P_EntFilFileLod)
       else if (ME.super_cmd->mytype == ODEN)
          ex$message(msgnumb = EMS_P_EntDictNme)
       else 
       {
          ex$message(msgnumb = EMS_P_EntObjid);
          mask &= ~GRm_TEXT_VALUE;
          mask |= GRm_VALUE;
       } 
      sts = co$getevent (
            msg = &msg,
            event_mask = mask,
            value_type = GRIO_SCALAR,
            response = response,
            response_data = response_data,
            event = &event
      );

       ERROR(sts, msg, "ECdynload getevent", wrapup);

       if (event.response == GR_UNKNOWN_TYPE)
         return(OM_S_SUCCESS);
       else if (event.response == EX_BACK_UP)
         ME.super_cmd->state = 0;
       else if (event.response == STRING)
       {
         ex$message(msgnumb = EMS_P_ClearPromptField);
         ex$message(msgnumb = EMS_S_Processing); 

         if (ME.super_cmd->mytype == LOAD)
         {
          GoodDload = (char *)dload(event.event.keyin, OVERLOAD | 
                        TEXTREDEF | ALLOWURES);
          if(!GoodDload) goto badload;
         }
         else if (ME.super_cmd->mytype == LOAD_FROM_FILE)
         {
          char dfile[200];
          FILE *file_ptr;

          file_ptr = fopen(event.event.keyin, "r");
          if(!file_ptr) goto badload;
          while(!feof(file_ptr))
           {
            if(fscanf(file_ptr, "%s", dfile) != -1)
             {
              ex$message(msgnumb = EMS_S_LoadFile);
              GoodDload = (char *) dload(dfile, OVERLOAD | TEXTREDEF | 
                             ALLOWURES);
              if(!GoodDload) goto badload;
             }
           }
         }

        ME.super_cmd->state = 1;     
        ex$message(msgnumb = EMS_S_SuccfLode); 

       } /* else if (event.response == STRING) */

       else if (event.response == VALUE)
       {
         id = (IGRint) event.event.value;
         sts = EMshowrng(id);
         ERROR(sts, msg, "ECdynload show range failure", wrapup);
         ME.super_cmd->state = 1;     
       }
       break;
        
       badload:
       {
         ex$message(msgnumb = EMS_E_UnsuccLode); 
         ME.super_cmd->state = 0;     
       }    
       break;
     }
 
     default:
     {
       ERROR(sts, msg, "ECdynload bad state", wrapup);
       break;
     }

   } /*switch*/
 }
 while (TRUE);

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);

}

void ems_dload( f_name )

IGRchar *f_name;

{
  IGRchar *stat=NULL;

  stat = (IGRchar *) dload(f_name, OVERLOAD | TEXTREDEF | ALLOWURES);

  return;

}



end implementation ECdynload;
