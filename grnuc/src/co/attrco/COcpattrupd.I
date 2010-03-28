/*

Name
    COcpattrupd.I

Description
    These methods support the copy symbology and copy text parameters
    forms.

History
    03/15/89 : jay wallingford : creation date

    03/01/93 : Change exfidef.h exfi.h
*/

class implementation COcpattr;

#include <coimport.h>
#include "font.h"
#include "exfi.h"

extern IGRint COdpb_get_font();
extern IGRint COdpb_get_just();
extern IGRint COdpb_get_style();

from GRfm import GRfm_retdata, GRduplicate_font, GRmake_entry;

/*

Name
     form_update

Abstract
     This method updates the copy symbology and copy text
     parameters forms.

Synopsis
     mask   IGRuint   I   mask of which fields to display on the form.  Defined
                          in dpbco.h - CO_level, CO_weight, CO_color, etc.

Description

Return Value
     IGRlong    OM_S_SUCCESS    no problems - success.

Notes

Index

Keywords
     symbology and text parameters form(s)

History
     12/21/87 : Jay Wallingford : Design and Implementation.
     04/26/89 : jhw             : Changed to cbase forms.

*/

method form_update ( IGRuint mask )
{
    /* external functions */
    extern IGRdouble atof();

    /* misc macro arguments and flags */
    IGRlong        ok, rc, status;
    IGRshort       num_alias=1;
    IGRshort       field_size=sizeof(IGRchar) * EXFI_STRLEN;
    IGRchar        str[EXFI_STRLEN];
    IGRint         count;
    IGRshort       vfontnum;                                  

    struct GRid            mod_id,fontmgr_obj;
    struct GRobj_env       obj_env;
    struct vfont_entry     font_info;
    struct COdpb_attr *    p;

    status = OM_S_SUCCESS;

    p = &me->Attr[me->Active];

    /*
     * Clear the message field.
     */
    FIfld_set_text ( me->status_display_form_ptr, 
                     MSG_FIELD, 
                     0, 0, 
                     "", 
                     FALSE );

    if ( mask & CO_level ) 
    {
        IGRlong sz_name = EXFI_STRLEN;

        /* 
         * Display the current symbology on the form
         */
         sprintf(str,"%d",p->Level);
         FIfld_set_text ( me->status_display_form_ptr, 
                          LEVEL_VALUE_FIELD, 
                          0, 0, 
                          str, 
                          FALSE);

        /* 
         * Get the level name if it exists.
         */
        status = dp$levels_number_to_name(msg = &ok,
                                          number = &p->Level,
                                          size_name_buffer = &sz_name,
                                          name = str,
                                          mod_objid = me->ModuleInfo.md_id.objid,
                                          osnum = me->ModuleInfo.md_id.osnum);

        FIfld_set_text ( me->status_display_form_ptr, 
                         LEVEL_ALPHA_FIELD, 
                         0, 0, 
                         (ok&status&1) ? str : "", 
                         FALSE);
    } /* End If Level */

    if ( mask & CO_color ) 
    {
        /*
         * Display the color.
         */
        sprintf(str,"%d",p->dpb_Display.color);

        FIfld_set_text ( me->status_display_form_ptr, 
                         COLOR_VALUE_FIELD, 
                         0, 0, 
                         str, 
                         FALSE);
        /* 
         * Get the color name if it exists.
         */
        status = ige$get_name_from_color( color = p->dpb_Display.color,
                                          name = str,
                                          mod_id = me->ModuleInfo.md_id.objid,
                                          mod_osnum = me->ModuleInfo.md_id.osnum);
          
        FIfld_set_text ( me->status_display_form_ptr, 
                         COLOR_ALPHA_FIELD, 
                         0, 0, 
                         (status&1) ? str : "", 
                         FALSE );
    } /* End If Color */

    if ( mask & CO_weight ) 
    {
        /*
         * Display the weight.
         */
        sprintf(str,"%d",p->dpb_Display.weight);

        FIfld_set_text ( me->status_display_form_ptr, 
                         WEIGHT_VALUE_FIELD, 
                         0, 0, 
                         str, 
                         FALSE );
    } /* End If Weight */

    /*
     * If the current form is copytxsymb.
     */
    if ( me->mytype == COPYTXSYMB )
    {

       status = om$get_channel_count( objid = my_id,
				      p_chanselect = &me->located_chansel,
				      count = (OMuint *)&count);
       
       if ( (1 & status) && count ) 
       {
	   /* get the obj_env of object on located channel */

      	    status = gr$gsget_objects( msg = &ok,
 	                               array = &obj_env,
                                       size = sizeof(struct GRobj_env),
                                       count = &count,
				       from_obj = 0,
				       to_obj = 0,
                                       p_chanselect = &me->located_chansel );

            _err_ck2( status, ok );

	    mod_id.osnum = obj_env.obj_id.osnum;

	    ex$get_modid( mod_osnum = obj_env.obj_id.osnum,
	  	          mod_id = &mod_id.objid);

            if (mod_id.osnum !=  me->ModuleInfo.md_id.osnum)
	    {
         	/*
          	 * get the object id of the font manager 
		 * in located obj space
         	 */

         	ex$get_super( mod_id = mod_id.objid,
                	      mod_osnum = mod_id.osnum,
                      	      super_name = FONTMGR_NO_NAME,
                      	      create = TRUE,
                              super_class = "GRfm",
                       	      super_id = &fontmgr_obj.objid,
                              super_osnum = &fontmgr_obj.osnum);

         	/*
         	 * get the font information of the font in the
	         * located object space
          	 */

         	om$send(mode = OM_e_wrt_object,
                	msg = message GRfm.GRfm_retdata
                       		(&ok,&p->TextSymb.Active_font,&font_info),
			senderid = my_id,
                 	targetid = fontmgr_obj.objid,
                 	targetos = fontmgr_obj.osnum);

	         /*
        	  * get the object id of the font manager in the other
          	  * object space
         	  */

	         ex$get_super(mod_id = me->ModuleInfo.md_id.objid,
	                      mod_osnum = me->ModuleInfo.md_id.osnum,
        	              super_name = FONTMGR_NO_NAME,
                	      create = TRUE,
	                      super_class = "GRfm",
        	              super_id = &fontmgr_obj.objid,
                	      super_osnum = &fontmgr_obj.osnum);

	         /*
        	  * search the font manager to see if this font is already
	          * in the module
        	  */

	         rc = om$send(mode = OM_e_wrt_object,
        	              msg = message GRfm.GRduplicate_font(&ok,
                	            font_info.fontfile,&vfontnum),
			      senderid = my_id,
                              targetid = fontmgr_obj.objid,
        	              targetos = fontmgr_obj.osnum);

	         if (ok != MSSUCC)
        	 {
	            /* 
        	     * font is not in the other object space so add font
	             * to the font manager and download
        	     */

	            vfontnum = -1;

        	    rc = om$send(mode = OM_e_wrt_object, 
                	         msg = message GRfm.GRmake_entry(&ok,
                        	       font_info.fontfile,font_info.vfontname,
                               	       font_info.flags,&vfontnum),
	                         targetid = fontmgr_obj.objid,
        	                 targetos = fontmgr_obj.osnum);

	            if (!(rc & ok & 1))
        	    {
	               struct  GRdpb_text_symb   current_text_symb;
        	       IGRlong                   nbytes_in_buffer;
	               IGRlong                   nbytes_transferred;

        	       /*
                	* could not download the copied text's font; use the
	                * default font
        	        */

	               nbytes_in_buffer = sizeof(current_text_symb);
        	       gr$get_text_symb(msg = &ok,
                	                sizbuf = &nbytes_in_buffer,
                        	        buffer = &current_text_symb,
                                	nret = &nbytes_transferred);
	               vfontnum = current_text_symb.Active_font;
        	    }
	         }

        p->TextSymb.Active_font = vfontnum;

	    }

	}

        if ( mask & CO_font ) 
        {
            /* 
             * Search for the active font name.
             */
            ok = COdpb_get_font ( str,
                                  &p->TextSymb.Active_font,
                                  CO_font,
                                  CO_attr_to_name );
            _err_ck(ok);

            /*
             * Output the font name.
             */  
            FIfld_set_text ( me->status_display_form_ptr, 
                             FONT_ALPHA_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );
        } /* End If FtTog */

        if ( mask & CO_height ) 
        {
            status = co$cvt_imp_to_alias( msg = &ok,
                                          unit_type = "UOM_DISTANCE",
                                          osnum = me->ModuleInfo.md_id.osnum,
                                          working_units = &(p->TextSymb.Active_height),
                                          num_alias = &num_alias,
                                          field_size = &field_size,
                                          cvt_list = str);
            _err_ck2(status,ok);

            FIfld_set_text ( me->status_display_form_ptr, 
                             HEIGHT_ALPHA_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

        } /* End If Height */

        if ( mask & CO_width ) 
        {
            status = co$cvt_imp_to_alias( msg = &ok,
                                          unit_type = "UOM_DISTANCE",
                                          osnum = me->ModuleInfo.md_id.osnum,
                                          working_units = &(p->TextSymb.Active_width),
                                          num_alias = &num_alias,
                                          field_size = &field_size,
                                          cvt_list = str);
            _err_ck2(status,ok);

            FIfld_set_text ( me->status_display_form_ptr, 
                             WIDTH_ALPHA_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

        } /* End If Width */

        if ( mask & CO_just ) 
        {
            sprintf(str, "%d", p->TextSymb.Active_just);

            FIfld_set_text ( me->status_display_form_ptr, 
                             JUST_VALUE_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

            COdpb_get_just ( str, &p->TextSymb.Active_just, CO_attr_to_name );

            FIfld_set_text ( me->status_display_form_ptr, 
                             JUST_ALPHA_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

        } /* End If Text Justification */

        if ( mask & CO_linesp ) 
        {
            sprintf(str, "%g", p->TextSymb.Active_linespac);

            FIfld_set_text ( me->status_display_form_ptr, 
                             LINESP_VALUE_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

        } /* End If Line Spacing */

        if ( mask & CO_charsp ) 
        {
            sprintf(str, "%g", p->TextSymb.Active_charspac);

            FIfld_set_text ( me->status_display_form_ptr, 
                             CHARSP_VALUE_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );
        } /* End If Character Spacing */
    }
    /* 
     * Else the form was copysymb.
     */
    else
    {  
        if ( mask & CO_style ) 
        {
            /* 
             * Display the style, which is only on the copysymb form.
             */                  
            sprintf(str, "%d", p->dpb_Display.style);

            FIfld_set_text ( me->status_display_form_ptr, 
                             STYLE_VALUE_FIELD, 
                             0, 0, 
                             str, 
                             FALSE );

        } /* End If Line Style */
    }
     
quit:
     return status;
}

end implementation COcpattr;
