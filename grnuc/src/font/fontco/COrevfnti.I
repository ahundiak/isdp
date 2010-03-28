/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: COrevfnt
     METHOD NAME: wakeup
                  sleep
                  execute
                  do_form
                  send_font_info
     Abstract: Review fonts
-----
%SC%    
     Value = COrevfnt_wakeup_method (IGRint pos)

             COrevfnt_sleep_method  (IGRint pos)
             COrevfnt_execute_method (IGRint *response;
                                      IGRchar *response_ptr;
                                      IGRint pos)

             COrevfnt_do_form_method (IGRlong *msg, 
                                      IGRint form_label,
                                      IGRint gadget_label,
                                      Form form_ptr)
             COrevfnt_send_font_info (IGRlong *msg)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
             
     Methods:  GRfm.GRfm_get_entries
               GRfm.GRupd_vfont_name
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:

     DEK  08/04/88 : Design Date.
     DEK  08/04/88 : Creation Date.
     msm  05/09/91 : Changed to c-based form. OneColoumnFont and TwoColoumnFont
                     forms are combined in GRFont. 
     JJM  02/06/92 : Added Sun-specific code to tell Forms where to look for
                     typefaces and charmaps.
     jjm  02/19/92 : added code in do_form() so when buttons were pressed,
		     the correct font sample would be displayed.
     elp  01/06/93 : semi port to NT
     elp  01/12/93 : port to NT
     scw  08/09/94 : port to Intel Solaris
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation COrevfnt;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "OMerrordef.h"
#include "exmacros.h"
#include "exdef.h"
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "godef.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "FS.h"
#include "femacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "fontmacros.h"
#include "execmsg.h"
#include "grmessage.h"
#include "grcmd.h"

#define FractionFont 3
#define SixteenBitFont 5
#define SevenBitFont 7

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

#if defined( NT )
#  ifndef alloca
#    define alloca _alloca
#  endif
#else
#  include <alloca.h>
#endif

from GRfm import GRfm_get_entries, GRupd_vfont_name, GRvirt_search, 
                 GRphy_search;

#define FONTS_IN_FILE    0
#define AVAIL_FONTS      1
#define LOGICAL_VIRTUAL_FIELD	16
#define LOGICAL_NAME_FIELD	15
#define FORM1       1
#define AVAL_FONT_GADGET 19
#define FONT_FILE_GADGET 17
#define ACCEPT_BUTTON    1
#define SHOW_FONT_TOGGLE 20
#define DISP_FONT_FIELD  14
#define DISP_TEXT        21

/*--------------------------------------------------------------*/
/*                    method: init                              */
/*--------------------------------------------------------------*/

method init ( int type; char *str_ptr )
{

#if defined ( SUNOS ) || defined ( SUNOS5 )

/* Set up search paths so Forms can find the typefaces/charmaps */
/*                                                              */
/* Jim Macklow: 2/6/92                                          */

   char *cmap="FS_CMPATH";
   char *tface="FS_TFPATH";
   char *tfpath;
   char *cmpath;
   char *tmp;


   tmp= (char *)getenv(tface);
   if (tmp)
   {
      tfpath= (char *) alloca(strlen(tmp)+37);
      if (tfpath)
      {
	 *tfpath='\0';
	 tfpath= (char *)strcat(tfpath,tmp);
	 tfpath= (char *)strcat(tfpath,":/usr/ip32/resrc/fontserver/typeface");
      }
   }

   tmp= (char *)getenv(cmap);
   if (tmp)
   {
      cmpath= (char *) alloca(strlen(tmp)+36);
      if (cmpath)
      {
	 *cmpath='\0';
	 cmpath= (char *)strcat(cmpath,tmp);
	 cmpath= (char *)strcat(cmpath,":/usr/ip32/resrc/fontserver/charmap");
      }
   }

   if (tfpath)
   {
#if ! defined( NT )
	   FI_set_FSfont_path(tfpath);
#endif
   }

   if (cmpath)
   {
#if ! defined( NT )
	   FI_set_charmap_path(cmpath);
#endif
   }

#endif

   om$send(mode = OM_e_wrt_message,
           msg = message super_cmd.init (type, str_ptr),
           targetid = my_id);

   me->form1 = NULL;  /* set form ptr to NULL to indicate it doesn't exist */

   return (OM_S_SUCCESS);
}

/*--------------------------------------------------------------*/
/*                    method: delete                            */
/*--------------------------------------------------------------*/

