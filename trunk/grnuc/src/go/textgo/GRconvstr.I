/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRconv_string
 
     Abstract:		This routine maps a given multi_font text_string
		from the current module environment to the target module
		environment. Any such fonts referred by the  text_string 
		that are not available in the target environment will be
		downloaded if possible.
-----
%SC%

     VALUE =  GRconv_string( msg, text_string, text_length, target_env )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         source text string 
     text_length  IGRshort         number of bytes in source text string
     *target_env  GRmd_env	   target module env
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                 DESCRIPTION
     ----------   -----------      -------------------------------------
     *msg         IGRlong          Completion code
                                         - MSSUCC if successful

     *text_string IGRuchar         target text string 


     VALUE (IGRboolean) = TRUE            - always successful
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRfm.GRduplicate_font
               GRfm.GRmake_entry

-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
      Jagdish Bisa 	02/01/91	Design Date
      SCW               07/21/92        Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     		This routine maps a given multi_font text_string
	from the current module environment to the target module
	environment. Any such fonts referred by the  text_string 
	that are not available in the target environment will be
	downloaded if possible.

----*/
/*EH*/

class implementation GRtext;

#define ESC	27

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "OMmacros.h"
#include "gotextdef.h"
#include "exmacros.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

from GRfm import GRduplicate_font, GRmake_entry, GRfm_retdata;

IGRint GRconv_string(msg,text_string,text_length, 
						target_env )

IGRlong           *msg;          /* completion code                          */
IGRuchar          *text_string;  /* text string possibly containing esc seqs */
IGRshort          text_length;   /* number of bytes in the string 	     */
struct  GRmd_env  *target_env;   /* target module env.			     */

{
    IGRlong                  rc;         /* status return code           */
    struct vfont_entry   font_info;	 /* font specific info		 */
    IGRshort          	 current_font;   /* buffer to hold font num	 */
    struct GRid          fontmgr_obj;    /* objid of cur. font manager   */
    struct GRid          tfontmgr_obj;   /* objid of other font manager  */
    OM_S_OBJID           module_id;      /* current module object id 	 */
    OM_S_OBJID           tmodule_id;     /* object id of other module    */
    IGRint 		 i;

    *msg = MSSUCC;

     rc = ex$get_modid( mod_osnum = OM_Gw_current_OS,
                           mod_id = &module_id);

     if(!(rc & 1)) {
		printf("Error: getting current module id\n");
		goto wrapup;
     }

     rc = ex$get_modid( mod_osnum = target_env->md_id.osnum,
                           mod_id = &tmodule_id);

     if(!(rc & 1)) {
		printf("Error: getting target module id\n");
		goto wrapup;
     }


    /*
     * get the object id of the current font manager.
     */

     rc = ex$get_super( mod_id = module_id,
                     mod_osnum = OM_Gw_current_OS,
                    super_name = FONTMGR_NO_NAME,
                        create = TRUE,
                   super_class = "GRfm",
                      super_id = &fontmgr_obj.objid,
                   super_osnum = &fontmgr_obj.osnum );

     if(!(rc & 1)) {
		printf("Error: getting current font_mgr id\n");
		goto wrapup;
     }


    /*
     * get the object id of the font manager in the other
     * object space
     */

     rc = ex$get_super( mod_id = tmodule_id,
                     mod_osnum = target_env->md_id.osnum,
                    super_name = FONTMGR_NO_NAME,
                        create = TRUE,
                   super_class = "GRfm",
                      super_id = &tfontmgr_obj.objid,
                   super_osnum = &tfontmgr_obj.osnum );

     if(!(rc & 1)) {
		printf("Error: getting target font_mgr id\n");
		goto wrapup;
     }

     /* scan the text_string */

     for( i = 0 ; i< text_length;) {

	if( text_string[i] == ESC ) {

		switch(text_string[i+1]){

			case 'H':
			case 'J':
			case 'j':
			case 'y':
			case 's':
			case 'v':
			case 'x':
			case 'h':
				i= i+10;
				break;

			case 'w':
			   	i = i + 3;
			   	break;

			case 'E':
			   	i = i + 2 ;
			   	break;

			case 'F':
			   	i = i + 4;
			   	break;

			case 'M':
			   	i = i + 20;
			   	break;

			case 'm':
			   	i = i + 19;
			   	break;

			case 'f':
				/* get the font num */
                		OM_BLOCK_MOVE(&text_string[i + 2],
							&current_font,2);

				/* get the font file name */
        			rc = om$send(  msg = message GRfm.GRfm_retdata
                       					(msg, &current_font,
								&font_info),
                 				senderid = fontmgr_obj.objid,
                 				targetid = fontmgr_obj.objid,
                 				targetos = fontmgr_obj.osnum);

     				if(!(rc & *msg & 1)) {
					printf("Error: getting font_info\n");
					rc = *msg;
					goto wrapup;
     				}

#ifdef DEBUG
printf("CHANGE from font = (%d, %s)  ", (int)current_font, font_info.fontfile);
#endif

         			/*
         	 		 * search the other font manager to see if 
				 * this font is already in the other module
          	 		 */

         			rc = om$send(  mode = OM_e_wrt_object,
                      			msg = message GRfm.GRduplicate_font(msg,
                            			font_info.fontfile,
						&current_font),
                      			senderid = tfontmgr_obj.objid,
                        		targetid = tfontmgr_obj.objid,
                      			targetos = tfontmgr_obj.osnum);

     				if(!(rc & 1)) {
					printf("Error: duplicating font \n");
					goto wrapup;
     				}


         			if (*msg != MSSUCC) {
            				/* 
            		 		 * font is not in the other object 
					 * module so add font to the font 
					 * manager and download
            		 		 */

            				current_font = -1;

            				rc = om$send(mode = OM_e_wrt_object, 
                         			msg = message GRfm.GRmake_entry(msg,
                               				font_info.fontfile,
							font_info.vfontname,
                               				font_info.flags,
							&current_font),
                      				senderid = tfontmgr_obj.objid,
                         			targetid = tfontmgr_obj.objid,
                         			targetos = tfontmgr_obj.osnum);

     					if(!(rc & *msg & 1)) {
						printf("Error: downloading font  = %s\n",
							font_info.fontfile);
						rc = *msg;
						goto wrapup;
     					}


				}

				/* replace the equivalent font */
#ifdef DEBUG
printf("to font = (%d, %s)\n",(int)current_font, font_info.fontfile );
#endif

                		OM_BLOCK_MOVE( 	&current_font,
						&text_string[i + 2], 2);

			   	i = i +  4 ;
			   	break;
			default: 
			   	i = i + 1 ;
		}
	    }
	    else
	    {
		   i = i + 1 ;
	    }
	}

wrapup:
	*msg = rc;

    return(TRUE);
}

end implementation GRtext;

