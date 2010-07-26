/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COdelfnt

     METHOD NAMES COinit
                  COexecute
                  COwakeup
                  COsleep

     Abstract:    This method will prompt the user to keyin the font
                  he wants deleted from the local font list. 
    
-----
%SC%
     Value = COdelfnt_COinit_method (IGRint type; IGRchar *string_ptr)

             COdelfnt_COexecute_method (IGRint *response;
                                        IGRchar *response_data;
                                        IGRint pos)

             COdelfnt_COwakeup_method (IGRint pos)

             COdelfnt_COsleep_method (IGRint pos)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                  DESCRIPTION
     ----------     ------------   -----------------------------------
     *response      IGRint     
     *response_data IGRchar
     pos            IGRint
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     *message      IGRlong        Completion code
                    - MSSUCC      if successful
                    - MSFAIL      (severe) if failure
                    - MSINARG     if trying to delete active font

     VALUE (IGRboolean) = TRUE        - if successful
                          FALSE       - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Methods:

     GRfm.GRvirt_search:    - This message will search the font manager
                              table for the specified font.

     GRfm.GRclear_entry:    - This message will delete a font from the font
                              manager table.

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
    
        DEK  11/11/87 : Design date.
        DEK  11/11/87 : Creation date.
        SCW  08/09/94 : Clarified sleep method
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

1.  Get the keyin.
    If a reset go to step 1.

2.  Search the font manager table for the specified virtual font.

3.  Delete the specifed font from the font manager. Clear the entry
    in the font table and point to the fast font. 

4.  Go back to step 1, and get keyin for another font.

----*/
/*EH*/

class implementation COdelfnt;

#include "msmacros.h"
#include "grmessage.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "fontdef.h"
#include "exmacros.h"

from GRfm   import GRvirt_search, GRclear_entry;

/*
 *#define DEBUG
 */

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init (IGRint type; IGRchar *string_ptr)
{

#ifdef DEBUG
    printf("Init method.\n");
#endif

   /*
    * initialize prompt
    */

   ex$message(msgnumb = GR_P_NameFntDel,
              buff = (IGRchar *)me^^COfont.Prompt);

   return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COsleep                          */
/*---------------------------------------------------------------*/

method super_cmd.sleep (IGRint pos)

{
#ifdef DEBUG
     printf("Sleep method.\n");
#endif

    ex$message(in_buff = "",
               field = MESSAGE_FIELD);
    ex$message(in_buff = "",
               field = PROMPT_FIELD);
    ex$message(in_buff = "",
               field = ERROR_FIELD);

    return (OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COwakeup                         */
/*---------------------------------------------------------------*/

method wakeup (IGRint pos)

{
#ifdef DEBUG
    printf("Wakeup method.\n");
#endif

    ex$message(in_buff = "",
               field = PROMPT_FIELD);
    ex$message(in_buff = "",
               field = ERROR_FIELD);

    ex$message(msgnumb = GRC_M_DelFt);

    return (OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COexecute                        */
/*---------------------------------------------------------------*/

method execute ( IGRint *response;
                 IGRchar *response_data;
                 IGRint pos )
{
   struct GRevent         event;            /* event from co$getevent  */
   IGRlong                rc;               /* OM return code          */
   IGRlong                temp_msg;
   IGRlong                mask;             /* input mask              */
   IGRlong                buffersize;       /* dpb buffer size         */
   IGRlong                nobytes;          /* no. of bytes returned   */
                                            /* from dpb call           */
   IGRshort               position;         /* virtual font number     */
   struct GRdpb_text_symb text_symb;        /* buffer to hold dpb      */
   GRspacenum             cur_mod_osnum;    /* current module's osnum  */
   struct GRid            fontmgr_obj;      /* objid of font manager   */
   OM_S_OBJID             cur_mod_id;       /* current module's objid  */

   mask = GRm_STRING | GRm_RESET;
   rc = OM_S_SUCCESS;

   do
   {
      /* get next event */

      co$getevent(msg = &temp_msg,
                  event_mask = mask,
                  prompt = me^^COfont.Prompt,
                  response = response,
                  response_data = response_data,
                  event = &event);

      switch (event.response)
      {

         case RESET:

            ex$message(in_buff = "",
                       field = ERROR_FIELD);
            break;

         case STRING:

            /*
             *  Find the object id of the font manager using its
             *  named object name.
             */

            ex$get_cur_mod(osnum = &cur_mod_osnum);

            ex$get_modid(mod_osnum = cur_mod_osnum,
                         mod_id = &cur_mod_id);

            ex$get_super(mod_id = cur_mod_id,
                         mod_osnum = cur_mod_osnum,
                         super_name = FONTMGR_NO_NAME,
                         create = TRUE,
                         super_class = "GRfm",
                         super_id = &fontmgr_obj.objid,
                         super_osnum = &fontmgr_obj.osnum);

            /*
             * search font manager table for specified font
             */

            position = -1;

            rc = om$send(mode = OM_e_wrt_object,
                         msg = message GRfm.GRvirt_search
                               (&temp_msg,(IGRuchar *)event.event.keyin,&position),
                         senderid = my_id,
                         targetid = fontmgr_obj.objid,
                         targetos = cur_mod_osnum);

            if (COERROR (rc))
            {
#ifdef DEBUG
               printf("COdelfnti.I err: GRfm.GRvirt_search rc = %d\n",rc);
#endif
               *response = TERMINATE;
               break;
            }

            if (temp_msg == MSFAIL)
            {
               ex$message(msgnumb = GR_E_FtNotFnd);
               break;
            }

            buffersize = sizeof(text_symb);
            gr$get_text_symb(msg = &temp_msg,
                             sizbuf = &buffersize,
                             buffer = &text_symb,
                             nret = &nobytes);

            if (!COERROR(temp_msg))
            {
                if (position == text_symb.Active_font)
                {
                    ex$message(msgnumb = GR_E_CantDelActFt);
                    break;
                }
            }
            else
            {
                *response = TERMINATE;
                rc = OM_E_ABORT;
                break;
            }

            /*
             * delete font from font manager table 
             */

            rc = om$send(mode = OM_e_wrt_object,
                         msg = message GRfm.GRclear_entry
                               (&temp_msg,&position),
                         senderid = my_id,
                         targetid = fontmgr_obj.objid,
                         targetos = cur_mod_osnum);

            if (COERROR (rc))
            {
#ifdef DEBUG
               printf("COdelfnti.I err: GRfm.GRclear_entry rc = %d\n", rc);
#endif
               *response = TERMINATE;
               break;
            }
            else if (temp_msg == MSINARG)
            {
                ex$message(msgnumb = GR_E_CantDelFFt);
                break;
            }
            ex$message(msgnumb = GR_I_FtDeld,
                       type = "%s",
                       var = `event.event.keyin`);
            break;   

         case GR_UNKNOWN_TYPE:

            break;

         default:

#ifdef DEBUG
            printf("COtext: unknown action requested\n");
#endif
        break;

      }     /* end switch */

   } while((event.response != GR_UNKNOWN_TYPE) && (*response != TERMINATE));

   return(OM_S_SUCCESS);
}

end implementation COdelfnt;