method delete ( int f_defer_flag )
{
   if (me->form1)
     FIf_delete(me->form1);

   om$send(mode = OM_e_wrt_message,
           msg = message Root.delete(f_defer_flag),
           targetid = my_id);

   return (OM_S_SUCCESS);
}

method super_cmd.sleep (int pos)
{
  if (me->form1)   
    FIf_erase (me->form1);

  return (OM_S_SUCCESS);
}

/*--------------------------------------------------------------*/
/*                    method: execute                           */
/*--------------------------------------------------------------*/

method execute(int *response;
               char *response_data;
               int pos )

{
   extern IGRboolean    GRisitfnt();

   IGRlong              mask;            /* co$get_event mask                */
   struct GRevent       event;           /* event returned from co$get_event */
   IGRlong              ii,jj;            /* index counters                   */
   IGRint               status;          /* status return code               */
   IGRlong              msg;             /* completion code                  */
   OM_S_OBJID           cur_mod_id;      /* current module object id         */
   GRspacenum           cur_mod_osnum;   /* current module object space num  */
   struct vfont_entry   font_info;       /* information about specified font */
   struct EX_fonts      font_parameters; /* locale font parameters           */
   struct EX_locale_var var_list;        /* locale identifiers               */
   struct EX_fonts      *all_fonts;      /* array of all fonts in font table */
   IGRint               num_chars;

   extern int                 GRfont_form_notify();

   if (me^^super_cmd.mytype == AVAIL_FONTS)
   {
      ex$message(msgnumb = GRC_M_RevAvailFnts);
   }
   else if (me^^super_cmd.mytype == FONTS_IN_FILE)
   {
      ex$message(msgnumb = GRC_M_RevFntsFile);
   }

   if (! me->form1)
   {
     ex$get_cur_mod(id = &cur_mod_id,
                    osnum = &cur_mod_osnum);

     ex$get_super(mod_id = cur_mod_id,
                  mod_osnum = cur_mod_osnum,
                  super_name = FONTMGR_NO_NAME,
                  create = TRUE,
                  super_class = "GRfm",
                  super_id = &me^^COrevfnt.fontmgr.objid,
                  super_osnum = &me^^COrevfnt.fontmgr.osnum);

     status = FIf_new(FORM1, "GRFont", GRfont_form_notify, &me->form1);
     if (status)
       return (OM_E_ABORT);

     status = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
     if (status) 
       return (OM_E_ABORT);

     me->row = 0;
     me->sample = FALSE;
   }

   if (me^^super_cmd.mytype == FONTS_IN_FILE)
   {
      /*
       * have review fonts in file
       */

      status = FIg_erase (me->form1, AVAL_FONT_GADGET);
      if (status)
        return (OM_E_ABORT);
      status = FIg_display (me->form1, FONT_FILE_GADGET);
      if (status)
        return (OM_E_ABORT);

      var_list.var = EX_font_parameters;
      var_list.var_ptr = (IGRchar *) &font_parameters;

      /*
       * get the number of defined entries in the font manager
       * and which entries they are
       */

      om$send(mode = OM_e_wrt_object,
              msg = message GRfm.GRfm_get_entries
                    (&msg,&me^^COrevfnt.num_entries,me^^COrevfnt.entries),
              senderid = my_id,
              targetos = me^^COrevfnt.fontmgr.osnum,
              targetid = me^^COrevfnt.fontmgr.objid);

      /*
       * for each defined entry, copy the virtual font name and
       * the logical name into the form's instance data
       */

      for (ii = 0; ii < me^^COrevfnt.num_entries; ++ii)
      {
         font$get_info(msg = &msg,
                       font_num = &me^^COrevfnt.entries[ii],
                       fontmgr = &me^^COrevfnt.fontmgr,
                       font_info = &font_info);

         ex$inq_locale (msg = &msg,
                        var = &var_list,
                        flags = EX_Text | EX_Logical_Name,
                        identifier = (char *)font_info.fontfile);

        status = FIfld_set_text(me->form1, LOGICAL_VIRTUAL_FIELD, ii, 0,
                                (char *) font_info.vfontname, 0);
        if (status)
          return (OM_E_ABORT);

        status = FIfld_set_text(me->form1, LOGICAL_VIRTUAL_FIELD, ii, 1,
                                font_parameters.name, 0);
        if (status)
          return (OM_E_ABORT);
      }

      status = FIfld_set_mode(me->form1, LOGICAL_VIRTUAL_FIELD, 0, 
                              FI_SINGLE_SELECT);
      if (status)
        return (OM_E_ABORT);
      status = FIfld_set_mode(me->form1, LOGICAL_VIRTUAL_FIELD, 1,
                              FI_SINGLE_SELECT);
      if (status)
        return (OM_E_ABORT);

      status = FIfld_set_select(me->form1, LOGICAL_VIRTUAL_FIELD, me->row, 0, 
                                TRUE);
      if (status)
        return (OM_E_ABORT);
      status = FIfld_set_select(me->form1, LOGICAL_VIRTUAL_FIELD, me->row, 1,
                                TRUE);
      if (status)
        return (OM_E_ABORT); 
      /*
       * review fonts in file has 2 columns
       */

   }
   else if (me^^super_cmd.mytype == AVAIL_FONTS)
   {
      /*
       * have review available fonts
       */

      status = FIg_erase (me->form1, FONT_FILE_GADGET);
      if (status)
        return (OM_E_ABORT);
      status = FIg_display (me->form1, AVAL_FONT_GADGET);
      if (status)
        return (OM_E_ABORT);

      /*
       * get the number of entries in the locale font table
       */

      var_list.var = EX_number_fonts;

      var_list.var_ptr = (IGRchar *) &num_chars;

      ex$inq_locale(msg = &msg,
                    var = &var_list,
                    flags = EX_Text);

      me^^COrevfnt.num_entries = (IGRshort) num_chars;

      /*
       * get the logical name of each entry in the locale font table
       */

      all_fonts = (struct EX_fonts *)
      om$malloc( size = me^^COrevfnt.num_entries  * sizeof( struct EX_fonts ) );

      if ( all_fonts )
      {
         var_list.var = EX_all_fonts;
         var_list.var_ptr = (IGRchar *) all_fonts;

         ex$inq_locale(msg = &msg,
                       var = &var_list,
                       flags = EX_Text);

         /*
          * for each text entry, copy the logical name into the 
          * form's instance data
          */

         for (ii = me^^COrevfnt.num_entries - 1, jj = 0; ii >= 0; --ii)
         {
            if ((all_fonts[ii].properties & EX_Text_Font) ||
                (all_fonts[ii].properties & EX_Frac_Font) ||
                (all_fonts[ii].properties & EX_Symb_Font))
            {
               num_chars = strlen(all_fonts[ii].name);

               if (GRisitfnt(&msg,all_fonts[ii].name,&num_chars,NULL))
               {
                  status = FIfld_set_text(me->form1, LOGICAL_NAME_FIELD, jj, 0,
                                          all_fonts[ii].name, 0);
                  if (status)
                    return (OM_E_ABORT);
                  ++jj;
               }
            }
         }
         status = FIfld_set_mode (me->form1, LOGICAL_NAME_FIELD, 0,
                                         FI_SINGLE_SELECT);
         if (status)
           return (OM_E_ABORT);
         status = FIfld_set_select (me->form1, LOGICAL_NAME_FIELD, me->row, 0,
                                       TRUE);
         if (status)
           return (OM_E_ABORT);

         me^^COrevfnt.num_entries = jj;
         /*
          * deallocate memory for the font info from the font table(s)
          */

         om$dealloc(ptr = all_fonts);
      }
      else  /* malloc failed */
      {
         status = FALSE;
      }
   }
   if (me->sample)
     display_font (me->form1, me->font_struct, me->row);

   status = FIf_display (me->form1);
   if (status)
     return (OM_E_ABORT);

   mask = GRm_COMMAND | GRm_DATA | GRm_RESET | GRm_STRING;

   co$getevent(msg = &msg,
               event_mask = mask,
               prompt = "",
               event = &event,
               response = response, 
               response_data = response_data);

   return (OM_S_SUCCESS);
}


