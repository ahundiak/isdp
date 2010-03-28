/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRtext
    METHOD NAME:  GRreplace_text

    Abstract:   This method replaces a text object's text string with the
              specified text string, updates the justification moves in the
              text string and updates the text object's range in the R-tree.
-----
%SC%    
        GRreplace_text(msg,env,text_length,text_string)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
    ------------  ------------   ------------------------------------
     *env         struct GRmd_env environment structure
     text_length  IGRshort        length of text string (in bytes)
     *text_string IGRuchar        replacement text string
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong         completion code
                                    MSSUCC - successful completion
                                    MSFAIL - failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:
        none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     04/07/88 : Design date.
        WBC     04/07/88 : Creation date.
        SCW     07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This method replaces a text object's text string with the
specified text string, updates the justification moves in the
text string and updates the text object's range in the R-tree.
----*/
/*EH*/

class implementation GRtext;

#include   "grimport.h"
#include   "msdef.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotextdef.h"
#include   "gotext.h"
#include   "OMmacros.h"
#include   "exmacros.h"
#include   "grdpbdef.h"
#include   "grdpb.h"
#include   "grdpbmacros.h"

from GRfm  import GRfm_retdata;

method GRreplace_text(IGRlong *msg; struct GRmd_env *env;
                      IGRshort text_length;  IGRuchar *text_string)
{
    extern IGRboolean   GRabsg_del_by_objid();
                                /* deletes abstract geometry from the cache  */
    IGRlong             rc;                       /* return code             */
    IGRlong             temp_msg;
    IGRlong             nbytes_in_buffer;
    IGRlong             nbytes_transferred;
    GRobjid             new_objid;                /* objid of the text elem  */
    OM_S_OBJID          cur_mod_id;               /* current module's objid  */
    struct  GRid        fontmgr_obj;              /* font manager object     */
    struct  vfont_entry font_info;
    struct  IGRlbsys    lbs;                      /* local bounded system    */
    struct  extents     extents;                  /* extents of text string  */
    struct  GRpost_info info;     /* processing info. for post abstr. geom.  */
    struct  GRdpb_text_symb text_symb;

    ex$get_modid(mod_osnum = OM_Gw_current_OS,
                 mod_id = &cur_mod_id);

    /*
     *  get the objid of the font manager using
     *  its named object
     */

    ex$get_super(mod_id = cur_mod_id,
                 mod_osnum = OM_Gw_current_OS,
                 super_name = FONTMGR_NO_NAME,
                 create = TRUE,
                 super_class = "GRfm",
                 super_id = &fontmgr_obj.objid,
                 super_osnum = &fontmgr_obj.osnum);

    /*
     * get address block of specified font
     */

    rc = om$send(mode = OM_e_wrt_object,
                 msg = message GRfm.GRfm_retdata
                           (&temp_msg,&me^^GRtext.attr.font,
                            &font_info),
                 senderid = my_id,
                 targetid = fontmgr_obj.objid,
                 targetos = OM_Gw_current_OS);

    if (1 & rc & temp_msg)
    {
        /*
         * initialize text symbology structure with current text object values;
         * some text symbology members are not saved as instance data of the
         * text object, so use the active symbology for these members
         */

        nbytes_in_buffer = sizeof(text_symb);

        gr$get_text_symb(msg = &temp_msg,
                         sizbuf = &nbytes_in_buffer,
                         buffer = &text_symb,
                         nret = &nbytes_transferred);

        if (temp_msg & 1)
        {
            text_symb.Active_linespac = me^^GRtext.attr.line_spac;
            text_symb.Active_charspac = me^^GRtext.attr.char_spac;
            text_symb.Active_font = me^^GRtext.attr.font;
            text_symb.Active_just = me^^GRtext.attr.just;
            text_symb.Active_width = me^^GRtext.attr.width;
            text_symb.Active_height = me^^GRtext.attr.height;
            text_symb.Active_flags = me^^GRtext.attr.flag;

            /*
             * replace the text object's text string with the replacement
             * text string
             */

            me^^GRtext.attr.text_length = text_length;
            om$vla_set_dimension(varray = me^^GRtext.text_string,
                                 size = (IGRuint)me^^GRtext.attr.text_length);
            OM_BLOCK_MOVE(text_string,
                          me^^GRtext.text_string,
                          (IGRint)me^^GRtext.attr.text_length);

            /*
             *  update the justification moves of the text string
             */

            rc = om$send(msg = message GRtext.GRchgtxstring(&temp_msg,
                                                            &text_symb,
                                                            &font_info,
                                                            0,NULL,
                                                            &extents),
                         senderid = my_id,
                         targetid = my_id);

            if (1 & rc & temp_msg)
            {
                /*
                 *  Initialize arguments in order to post the abstract
                 *  data.  This will update the text object's range in
                 *  the R-tree (unless the module environment's objid
                 *  equals NULL_OBJID).
                 */

                info.construct_flag = FALSE;

                /* get geometry of the local bounded system   */

                rc = om$send(mode = OM_e_wrt_object,
                             msg = message GRvg.GRgetgeom
                                       (&temp_msg,
                                        &env->md_env.matrix_type,
                                        env->md_env.matrix,
                                        (IGRchar *)&lbs),
                             senderid = my_id,
                             targetid = my_id);

                if (1 & rc & temp_msg)
                {
                    /*
                     *  update the local bounded system's diagonal points
                     *  to reflect the new extents of the text string
                     */

                    lbs.diag_pt1[0] = extents.left;
                    lbs.diag_pt1[1] = extents.bottom;
                    lbs.diag_pt1[2] = 0;
                    lbs.diag_pt2[0] = extents.right;
                    lbs.diag_pt2[1] = extents.top;
                    lbs.diag_pt2[2] = 0;

                    rc = om$send(mode = OM_e_wrt_object,
                                 msg = message GRvg.GRpostabsg
                                          (&temp_msg,env,&info,
                                          (IGRchar *)&lbs,&new_objid),
                                 senderid = my_id,
                                 targetid = my_id);

                    if (1 & rc & temp_msg)
                    {
                        GRabsg_del_by_objid(&my_id,&OM_Gw_current_OS);
                    }
                }
                else  /* GRvg.GRgetgeom failed */
                {
                    *msg = MSFAIL;
                }
            }
            else  /* GRtext.GRchgtxstring failed */
            {
                *msg = MSFAIL;
            }
        }
        else  /* gr$get_text_symb failed */
        {
            *msg = MSFAIL;
        }
    }
    else  /* GRfm.GRfm_retdata failed */
    {
        *msg = MSFAIL;
    }
    return(OM_S_SUCCESS);
}

end implementation GRtext;
