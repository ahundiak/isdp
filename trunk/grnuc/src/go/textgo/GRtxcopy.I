/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRtext
     METHOD NAME:  GRcopy

     Abstract: This method copies a text object to the object
               space described in the structure new_dsenv. If
               the object space is different, the virtual font
               number in the copy is updated to reflect the font
               manager in that object space. If the font does
               not exist in that object space, it is downloaded.
-----
%SC%    

     GRcopy(msg,obj_dsenv,new_dsenv,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   ------------------------------------
     *obj_dsenv   GRmd_env       struct describing object's present
                                 environment
     *new_dsenv   GRmd_env       struct describing copy's environment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   -----------------------------------
     msg          IGRlong        completion code
                                      - MSSUCC if successful
                                      - MSFAIL (severe) if failure
     *newobjid    GRobjid        objid of the copied object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRgraphics.GRcopy
               GRfm.GRfm_retdata
               GRfm.GRduplicate_font
               GRfm.GRmake_entry
               GRtext.GRchgtextattr
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        DEK     02/03/87: Design date.
        DEK     02/04/87: Creation date.
  Jagdish Bisa	02/02/91: Added  code  to take care of Inter_Os copying
			  of text objects having multi_font text_string
        mrm     06/12/91: check for MSINARG from GRfm_retdata
        SCW     07/21/92: Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method copies a text object to the object space described 
in the structure new_dsenv. If the object space is different, the 
virtual font number in the copy is updated to reflect the font
manager in that object space. If the font does not exist in that 
object space, it is downloaded.
----*/
/*EH*/

class implementation GRtext;

#include <stdio.h>
#include "msdef.h"
#include "fontdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grimport.h"
#include "gotextdef.h"
#include "grownmacros.h"

from GRfm import GRfm_retdata, GRduplicate_font, GRmake_entry;

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
              struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
   IGRlong                  rc;            /* status return code            */
   IGRshort                 vfontnum;      /* virtual font number           */
   IGRint	    	    text_length;
   struct GRdpb_text_symb   text_symb;     /* text specific attributes      */
   struct vfont_entry       font_info;     /* font entry information        */
   struct GRid              fontmgr_obj;   /* objid of font manager         */
   OM_S_OBJID               module_id;     /* object id of other module     */
   IGRint		    sts;
   IGRboolean		    Inter_Os_Copy;
   IGRuchar       	    *text_string;

   text_length = 0;
   text_string = NULL;
   rc = MSSUCC;

   text_symb.Active_just = me^^GRtext.attr.just;
   text_symb.Active_height = me^^GRtext.attr.height;
   text_symb.Active_width = me^^GRtext.attr.width;
   text_symb.Active_charspac = me^^GRtext.attr.char_spac;
   text_symb.Active_linespac = me^^GRtext.attr.line_spac;


   /* In case of Inter_Os Copy, Save the original text_string of the 
    * object, then convert the original text_string int an equivalent
    * one in the target OS. i.e map the font changes < if any > .
    */

   if (new_dsenv->md_id.osnum != obj_dsenv->md_id.osnum) {
	Inter_Os_Copy = TRUE;
   	if(me->attr.text_length){
		text_length = (IGRint) me->attr.text_length;
		text_string = (IGRuchar *)om$malloc( size = text_length );
		memcpy((char *)text_string, (char *)me->text_string, 
                       text_length);

    		sts = GRconv_string (msg, (char *)me->text_string, 
					(IGRint)text_length, new_dsenv );

        	if(!(*msg & 1)) {
			printf("Error: converting text string\n");
			goto wrapup;
        	}
    	}
    }
    else
	Inter_Os_Copy = FALSE;
	
   /*
    * copy the text object to the indicated space
    */

   rc = om$send(mode = OM_e_wrt_message,
                msg = message GRgraphics.GRcopy(msg,obj_dsenv,new_dsenv,
                      newobjid),
                senderid = my_id,
                targetid = my_id,
                targetos = OM_Gw_current_OS);

   if ((1 & rc) && (*msg == MSSUCC)){
      /*
       * if the text object is copied to another object space, the font
       * manager of the new space will have to be searched for the
       * required font
       */

      if (Inter_Os_Copy){
         /*
          * get the object id of the font manager in the current space
          */

         rc = ex$get_super(mod_id = obj_dsenv->md_id.objid,
                      mod_osnum =   obj_dsenv->md_id.osnum,
                      super_name = FONTMGR_NO_NAME,
                      create = TRUE,
                      super_class = "GRfm",
                      super_id = &fontmgr_obj.objid,
                      super_osnum = &fontmgr_obj.osnum);

     	if(!(rc & 1)) {
		printf("Error: getting font_mgr id\n");
		goto wrapup;
     	}

         /*
          * get the font information of the font in the current space
          */

        rc = om$send(mode = OM_e_wrt_object,
                 msg = message GRfm.GRfm_retdata
                       (msg,&me^^GRtext.attr.font,&font_info),
                 senderid = my_id,
                 targetid = fontmgr_obj.objid,
                 targetos = fontmgr_obj.osnum);
        /*
         *  MSINARG is okay; the method will return info for the default font
         */ 

     	if(!(rc & *msg & 1) && (*msg != MSINARG)) {
		printf("Error: getting font_info\n");
		goto wrapup;
     	}

         /*
          * get the object id of the font manager in the other
          * object space
          */

         rc = ex$get_modid(mod_osnum = new_dsenv->md_id.osnum,
                      mod_id = &module_id);

     	if(!(rc & 1)) {
		printf("Error: getting module id\n");
		goto wrapup;
     	}

         rc = ex$get_super(mod_id = module_id,
                      mod_osnum = new_dsenv->md_id.osnum,
                      super_name = FONTMGR_NO_NAME,
                      create = TRUE,
                      super_class = "GRfm",
                      super_id = &fontmgr_obj.objid,
                      super_osnum = &fontmgr_obj.osnum);

     	if(!(rc & 1)) {
		printf("Error: getting font_mgrid\n");
		goto wrapup;
     	}

         /*
          * search the font manager to see if this font is already
          * in the module
          */

         rc = om$send(mode = OM_e_wrt_object,
                      msg = message GRfm.GRduplicate_font(msg,
                            font_info.fontfile,&vfontnum),
                      senderid = my_id,
                      targetid = fontmgr_obj.objid,
                      targetos = fontmgr_obj.osnum);

         if (*msg != MSSUCC){
            /* 
             * font is not in the other object space so add font
             * to the font manager and download
             */

            vfontnum = -1;

            rc = om$send(mode = OM_e_wrt_object, 
                         msg = message GRfm.GRmake_entry(msg,
                               font_info.fontfile,font_info.vfontname,
                               font_info.flags,&vfontnum),
                         senderid = my_id,
                         targetid = fontmgr_obj.objid,
                         targetos = fontmgr_obj.osnum);

            if (!(rc & *msg & 1)){
               struct  GRdpb_text_symb   current_text_symb;
               IGRlong                   nbytes_in_buffer;
               IGRlong                   nbytes_transferred;

               /*
                * could not download the copied text's font; use the
                * default font
                */

               nbytes_in_buffer = sizeof(current_text_symb);
               gr$get_text_symb(msg = msg,
                                sizbuf = &nbytes_in_buffer,
                                buffer = &current_text_symb,
                                nret = &nbytes_transferred);
               vfontnum = current_text_symb.Active_font;
            }
         }

         text_symb.Active_font = vfontnum;

         /*
          * update the copied text object with the correct virtual
          * font number
          */

         rc = om$send(mode = OM_e_wrt_object,
                      msg =  message GRtext.GRchgtextattr(msg,new_dsenv,
                               	GRTEXT_FONT, &text_symb),
                      senderid = my_id,
                      targetid = *newobjid,
                      targetos = new_dsenv->md_id.osnum);

     	if(!(rc & *msg & 1)) {
		printf("Error: changing text attr\n");
		goto wrapup;
     	}

      }

      gr$add_to_active_owner(msg = msg,
                             mod_env = new_dsenv,
                             objid = *newobjid,
                             osnum = new_dsenv->md_id.osnum);

   }

wrapup:

   /* Reset the original text_string of this object */

   if (Inter_Os_Copy) {
   	if(me->attr.text_length){
		memcpy((char *)me->text_string, (char *)text_string,
                       text_length);
		om$dealloc ( ptr = text_string );	
    	}
    }

   return (rc);   
}

end implementation GRtext;

