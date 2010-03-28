/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COretfnt

     METHOD NAMES COinit
                  COexecute
                  COwakeup
                  COsleep

     Abstract:    This method will prompt the user to keyin the name
                of the font to be retrieved, and a font name to use 
                in the local list. If the specified font exists and 
                is not already in the local list, it will be retrieved
                and an entry will be made in the local list for this 
                font.  The font name to be used in the local list must
                be unique to the local list.
-----
%SC%
     Value = COretfnt_init_method (IGRint type;
                                   IGRchar *string_ptr)

             COretfnt_execute_method (IGRint *response;
                                      IGRchar *response_ptr;
                                      IGRint pos)

             COretfnt_wakeup_method (IGRint pos)

             COretfnt_sleep_method (IGRint pos)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     ------------   -----------------------------------
     *response      IGRint         
     *response_data IGRchar
     pos            IGRint
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

         GRfm.GRphy_search:  - This message will return the local
                               list name of the font if it has
                               already been down loaded.

         GRfm.GRvirt_search: - This message will return the position
                               of the font in the local list if it
                               exists in the list.

         GRfm.GRmake_entry:  - This message will down load a specified
                               font if it exists.
-----
%RL%

     RELATIONS REFERENCED:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        DEK  10/27/87 : Design date.
        DEK  10/27/87 : Creation date.
        SCW  08/09/94 : Clarified sleep method
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

    This method will prompt the user to keyin the name of the font 
to be retrieved, and a font name to use in the local list. If the 
specified font exists and is not already in the local list, it will 
be retrieved and an entry will be made in the local list for this 
font.  The font name to be used in the local list must be unique to 
the local list.

----*/
/*EH*/

class implementation COretfnt;

#include "igrdp.h"
#include "griodef.h"
#include "exmacros.h"
#include "grmessage.h"
#include "godef.h"
#include "go.h"
#include "grio.h"
#include "griomacros.h"
#include "codef.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "msdef.h"
#include "msmacros.h"

from GRfm   import GRphy_search, GRvirt_search, GRmake_entry;

/*
 *#define DEBUG
 */

/*
 * define the states for retrieve font
 */

