/* #######################    APOGEE COMPILED   ######################## */
/*
Name
    COsdrename  - rename a symbol in a symbol library

Synopsis
    usual command object arglists

Description
    This command object prompts the user for the name of a cell to
    rename, the new name, and renames the cell in the active cell library.

History
    Mike Mathis     10/16/86    Creation
    Mike Mathis     02/19/87    Fixed suspension problems
    Gray Winn       11/16/87    Changes for version 1.1
    mrm             01/05/89    issue cmd name from execute rather than wakeup
\*/

class implementation COsdrename;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "exdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grerr.h"

from GRsmdfhdr import GRrename_sd;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             init                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *str_ptr)
{
    me->state = 0;
    return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           wakeup method                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (int pos)
{
IGRlong msg;

   GRfindmod(&me->mod_id);
   gr$symget_asl_env (msg = &msg, asl_env = &me->asl_mod_env);
   if (msg == GR_I_SL_READ_ONLY)
   {
      me->asl_defined = 2;
   }else
   {
      me->asl_defined = msg & 1;
   }
   UI_prompt ("");
   UI_status ("");
   return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute (int *response; char *response_data; int pos)
{
IGRint           name_length;
IGRint           desc_length;
IGRlong          msg;
IGRlong          status;
IGRlong          exit;
struct GRid      temp_id;
struct GRevent   event;
struct GRnamdesc name_desc;
enum states     {GET_OLD_NAME, GET_NEW_NAME};

   if (me->asl_defined & 1)
   {
      exit = FALSE;
   }else
   {
      *response = TERMINATE;
      exit = TRUE;
      if (me->asl_defined == 0)
      {
         ex$message(msgnumb = GR_F_NoActCelLibDfn);
      }else
      {
         ex$message(msgnumb = GR_F_FlRdOnly);
      }
   }

   ex$message(msgnumb = GRC_M_RenCelLib);
   while (!exit)
   {
      switch (me->state)
      {
         case GET_OLD_NAME:
            co$getevent(msg = &msg, 
               event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
               msgnum = GR_P_KyCelRen, response = response, 
               response_data = response_data, event = &event);

            UI_status (""); /* clear message, if present */
            switch (event.response)
            {
               case STRING:

                  /*
                   *  locate the symbol in the active symbol space
                   */

                  status = gr$symsd_locate_in_asl (msg = &msg, 
                           sd_name = event.event.keyin,
                           sl_env = &me->asl_mod_env,
                           sd_id = &me->sym_id);

                  if ((status & msg & 1))
                  {
                     me->state = GET_NEW_NAME;
                  }else
                  {
                     ex$message(msgnumb = GR_E_CelNotFnd);
                  }
                  break;

               case EX_RESTART:
               case EX_BACK_UP:
                  break;

               case GR_UNKNOWN_TYPE:
               default:
                  exit = TRUE;
                  break;
            } /* end switch (event.response) */
            break;

         case GET_NEW_NAME:
            co$getevent(msg = &msg, 
               event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
               msgnum = GR_P_KyNwNme, response = response, 
               response_data = response_data, event = &event);

            switch (event.response)
            {
               case STRING:

                  /*
                   *  separate the name from the description
                   */

                  status = GRparse (&msg, event.event.keyin,
                           name_desc.name_symbol, &name_length,
                           name_desc.desc_symbol, &desc_length);

                  if (!status)
                  {
                     ex$message(msgnumb = GR_E_InvNme);
                     break;
                  }

                  /*
                   *  check the active symbol space for a duplicate name
                   */

                  status = gr$symsd_locate_in_asl (msg = &msg, 
                           sd_name = name_desc.name_symbol,
                           sl_env = &me->asl_mod_env,
                           sd_id = &temp_id);

                  if ((status & msg & 1))
                  {
                     ex$message(msgnumb=GR_E_DupNmeIs, type="%s",
                                var=`name_desc.name_symbol`);

                     break;
                  }

                  /*
                   *  send the located symbol a rename message
                   */

                  status = om$send (msg = message GRsmdfhdr.GRrename_sd
                           (&msg, 
                           (name_length) ? name_desc.name_symbol : NULL,
                           (desc_length) ? name_desc.desc_symbol : NULL),
                           targetid = me->sym_id.objid,
                           targetos = me->sym_id.osnum);

                  if (!(status & msg & 1))
                  {
                     ex$message(msgnumb = GR_E_CantRenCel);
                  }else
                  {
                     ex$message(msgnumb = GR_I_Ren, type="%s",
                                var=`name_desc.name_symbol`);

                     /*
                      *  Save the cell library.
                      */

                     gr$symsave_asl(msg = &msg);
                  }

                  me->state = GET_OLD_NAME;
                  break;

               case EX_RESTART:
               case EX_BACK_UP:
                  me->state = GET_OLD_NAME;
                  break;

               case GR_UNKNOWN_TYPE:
               default:
                  exit = TRUE;
                  break;
            } /* end switch (event.response) */
         break;
      } /* end switch (me->state) */
   } /* end while (!exit) */
   return (OM_S_SUCCESS);
}

end implementation COsdrename;