int GRfont_form_notify (form_label, gadget_label, value, form_ptr)

int form_label, gadget_label;
double value;
Form  form_ptr;
{
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;

  FIf_get_cmd_oid_os (form_ptr, (unsigned int *) &cmdobj,
                      (unsigned short *) &cmdos);

  om$send (msg = message COrevfnt.do_form (&msg_loc, form_label,
                                           gadget_label, value),
           senderid = NULL_OBJID,
           targetid = cmdobj,
           targetos = cmdos);

  return FI_SUCCESS;
}

method do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
  IGRlong  status, size;
  IGRchar  buffer[2];
  IGRint  terminate = TERMINATE;
  IGRint  position;

  IGRint display_font();

  if (form_label == FORM1) {
    switch (gadget_label)
     {
      case ACCEPT_BUTTON:
        size = 2;
        status = ex$putque(msg = msg,
                           byte = &size,
                           pos = FRONT,
                           response = &terminate,
                           buffer = buffer);
        FIf_erase (me->form1);
        break;
                
      case LOGICAL_VIRTUAL_FIELD:
      case LOGICAL_NAME_FIELD   :
      /*
       * Check if a button on the index field was pushed
       */
        if (value == -1.0) {
          if (FIfld_get_active_row(me->form1,gadget_label,&me->row,&position))
            goto wrapup;
	}
        else
          me->row = value;

	if (FIfld_set_select(me->form1, gadget_label,me->row,0,TRUE))
	  goto wrapup;
        if (gadget_label == LOGICAL_VIRTUAL_FIELD){
          status = FIfld_set_select(me->form1, LOGICAL_VIRTUAL_FIELD, 
                                    me->row, 1, TRUE);
          if (status)
            goto wrapup;
        }
        if (me->sample)
          display_font (me->form1, me->font_struct, me->row);
        break;

      case SHOW_FONT_TOGGLE :
        if (!me->sample) {
          me->sample = TRUE;
          status = om$send (msg = message COrevfnt.send_font_info(msg),
                            senderid = NULL_OBJID,
                            targetid = my_id,
                            targetos = OM_Gw_current_OS);
          if (! (status & 1))
            goto wrapup;

          display_font (me->form1, me->font_struct, me->row);
        }
        else if (me->sample) {
           me->sample = FALSE;
           FIg_erase (me->form1, DISP_TEXT);
        }
        break;
    }
  }