#define GET_FONT     0
#define DWN_LD_FNT   1

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init (IGRint type; IGRchar *string_ptr)
{

# ifdef DEBUG
    printf("Init method.\n");
# endif

   /*
    * initialize state
    */

   me^^super_cmd.state = GET_FONT;
   me^^COretfnt.mask = GRm_STRING | GRm_RESET;

   ex$message(msgnumb = GR_P_NameNumFnt,
              buff = (IGRchar *)me^^COfont.Prompt);

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

   ex$message(msgnumb = GRC_M_RetFt);

   return (OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COexecute                        */
/*---------------------------------------------------------------*/

method execute ( IGRint *response;
                 IGRchar *response_data; 
                 IGRint pos )
{
   extern IGRboolean      GRisitfnt();

   struct GRevent         event;           /* event from co$getevent  */
   IGRlong                OMmsg;           /* OM return code          */
   IGRlong                temp_msg;
   IGRint                 num_chars;
   IGRuchar       vfont_name[40];  /* virtual font name       */
   IGRshort               vfont_num;       /* virtual font number     */
   IGRshort               position;        /* position of font in     */
                                           /* local list              */
   GRspacenum             cur_mod_osnum;   /* current module's osnum  */
   struct GRid            fontmgr_obj;     /* objid of font manager   */
   OM_S_OBJID             cur_mod_id;      /* current module's objid  */
   struct EX_fonts        font_parameters; /* locale font parameters  */
   struct EX_locale_var   var_list;        /* locale identifiers      */

   OMmsg = OM_S_SUCCESS;
   me^^COretfnt.font_flags = 0;

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

   do
   {
      /*
       *  issue prompt and get input
       */

      co$getevent(msg = &temp_msg,
                  event_mask = me^^COretfnt.mask,
                  prompt = me^^COfont.Prompt,
                  response = response,
                  response_data = response_data,
                  event = &event);

      switch (event.response)
      {

         case RESET:

            me^^super_cmd.state = GET_FONT;

            ex$message(msgnumb = GR_P_NameNumFnt,
                       buff = (IGRchar *)me^^COfont.Prompt);

            ex$message(in_buff = "",
                       field = ERROR_FIELD);

            break;

         case STRING:

            switch(me^^super_cmd.state)
            {
               case GET_FONT:            /* get font file */

                  /*
                   *  call routine to determine if the input file is a font
                   *  file or not
                   */

                  num_chars = event.nbytes - 1;

                  if (!GRisitfnt(&temp_msg,event.event.keyin,&num_chars,
                                 NULL))
                  {
                     ex$message(msgnumb = GR_E_FtLibNotFnd);

                     break;
                  }

                  strcpy((char *)me^^COretfnt.logical_name,event.event.keyin);

                  ex$message(in_buff = "",
                             field = ERROR_FIELD);

                  /*
                   *  Call GRphy_search to see if the specified font is
                   *  already in the local list
                   */

                  OMmsg = om$send(mode = OM_e_wrt_object,
                                  msg = message GRfm.GRphy_search
                                        (&temp_msg,me^^COretfnt.logical_name,
                                         vfont_name),
                                  senderid = my_id,
                                  targetid = fontmgr_obj.objid,
                                  targetos = cur_mod_osnum);

                  if ((temp_msg == MSSUCC) || (COERROR(OMmsg)))
                  {
                      if (temp_msg == MSSUCC)   /* typeface already used */
                      {
                          ex$message(msgnumb = GR_E_FtLdd,
                                     type = "%s",
                                     var = `vfont_name`);
                      }
                      else
                      {
#ifdef DEBUG
                          printf("COretfnti.I err: GRfm.GRphy_search");
#endif
                          *response = TERMINATE;
                      }

                      break;
                  }

                  var_list.var = EX_font_parameters;
                  var_list.var_ptr = (IGRchar *) &font_parameters;

                  ex$inq_locale (msg = &temp_msg,
                                 var = &var_list,
                                 flags = EX_Text | EX_Logical_Name,
                                 identifier = (IGRchar *)me^^COretfnt.logical_name);

                  if (!(font_parameters.properties & EX_Text_Font) &&
                      !(font_parameters.properties & EX_Frac_Font) &&
                      !(font_parameters.properties & EX_Symb_Font))
                  {
                     ex$message(in_buff = "Font is not a graphics font",
                                field = ERROR_FIELD);

                     break;
                  }

                  if (font_parameters.properties & EX_Sixteen_Bit)
                  {
                     me^^COretfnt.font_flags |= SIXTEEN_BIT;
                  }
                  else if (font_parameters.properties & EX_Eight_Bit)
                  {
                     me^^COretfnt.font_flags |= EIGHT_BIT;
                  }

                  if (font_parameters.properties & EX_Text_Font)
                  {
                     me^^COretfnt.font_flags |= TEXT_FONT;
                  }
                  else if (font_parameters.properties & EX_Frac_Font)
                  {
                     me^^COretfnt.font_flags |= FRACTION_FONT;
                  }
                  else
                  {
                     me^^COretfnt.font_flags |= SYMBOL_FONT;
                  }

                  ex$message(in_buff = "",
                             field = ERROR_FIELD);

                  ex$message(msgnumb = GR_P_FntNameLL,
                             buff = (IGRchar *)me^^COfont.Prompt);

                  me^^super_cmd.state = DWN_LD_FNT;

                  break;

               case DWN_LD_FNT:           /* down load the specified font */

                  if (event.nbytes > 1)   /* event.nytes = 1 indicates only */
                  {                       /* a carriage return was entered  */
                      position = -1;

                      /*
                       *  Call GRvirt_search to insure the local list name
                       *  is unique.
                       */

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRvirt_search
                                            (&temp_msg,(IGRuchar *)event.event.keyin,
                                            &position),
                                      senderid = my_id,
                                      targetid = fontmgr_obj.objid,
                                      targetos = cur_mod_osnum);

                      if ((temp_msg == MSSUCC) || (COERROR(OMmsg)))
                      {
                          if (temp_msg == MSSUCC)  /* virt name already used */
                          {
                              ex$message(msgnumb = GR_E_FtNmeLdd);
                          }
                          else
                          {
#ifdef DEBUG
                              printf("COretfnti.I err: GRfm.GRvirt_search");
#endif
                              *response = TERMINATE;
                          }
                          break;
                      }

                      ex$message(msgnumb = GR_I_Executing);

                      /*
                       *  Call GRmake_entry to down load the specified font.
                       */

                      vfont_num = -1;   /* place font in next available slot */

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRmake_entry
                                            (&temp_msg,
                                            me^^COretfnt.logical_name,
                                            (IGRuchar *)event.event.keyin,
                                            me^^COretfnt.font_flags,
                                            &vfont_num),
                                      senderid = my_id,
                                      targetid = fontmgr_obj.objid,
                                      targetos = cur_mod_osnum);

                      if (COERROR(OMmsg))
                      {
#ifdef DEBUG
                         printf("COretfnti.I err: GRfm.GRmake_entry");
#endif
                         *response = TERMINATE;
                         break;
                      }
                      else if (COERROR(temp_msg))
                      {
#ifdef DEBUG
                         printf("COretfnti.I err: GRfm.GRmake_entry");
#endif
                         if (temp_msg == GR_E_MxNoFtLdd)
                         {
                            ex$message(msgnumb = GR_E_MxNoFtLdd);
                            break;
                         }

                         *response = TERMINATE;
                         break;
                      }

                      me^^super_cmd.state = GET_FONT;
                      ex$message(in_buff = "",
                                 field = ERROR_FIELD);
                      ex$message(msgnumb = GR_P_NameNumFnt,
                                 buff = (IGRchar *)me^^COfont.Prompt);

                  }          /* end if not a carriage return */
                  break;

               default:

#ifdef DEBUG
                  printf("COretfnti.I err: unknown state");
#endif
                  *response = TERMINATE;
                  break;
            }             /* end switch */
            break;

         case GR_UNKNOWN_TYPE:

            break;

         default:

#ifdef DEBUG
            printf("COretfnt: unknown action requested\n");
#endif
            break;

      }     /* end switch */

   } while((event.response != GR_UNKNOWN_TYPE) && (*response != TERMINATE));

   return(OM_S_SUCCESS);
}

end implementation COretfnt;
