/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COfstfnt

     METHOD NAMES COinit
                  COexecute
                  COwakeup
                  COsleep

     Abstract:    This method will prompt the user to keyin the name
                of the font that is to become the new fast font.  If
                the specified font is found in the local list, it
                will become the new fast font and all undefined entries
                in the local list will use the new fast font.
-----
%SC%
     Value = COfstfnt_COinit_method (IGRint type;
                                     IGRchar *string_ptr)

             COfstfnt_COexecute_method (IGRint *response;
                                        IGRchar *response_data;
                                        IGRint pos)

             COfstfnt_COwakeup_method (IGRint pos)

             COfstfnt_COsleep_method (IGRint pos)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     response     IGRint         
     response_dataIGRchar
     pos          IGRint
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Methods:

         GRfm.GRvirt_search:     - This message will return the position
                                   of the font in the local list if it
                                   exists in the list.

         GRfm.GRset_fast_fnt:    - This message will make the specified
                                   font the new fast font.
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
        
        WBC  04/29/86 : Design date.
        WBC  04/29/86 : Creation date.
        SCW  08/09/94 : Clarified sleep method
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
1.  Get the keyin that specifies which font is to become
    the new fast font.

2.  Call GRvirt_search to find the position of the specified font
    in the local list.

3.  Call GRset_fast_fnt to make the specified font the new fast
    font.

----*/
/*EH*/

class implementation COfstfnt;

#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "fontdef.h"
#include "exmacros.h"

from GRfm   import GRvirt_search, GRset_fast_fnt;

/*
 *#define DEBUG
 */

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init (IGRint type; IGRchar *string_ptr)
{

# ifdef DEBUG
    printf("Init method.\n");
# endif

   /*
    * initialize prompt
    */

   ex$message(msgnumb = GR_P_NameFstFnt,
              buff = (IGRchar *) me^^COfont.Prompt);

   return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COsleep                          */
/*---------------------------------------------------------------*/

method super_cmd.sleep (IGRint pos)

{
# ifdef DEBUG
     printf("Sleep method.\n");
# endif

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
# ifdef DEBUG
    printf("Wakeup method.\n");
# endif

   ex$message(in_buff = "",
              field = PROMPT_FIELD);
   ex$message(in_buff = "",
              field = ERROR_FIELD);

   ex$message(msgnumb = GRC_M_SetFstFt);

   return (OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COexecute                        */
/*---------------------------------------------------------------*/

method execute ( IGRint *response;
                 IGRchar *response_data; 
                 IGRint pos )
{
   struct GRevent         event;           /* event from co$getevent */
   IGRlong                temp_msg;
   IGRlong                mask;            /* input mask             */
   IGRshort               vfont_num;       /* virtual font number    */
   IGRlong                OMmsg;           /* OM return code         */
   GRspacenum             cur_mod_osnum;   /* current module's osnum */
   struct GRid            fontmgr_obj;     /* objid of font manager   */
   OM_S_OBJID             cur_mod_id;      /* current module's objid  */
   IGRchar                type;            /* type of font; text or
                                              fraction                */

   mask = GRm_STRING | GRm_RESET;
   OMmsg = OM_S_SUCCESS;
   type = TEXT_FONT;

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

         case RESET:                            /* do nothing       */

            break;

         case STRING:     /* make the specified font the new fast font */

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

            vfont_num = -1;

            /* Find the font's local list number */

            OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRfm.GRvirt_search(&temp_msg,
                                  (IGRuchar *)event.event.keyin,&vfont_num),
                            senderid = my_id,
                            targetid = fontmgr_obj.objid,
                            targetos = cur_mod_osnum);

            if (COERROR(temp_msg))
            {
                ex$message(msgnumb = GR_E_FtNotFnd);
                break;
            }
            else if (COERROR(OMmsg))
            {
#ifdef DEBUG
                printf("COfstfnti.I err: GRfm.GRvirt_search");
#endif
                *response = TERMINATE;
                break;
            }

            /* change the fast font */

            OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRfm.GRset_fast_fnt(&temp_msg,
                                  &vfont_num,type),
                            senderid = my_id,
                            targetid = fontmgr_obj.objid,
                            targetos = cur_mod_osnum);

            if ((COERROR(temp_msg)) || (COERROR(OMmsg)))
            {
#ifdef DEBUG
                printf("COfstfnti.I err: GRfm.GRset_fast_fnt");
#endif
                *response = TERMINATE;    
                break;
            }

            ex$message(in_buff = "",
                       field = ERROR_FIELD);
            break;

         case GR_UNKNOWN_TYPE:

            break;

         default:

#ifdef DEBUG
            printf("COfstfnt: unknown action requested\n");
#endif
            break;

      }     /* end switch */

   } while ((event.response != GR_UNKNOWN_TYPE) && (*response != TERMINATE));

   return(OM_S_SUCCESS);
}

end implementation COfstfnt;
