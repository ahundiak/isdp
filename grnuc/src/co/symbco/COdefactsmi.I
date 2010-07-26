/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COdefactsm

Description
   The COdefactsm comand object defines an active cell given a cell
   name from a keyin. The active cell library is searched for the
   cell.  Currently only the active cell library is supported, but 
   symbol_lib_array was designed to facilitate multiple attached cell
   libraries in the future.

History
   BC    06/12/86 : Design date.
   HGW   06/30/86 : Finished coding and testing.
   HGW   08/05/86 : Changed terminology
   mrm   10/01/86 : OM 4.0 conversion
   HGW   12/15/87 : Changes for version 1.1
\*/

class implementation COdefactsm;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grerr.h"
#include "grsymdef.h"
#include "grsym.h"
#include "OMerrordef.h"
#include "codef.h"
#include "grdpbdef.h"

#define FUNC_ERROR  0      /* Error then cleanup                    */
#define SUCCESS     1      /* Continue looping                      */
#define RETCONTROL  2      /* Exit command and return(OM_S_SUCCESS) */

/***********************************************************************/
/************************** execute method *****************************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
IGRlong           om_msg;           /* OM return status                 */
IGRlong           ret_msg;          /* Function return code             */
IGRlong           exit_code;        /* Loop control variable            */
struct GRmd_env   sl_env;           /* The env for the located symbol   */
struct GRid       symbol_id;        /* Located symbol object id         */
IGRchar           symbol_name[MAX_SYMBOL_DEF_NAME];/* Active symbol name*/
struct GRactive_symbol_def active_symbol; /* Active symbol        */

   ex$message(msgnumb = GRC_M_DfnActCel);

   if (me->init_success == TRUE)
   {
      exit_code = SUCCESS;

      /*
       *  display the active cell name
       */

      om_msg = gr$symget_active_symbol (msg = &ret_msg, 
                                        act_symbol_def = &active_symbol);

      if (om_msg & ret_msg & 1)
      {
         ex$message (msgnumb = GR_I_ActCel,
                     type = "%s",
                     var = `active_symbol.name`);
      }
   }else
   {
      ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }

   while (exit_code == SUCCESS)
   {
      co$getevent(msg = &ret_msg, 
         event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
         msgnum = GR_P_KyCelNme, response = response, 
         response_data = response_data, event = &me->event);

      switch (me->event.response)
      {
         case STRING:
         {
            strcpy (symbol_name, me->event.event.keyin);

            /*
             *  Search for the symbol in the attached symbol
             *  libraries.
             */

            om_msg = gr$symsd_locate_in_all_sl ( msg = &ret_msg,
                     sd_name = symbol_name, sl_env = &sl_env, 
                     sd_id = &symbol_id);

            if (COERROR(om_msg))
            {
               ex$message(msgnumb = GR_E_ErrEncCmdRst);
               break;
            }else if (ret_msg == GR_I_NOSL)
            {
               ex$message(msgnumb = GR_F_NoActCelLibDfn);
               *response = TERMINATE;
               exit_code = RETCONTROL;
               break;
            }else if (COERROR(ret_msg))
            {
               ex$message(msgnumb = GR_E_CelNotFnd);
               break;
            }

            /*
             *  Define the located active symbol as the new
             *  active symbol.  The super is responsible for
             *  any work associated with defining it as the
             *  active symbol.
             */

            om_msg = gr$symput_active_symbol ( msg = &ret_msg,
                     symbol_name = symbol_name, symbol_id = &symbol_id,
                     asl_env = &sl_env);

            if (COERROR(om_msg & ret_msg))
            {
               ex$message(msgnumb = GR_E_ErrEncCmdRst);
               break;
            }

            ex$message(msgnumb = GR_I_ActCel, type = "%s",
               var = `symbol_name`);


            /*
             *  Set response to TERMINATE to exit the command.
             */

            *response = TERMINATE; 
            exit_code = RETCONTROL;            

         }  /* End of STRING case */
         break;

         case EX_RESTART:
         case EX_BACK_UP:
            break;

         case GR_UNKNOWN_TYPE:
         {
            exit_code  = RETCONTROL;
         }
         break;
      }  /* End of switch statement */
   }  /* End of while statement     */
   
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/*********************** COevent init method  **************************/
/***********************************************************************/

method init (int type; char *str_ptr)
{
IGRlong     ret_msg;       /* Msg return code               */
IGRlong     om_msg;        /* OM return status              */
IGRint      size;          /* size of DPB structure         */
IGRint      ret_size;      /* size of DPB structure returned*/

   me->init_success = TRUE;

   /* 
    *  Get the module environment.
    */

   size = sizeof( struct GRmd_env );
   om_msg = gr$get_module_env (msg = &ret_msg, sizbuf = &size, 
            buffer = &me->ModuleInfo, nret = &ret_size);
   return( OM_S_SUCCESS );
}
end implementation COdefactsm;