wrapup:

  return (OM_S_SUCCESS);
}

IGRint display_font (form1, font_struct, row)

Form  form1;
struct EXlstfnt *font_struct;
IGRint row;
{
   extern char *strchr();
   IGRint status;
   IGRchar  string[80], *temp;

   temp = strchr(font_struct[row].typeface, '.');
   if (temp)
   {
   status = FIg_erase (form1, DISP_TEXT);
   if (status)
     return (OM_E_ABORT);
   temp[0]='\0';
   status = FIg_set_font (form1, DISP_TEXT, font_struct[row].typeface, 
                          (float)font_struct[row].size);
   temp[0]='.';
   if (status)
     return (OM_E_ABORT);
   if (font_struct[row].len == FractionFont)
   {
     ex$message(msgnumb = GR_I_RvFntFracFnt,
		buff = string,
		buffer_size = 80);
   }
   else if (font_struct[row].len == SixteenBitFont)
   {
     ex$message(msgnumb = GR_I_RvFnt16BitFnt,
		buff = string,
		buffer_size = 80);
   }
   else if (font_struct[row].len == SevenBitFont)
   {
     ex$message(msgnumb = GR_I_RvFnt7or8BitFnt,
		buff = string,
		buffer_size = 80);
   }
   status = FIg_set_text (form1, DISP_TEXT, string);
   if (status)
     return (OM_E_ABORT);
   status = FIg_display (form1, DISP_TEXT);
   if (status)
     return (OM_E_ABORT);
   }
 return (OM_S_SUCCESS);
}

/*--------------------------------------------------------------*/
/*                 method: send_font_info                       */
/*--------------------------------------------------------------*/

