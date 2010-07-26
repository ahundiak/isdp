/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COrplfnt

     METHOD NAMES COinit
                  COexecute
                  COwakeup
                  COsleep

     Abstract:    This method will prompt the user to keyin the name
                of the virtual font to be replaced, the name of a
                font file, and a font name to use in the local list
                for the replacement font. If the specified font file
                exists and is not already in the local list, the font to
                be replaced will be deleted and the new font will be
                down loaded in the same position in the local list.
                The font name to be used in the local list must be
                unique to the local list.
-----
%SC%
     Value = COrplfnt_COinit_method (IGRint type;
                                     IGRchar *string_ptr)

             COrplfnt_COexecute_method (IGRint *response;
                                        IGRchar *response_data;
                                        IGRint pos)

             COrplfnt_COwakeup_method (IGRint pos)

             COrplfnt_COsleep_method (IGRint pos)
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

     Modules:    

         strcpy:                 - A standard C function to copy the
                                   contents of string2 into string1.

         strlen:                 - A standard C function to find the
                                   length of a character string.

     Methods:

         GRfm.GRphy_search:      - This message will return the local
                                   list name of the font if it has
                                   already been down loaded.

         GRfm.GRvirt_search:     - This message will return the position
                                   of the font in the local list if it
                                   exists in the list.

         GRfm.GRmake_entry:      - This message will down load a specified
                                   font if it exists.

         GRfm.GRclear_entry:     - This message will delete a specified
                                   font from the local list if it exists.
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
1.  Get the keyin that specifies which local list font is to be
    replaced.

2.  Get the keyin that specifies which font file the replacement
    font is.

3.  Call GRphy_search to see if the specified font already exists in
    the local list.

4.  Get the keyin that indicates the name the replacement font will
    have in the local list.

5.  Call GRvirt_search to see if the font name is unique to the
    local list.

6.  Call GRclear_entry to delete the font to be replaced.

7.  Call GRmake_entry to down load the specified font.

----*/
/*EH*/

class implementation COrplfnt;

#include "msmacros.h"
#include "grmessage.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "msdef.h"
#include "fontdef.h"
#include "exmacros.h"
#include "ctype.h"
#include "exlocaledef.h"
#include "exlocale.h"

from GRfm   import GRphy_search, GRvirt_search, GRmake_entry, GRclear_entry, GRisitfstfnt;

/*
 *#define DEBUG
 */

/*
 * define the states for replace font
 */