method send_font_info (IGRlong *msg)
{
   extern IGRboolean    GRisitfnt();

   struct vfont_entry   font_info;       /* information about specifed font  */
   IGRint               ii,jj;           /* index counter                    */
   struct EX_locale_var var_list;        /* locale identifiers               */
   struct EX_fonts      font_parameters; /* locale font parameters           */
   struct EX_fonts      *all_fonts;      /* array of all fonts in font table */
   IGRchar              charmap[64];     /* character mapping form form font */
   FontId               fontid;          /* identification number of font    */
   IGRint               FS_flags=0;      /* flags used by font server        */
   IGRlong              msg;             /* status message                   */
   IGRint               num_chars;
   IGRdouble		bodysize;

   msg = MSSUCC;

   ex$message(msgnumb = GR_I_Working);
   OM_SET_DIMENSION(me->font_struct, me->num_entries);
   
   if (me^^super_cmd.mytype == FONTS_IN_FILE)
   {
      var_list.var = EX_font_parameters;
      var_list.var_ptr = (IGRchar *) &font_parameters;

      for (ii = 0; ii < me^^COrevfnt.num_entries; ++ii)
      {
         font$get_info(msg = &msg,
                       font_num = &me^^COrevfnt.entries[ii],
                       fontmgr = &me^^COrevfnt.fontmgr,
                       font_info = &font_info);


         ex$inq_locale (msg = &msg,
                        var = &var_list,
                        flags = EX_Text | EX_Logical_Name,
                        identifier = (char *)font_info.fontfile);

	 /* TR90N2418: handle font 101 which contains under 
		       and over lines specially.. 
	    TR90N2420: gap for ansifrac2 */

	 if(!strcmp((char *) font_info.fontfile, "101")) 
		bodysize=18.0;
	 else
		bodysize=22.0;

	 /* TR90N2419: now the sample text does'nt overlap! */
         fe$add_font(msg = &msg,
                        typeface = font_parameters.tf,
			      bodysize = bodysize,
                              charmap = "fontform.cm",
                              flags = FS_flags,
                              font_id = &fontid);


         me->font_struct[ii].rotation = 0.0;      
         me->font_struct[ii].fontid = fontid;
         me->font_struct[ii].size = bodysize;
         strcpy(me->font_struct[ii].typeface,font_parameters.tf);

         if (font_info.flags & FRACTION_FONT)
         {
            me->font_struct[ii].len = FractionFont;
         }
         else if (font_info.flags & SIXTEEN_BIT)
         {
            me->font_struct[ii].len = SixteenBitFont;
         }
         else
         {
            me->font_struct[ii].len = SevenBitFont;
         }
      }

   }
   else if (me^^super_cmd.mytype == AVAIL_FONTS)
   {
      /*
       * get the number of entries in the locale font table
       */

      var_list.var = EX_number_fonts;
      var_list.var_ptr = (char *) &num_chars;

      ex$inq_locale(msg = &msg,
                    var = &var_list,
                    flags = EX_Text);

      me^^COrevfnt.num_entries = (short) num_chars;

      /*
       * get the logical name of each entry in the locale font table
       */

      if (all_fonts = (struct EX_fonts *) om$malloc(size = me^^COrevfnt.num_entries  * sizeof(struct EX_fonts)))
      {
         var_list.var = EX_all_fonts;
         var_list.var_ptr = (IGRchar *) all_fonts;

         ex$inq_locale(msg = &msg,
                       var = &var_list,
                       flags = EX_Text);

         strcpy(charmap,"fontform.cm");

         /*
          * for each entry, get the fontid and typeface name from the 
          * logical name
          */

         for (ii = me^^COrevfnt.num_entries - 1, jj = 0; ii >= 0; --ii)
         {
            if ((all_fonts[ii].properties & EX_Text_Font) ||
                (all_fonts[ii].properties & EX_Frac_Font) ||
                (all_fonts[ii].properties & EX_Symb_Font))
            {

               num_chars = strlen(all_fonts[ii].name);

               if (GRisitfnt(&msg,all_fonts[ii].name,&num_chars,NULL))
               {
                  if (all_fonts[ii].properties & EX_Bitmap_Font)
                  {
                     FS_flags = FS_3D;
                  }
                  else
                  {
                     FS_flags = FS_OUTLINE | FS_3D;
                  }

                  fe$add_font(msg = &msg,
                              typeface = all_fonts[ii].tf,
			      bodysize = 20.0,
                              charmap = charmap,
                              flags = FS_flags,
                              font_id = &fontid);


                  me->font_struct[jj].rotation = 0.0;
                  me->font_struct[jj].fontid = fontid;
                  me->font_struct[jj].size = 20.0;
                  strcpy(me->font_struct[jj].typeface,all_fonts[ii].tf);

                  if (all_fonts[ii].properties & EX_Frac_Font)
                  {
                     me->font_struct[jj].len = FractionFont;
                  }
                  else if (all_fonts[ii].properties & EX_Sixteen_Bit)
                  {
                     me->font_struct[jj].len = SixteenBitFont;
                  }
                  else
                  {
                     me->font_struct[jj].len = SevenBitFont;
                  }

                  ++jj;
               }
            }
         }

         /*
          * deallocate memory for the font info from the font table(s)
          */

         om$dealloc(ptr = all_fonts);
      }
   }
   ex$message(msgnumb = EX_S_Clear);

   return(OM_S_SUCCESS);
}

end implementation COrevfnt;