#define OLD_VIRT_NAME     0
#define FONT_FILE_NAME    1
#define NEW_VIRT_NAME     2

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init (IGRint type; IGRchar *string_ptr)
{

#ifdef DEBUG
    printf("Init method.\n");
#endif

   /*
    * initialize state
    */

   me^^super_cmd.state = OLD_VIRT_NAME;
   me^^COrplfnt.mask = GRm_STRING | GRm_RESET;

   ex$message(msgnumb = GR_P_FntRplLL,
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

   ex$message(msgnumb = GRC_M_RepFt);

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

   IGRlong                temp_msg;        /* temp status message     */
   IGRint                 num_chars;       /* number of characters    */
   IGRuchar       vfont_name[40];  /* virtual font name       */
   IGRshort               position;        /* position of font in     */
                                           /* local list              */
   IGRlong                OMmsg;           /* OM return code          */
   struct GRevent         event;           /* event from co$getevent  */
   GRspacenum             cur_mod_osnum;   /* current module's osnum  */
   struct GRid            fontmgr_obj;     /* objid of font manager   */
   OM_S_OBJID             cur_mod_id;      /* current module's objid  */
   struct EX_fonts        font_parameters; /* locale font parameters  */
   struct EX_locale_var   var_list;        /* locale identifiers      */
   IGRshort               type;            /* type of fast font       */

   OMmsg = OM_S_SUCCESS;
   me^^COrplfnt.font_flags = 0;

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
      temp_msg = MSSUCC;

      co$getevent(msg = &temp_msg,
                  event_mask = me^^COrplfnt.mask,
                  prompt = me^^COfont.Prompt,
                  response = response,
                  response_data = response_data,
                  event = &event);

      switch (event.response)
      {
         case RESET:

            me^^super_cmd.state = OLD_VIRT_NAME;

            ex$message(msgnumb = GR_P_FntRplLL,
                       buff = (IGRchar *)me^^COfont.Prompt);

            ex$message(in_buff = "",
                       field = ERROR_FIELD);

            break;

         case STRING:

            switch(me^^super_cmd.state)
            {

               case OLD_VIRT_NAME: 

                  if (event.nbytes > 1)   /* event.nytes = 1 indicates only */
                  {                       /* a carriage return was entered  */
                      /*
                       *  Call GRvirt_search to see if font exists
                       *  in local list.
                       */

                      me^^COrplfnt.vfont_num = -1;

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRvirt_search
                                            (&temp_msg,(IGRuchar *)event.event.keyin,
                                             &(me^^COrplfnt.vfont_num)),
                                senderid = my_id,
                                targetid = fontmgr_obj.objid,
                                targetos = cur_mod_osnum);

                      if (COERROR(OMmsg))
                      {
#ifdef DEBUG
                         printf("COrplfnti.I err: GRfm.GRvirt_search");
#endif
                         *response = TERMINATE;
                         break;
                      }
                      else if (COERROR(temp_msg))
                      {
                         ex$message(msgnumb = GR_E_FtNotFnd);
                         me^^super_cmd.state = OLD_VIRT_NAME;
                         break;
                      }

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRisitfstfnt
                                            (&temp_msg,
                                            &(me^^COrplfnt.vfont_num),
                                            &type),
                                      senderid = my_id,
                                      targetid = fontmgr_obj.objid,
                                      targetos = cur_mod_osnum);

                      if (COERROR(OMmsg))
                      {
#ifdef DEBUG
                          printf("COrplfnti.I err: GRfm.GRisitfstfnt");
#endif
                          *response = TERMINATE;
                          break;
                      }
                      else if (temp_msg == MSSUCC)
                      {
                          ex$message(msgnumb = GR_E_CantRepFFt);
                          me^^super_cmd.state = OLD_VIRT_NAME;
                          break;
                      }

                      ex$message(in_buff = "",
                                 field = ERROR_FIELD);

                      ex$message(msgnumb = GR_P_NameNumFnt,
                                 buff = (IGRchar *)me^^COfont.Prompt);

                      me^^super_cmd.state = FONT_FILE_NAME;

                  }       /* end if not a carriage return */
                  break;

               case FONT_FILE_NAME: 

                  num_chars = event.nbytes - 1;

                  if (!GRisitfnt(&temp_msg,event.event.keyin,&num_chars,
                                 NULL))
                  {
                     ex$message(msgnumb = GR_E_FtLibNotFnd);

                     break;
                  }

                  strcpy((char *)me^^COrplfnt.logical_name,event.event.keyin);

                  ex$message(in_buff = "",
                             field = ERROR_FIELD);

                  /*
                   *  Call GRphy_search to see if the specified font
                   *  is already in the local list.
                   */

                  OMmsg = om$send(mode = OM_e_wrt_object,
                                  msg = message GRfm.GRphy_search
                                        (&temp_msg,me^^COrplfnt.logical_name,
                                         vfont_name),
                                  senderid = my_id,
                                  targetid = fontmgr_obj.objid,
                                  targetos = cur_mod_osnum);

                  if (COERROR(OMmsg))
                  {
#ifdef DEBUG
                      printf("COrplfnti.I err: GRfm.GRphy_search");
#endif
                      *response = TERMINATE;
                      break;
                  }
                  else if (temp_msg == MSSUCC)   /* typeface already used */
                  {
                     ex$message(msgnumb = GR_E_FtLdd,
                                type = "%s",
                                var = `vfont_name`);
                     break;
                  }

                  var_list.var = EX_font_parameters;
                  var_list.var_ptr = (IGRchar *)&font_parameters;

                  ex$inq_locale (msg = &temp_msg,
                                 var = &var_list,
                                 flags = EX_Text | EX_Logical_Name,
                                 identifier = (IGRchar *)me^^COrplfnt.logical_name);

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
                     me^^COrplfnt.font_flags |= SIXTEEN_BIT;
                  }
                  else if (font_parameters.properties & EX_Eight_Bit)
                  {
                     me^^COrplfnt.font_flags |= EIGHT_BIT;
                  }

                  if (font_parameters.properties & EX_Text_Font)
                  {
                     me^^COrplfnt.font_flags |= TEXT_FONT;
                  }
                  else if (font_parameters.properties & EX_Frac_Font)
                  {
                     me^^COrplfnt.font_flags |= FRACTION_FONT;
                  }
                  else
                  {
                     me^^COrplfnt.font_flags |= SYMBOL_FONT;
                  }


                  ex$message(in_buff = "",
                             field = ERROR_FIELD);

                  ex$message(msgnumb = GR_P_FntNameLL,
                             buff = (IGRchar *)me^^COfont.Prompt);

                  me^^super_cmd.state = NEW_VIRT_NAME;
                  break;

               case NEW_VIRT_NAME: 

                  if (event.nbytes > 1)   /* event.nytes = 1 indicates only */
                  {                       /* a carriage return was entered  */
                      position = -1;

                      /*
                       *  Call GRvirt_search to insure the local
                       *  list name is unique.
                       */

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRvirt_search(&temp_msg,
                                            (IGRuchar *)event.event.keyin,&position),
                                      senderid = my_id,
                                      targetid = fontmgr_obj.objid,
                                      targetos = cur_mod_osnum);

                      if (COERROR(OMmsg))
                      {
#ifdef DEBUG
                         printf("COrplfnti.I err: GRfm.GRvirt_search");
#endif
                         *response = TERMINATE;
                         break;
                      }
                      else if (temp_msg == MSSUCC) /* virt name already used */
                      {
                         ex$message(msgnumb = GR_E_FtNmeLdd);
                         break;
                      }

                      ex$message(in_buff = "",
                                 field = ERROR_FIELD);

                      /*
                       *  Call GRclear_entry to delete the specified font.
                       */

                      OMmsg = om$send(mode = OM_e_wrt_object,
                                      msg = message GRfm.GRclear_entry
                                         (&temp_msg,&(me^^COrplfnt.vfont_num)),
                                      senderid = my_id,
                                      targetid = fontmgr_obj.objid,
                                      targetos = cur_mod_osnum);

                     if (COERROR(OMmsg) || COERROR(temp_msg))
                     {
#ifdef DEBUG
                        printf("COrplfnti.I err: GRfm.GRclear_entry");
#endif
                        *response = TERMINATE;
                        break;
                     }

                     /*
                      *  Call GRmake_entry to down load the specified font.
                      */

                     OMmsg = om$send(mode = OM_e_wrt_object,
                                     msg = message GRfm.GRmake_entry(&temp_msg,
                                           me^^COrplfnt.logical_name,
                                           (IGRuchar *)event.event.keyin,
                                           me^^COrplfnt.font_flags,
                                           &(me^^COrplfnt.vfont_num)),
                                     senderid = my_id,
                                     targetid = fontmgr_obj.objid,
                                     targetos = cur_mod_osnum);

                     if (COERROR(OMmsg))
                     {
#ifdef DEBUG
                        printf("COrplfnti.I err: GRfm.GRmake_entry");
#endif
                        *response = TERMINATE;
                        break;
                     }
                     else if (COERROR(temp_msg))
                     {
#ifdef DEBUG
                        printf("COrplfnti.I err: GRfm.GRmake_entry");
#endif
                        if (temp_msg == FS_INVALID_TF_FILE)
                        {
                           ex$message(msgnumb = GR_E_FtLibNotFnd);
                           break;
                        }

                        *response = TERMINATE;
                        break;
                     }

                     me^^super_cmd.state = OLD_VIRT_NAME;

                     ex$message(msgnumb = GR_P_FntRplLL,
                                buff = (IGRchar *)me^^COfont.Prompt);

                 }        /* end if a carriage return was entered */
                 break;   

              }                     /* end switch */
              break;

         case GR_UNKNOWN_TYPE:

            break;

         default:

#ifdef DEBUG
            printf("COrplfnt: unknown action requested\n");
#endif
            break;

      }     /* end switch */
  
   } while((event.response != GR_UNKNOWN_TYPE) && (*response != TERMINATE));

   return(OM_S_SUCCESS);
}

end implementation COrplfnt;
